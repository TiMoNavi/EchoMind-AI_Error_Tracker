"""Weekly review service."""
from datetime import datetime, timedelta, timezone

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.question import Question
from app.models.student_mastery import StudentMastery
from app.models.student import Student
from app.models.model import Model
from app.models.knowledge_point import KnowledgePoint
from app.schemas.weekly_review import WeeklyReviewResponse, WeeklyProgress


async def get_weekly_review(db: AsyncSession, user: Student) -> WeeklyReviewResponse:
    now = datetime.now(timezone.utc)
    week_ago = now - timedelta(days=7)

    # 本周题目统计
    result = await db.execute(
        select(
            func.count().label("total"),
            func.count().filter(Question.is_correct == True).label("correct"),
            func.count().filter(Question.is_correct == False).label("errors"),
        ).where(Question.student_id == user.id, Question.created_at >= week_ago)
    )
    row = result.one()

    # 本周新掌握数（level >= 3）
    mastery_result = await db.execute(
        select(func.count()).where(
            StudentMastery.student_id == user.id,
            StudentMastery.current_level >= 3,
            StudentMastery.updated_at >= week_ago,
        )
    )
    new_mastered = mastery_result.scalar() or 0

    # 上周正确率（用于计算 score_change）
    two_weeks_ago = week_ago - timedelta(days=7)
    last_week_result = await db.execute(
        select(
            func.count().label("total"),
            func.count().filter(Question.is_correct == True).label("correct"),
        ).where(
            Question.student_id == user.id,
            Question.created_at >= two_weeks_ago,
            Question.created_at < week_ago,
        )
    )
    lw = last_week_result.one()
    this_week_rate = row.correct / row.total if row.total > 0 else 0
    last_week_rate = lw.correct / lw.total if lw.total > 0 else 0
    # 折算 150 分制的分差
    score_change = round((this_week_rate - last_week_rate) * 150, 1)

    # 薄弱项作为下周重点
    weak_result = await db.execute(
        select(StudentMastery.target_id).where(
            StudentMastery.student_id == user.id,
            StudentMastery.current_level <= 1,
        ).order_by(StudentMastery.error_count.desc()).limit(5)
    )
    next_week_focus = [r[0] for r in weak_result.all()]

    # 本周/上周预测分（正确率 × 150）
    this_week_score = round(this_week_rate * 150, 1)
    last_week_score = round(last_week_rate * 150, 1)

    # 本周新掌握项名称（从 mastery → Model/KnowledgePoint 查名称）
    mastered_rows = await db.execute(
        select(StudentMastery.target_id, StudentMastery.target_type).where(
            StudentMastery.student_id == user.id,
            StudentMastery.current_level >= 3,
            StudentMastery.updated_at >= week_ago,
        )
    )
    progress_items: list[str] = []
    for mid, mtype in mastered_rows.all():
        if mtype == "model":
            r = await db.execute(select(Model.name).where(Model.id == mid))
        else:
            r = await db.execute(select(KnowledgePoint.name).where(KnowledgePoint.id == mid))
        name = r.scalar()
        if name:
            progress_items.append(name)

    # 下周重点项名称解析
    focus_item_names: list[str] = []
    for fid in next_week_focus:
        r = await db.execute(select(Model.name).where(Model.id == fid))
        name = r.scalar()
        if not name:
            r = await db.execute(select(KnowledgePoint.name).where(KnowledgePoint.id == fid))
            name = r.scalar()
        if name:
            focus_item_names.append(name)

    return WeeklyReviewResponse(
        score_change=score_change,
        weekly_progress=WeeklyProgress(
            total_questions=row.total,
            correct_count=row.correct,
            error_count=row.errors,
            new_mastered=new_mastered,
        ),
        dashboard_stats={
            "formula_memory_rate": user.formula_memory_rate,
            "model_identify_rate": user.model_identify_rate,
            "calculation_accuracy": user.calculation_accuracy,
            "reading_accuracy": user.reading_accuracy,
        },
        next_week_focus=next_week_focus,
        last_week_score=last_week_score,
        this_week_score=this_week_score,
        progress_items=progress_items,
        focus_item_names=focus_item_names,
    )
