"""Exam service."""
from datetime import datetime, timedelta, timezone
from collections import defaultdict

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.question import Question
from app.schemas.exam import ExamItem, HeatmapPoint


async def get_recent_exams(db: AsyncSession, student_id) -> list[ExamItem]:
    # 暂无独立考试表，返回空列表
    return []


async def get_heatmap(db: AsyncSession, student_id) -> list[HeatmapPoint]:
    now = datetime.now(timezone.utc)
    start = now - timedelta(days=180)
    result = await db.execute(
        select(
            func.date_trunc("day", Question.created_at).label("day"),
            func.count().label("cnt"),
        ).where(
            Question.student_id == student_id,
            Question.created_at >= start,
        ).group_by("day").order_by("day")
    )
    return [
        HeatmapPoint(date=row.day.strftime("%Y-%m-%d"), count=row.cnt)
        for row in result.all()
    ]
