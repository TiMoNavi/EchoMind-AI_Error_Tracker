"""Mastery service — 掌握度计算与更新。"""
import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

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
