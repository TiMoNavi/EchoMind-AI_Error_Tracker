"""Mastery service — 掌握度计算与更新。"""
import uuid
from datetime import datetime, timezone

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.student import Student
from app.models.student_mastery import StudentMastery

REWARD = 10.0
PENALTY = 15.0
UNSTABLE_THRESHOLD = 3


async def update_mastery(
    db: AsyncSession,
    student_id: uuid.UUID,
    target_type: str,
    target_id: str,
    is_correct: bool,
) -> None:
    """更新掌握度：答对 +reward，答错 -penalty，clamp 0-100。"""
    result = await db.execute(
        select(StudentMastery).where(
            StudentMastery.student_id == student_id,
            StudentMastery.target_type == target_type,
            StudentMastery.target_id == target_id,
        )
    )
    mastery = result.scalar_one_or_none()

    if not mastery:
        mastery = StudentMastery(
            student_id=student_id,
            target_type=target_type,
            target_id=target_id,
            mastery_value=50.0,
            correct_count=0,
            error_count=0,
            current_level=2,
            peak_level=2,
            recent_results=[],
        )
        db.add(mastery)

    # 更新计数
    if is_correct:
        mastery.correct_count += 1
        mastery.mastery_value = min(100.0, mastery.mastery_value + REWARD)
    else:
        mastery.error_count += 1
        mastery.mastery_value = max(0.0, mastery.mastery_value - PENALTY)

    # 更新 recent_results（保留最近 10 次）
    recent = list(mastery.recent_results or [])
    recent.append(is_correct)
    mastery.recent_results = recent[-10:]

    # 连续错 3 次以上标记 is_unstable
    consecutive_errors = 0
    for r in reversed(mastery.recent_results):
        if not r:
            consecutive_errors += 1
        else:
            break
    mastery.is_unstable = consecutive_errors >= UNSTABLE_THRESHOLD

    # 更新 current_level（mastery_value 映射到 0-5 级）
    mastery.current_level = int(mastery.mastery_value // 20)
    mastery.peak_level = max(mastery.peak_level, mastery.current_level)
    mastery.last_active = datetime.now(timezone.utc)

    await db.flush()


async def update_student_dimensions(db: AsyncSession, student_id: uuid.UUID) -> None:
    """从 StudentMastery 聚合计算 Student 四维能力字段。

    MVP 映射：
    - formula_memory_rate: 知识点(kp)类掌握度均值 / 100
    - model_identify_rate: 题型(model)类掌握度均值 / 100
    - calculation_accuracy: 全部记录的正确率 (correct / total)
    - reading_accuracy: 最近做题的正确率 (recent_results 聚合)
    """
    result = await db.execute(
        select(StudentMastery).where(StudentMastery.student_id == student_id)
    )
    rows = result.scalars().all()
    if not rows:
        return

    kp_values = []
    model_values = []
    total_correct = 0
    total_attempts = 0
    recent_correct = 0
    recent_total = 0

    for m in rows:
        if m.target_type == "kp":
            kp_values.append(m.mastery_value)
        elif m.target_type == "model":
            model_values.append(m.mastery_value)
        total_correct += m.correct_count
        total_attempts += m.correct_count + m.error_count
        for r in (m.recent_results or []):
            recent_total += 1
            if r:
                recent_correct += 1

    student = await db.get(Student, student_id)
    if not student:
        return

    student.formula_memory_rate = (sum(kp_values) / len(kp_values) / 100.0) if kp_values else 0.0
    student.model_identify_rate = (sum(model_values) / len(model_values) / 100.0) if model_values else 0.0
    student.calculation_accuracy = (total_correct / total_attempts) if total_attempts > 0 else 0.0
    student.reading_accuracy = (recent_correct / recent_total) if recent_total > 0 else 0.0

    await db.flush()


async def update_predicted_score(db: AsyncSession, student_id: uuid.UUID) -> None:
    """基于掌握度加权计算预测分数，写入 Student.predicted_score。

    MVP 算法：avg(mastery_value) / 100 * target_score
    """
    result = await db.execute(
        select(func.avg(StudentMastery.mastery_value)).where(
            StudentMastery.student_id == student_id
        )
    )
    avg_mastery = result.scalar()
    if avg_mastery is None:
        return

    student = await db.get(Student, student_id)
    if not student:
        return

    student.predicted_score = round((avg_mastery / 100.0) * student.target_score, 1)
    student.last_prediction_time = datetime.now(timezone.utc)

    await db.flush()
