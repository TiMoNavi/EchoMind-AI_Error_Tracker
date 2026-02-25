"""Exam service."""
from datetime import datetime, timedelta, timezone

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.question import Question
from app.schemas.exam import ExamItem, HeatmapPoint


async def get_recent_exams(db: AsyncSession, student_id) -> list[ExamItem]:
    """按日期聚合 Question 记录，模拟考试列表（无独立考试表）。"""
    now = datetime.now(timezone.utc)
    start = now - timedelta(days=90)

    day_col = func.date_trunc("day", Question.created_at)
    result = await db.execute(
        select(
            day_col.label("day"),
            func.count().label("total"),
            func.count().filter(Question.is_correct == True).label("correct"),
        ).where(
            Question.student_id == student_id,
            Question.created_at >= start,
        ).group_by(day_col).order_by(day_col.desc()).limit(10)
    )
    rows = result.all()

    exams: list[ExamItem] = []
    for i, row in enumerate(rows):
        date_str = row.day.strftime("%Y-%m-%d")
        # 按正确率折算 150 分制
        score = round(row.correct / row.total * 150, 1) if row.total > 0 else None
        exams.append(ExamItem(
            id=f"exam-{date_str}",
            name=f"{date_str} 练习 ({row.total}题)",
            score=score,
            total_score=150,
            date=date_str,
        ))

    return exams


async def get_heatmap(db: AsyncSession, student_id) -> list[HeatmapPoint]:
    now = datetime.now(timezone.utc)
    start = now - timedelta(days=180)
    day_col = func.date_trunc("day", Question.created_at)
    result = await db.execute(
        select(
            day_col.label("day"),
            func.count().label("cnt"),
        ).where(
            Question.student_id == student_id,
            Question.created_at >= start,
        ).group_by(day_col).order_by(day_col)
    )
    return [
        HeatmapPoint(date=row.day.strftime("%Y-%m-%d"), count=row.cnt)
        for row in result.all()
    ]
