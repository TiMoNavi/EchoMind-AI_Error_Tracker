"""Weekly review service."""
from datetime import datetime, timedelta, timezone

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.question import Question
from app.models.student_mastery import StudentMastery
from app.models.student import Student
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
    )
