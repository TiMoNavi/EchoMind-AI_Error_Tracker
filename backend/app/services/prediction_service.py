"""Prediction service."""
from datetime import datetime, timedelta, timezone

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.student import Student
from app.models.student_mastery import StudentMastery
from app.models.question import Question
from app.models.model import Model
from app.schemas.prediction import PredictionResponse, TrendPoint, PriorityModel, ScorePathRow


async def get_prediction(db: AsyncSession, user: Student) -> PredictionResponse:
    # 薄弱模型（level 最低的前 5 个）
    result = await db.execute(
        select(StudentMastery, Model.name).join(
            Model, StudentMastery.target_id == Model.id
        ).where(
            StudentMastery.student_id == user.id,
            StudentMastery.target_type == "model",
        ).order_by(StudentMastery.current_level).limit(5)
    )
    rows = result.all()
    priority_models = [
        PriorityModel(
            model_id=m.target_id, model_name=name,
            current_level=m.current_level, error_count=m.error_count,
        )
        for m, name in rows
    ]

    # 分数路径：四维能力
    score_path = [
        ScorePathRow(label="公式记忆", current=user.formula_memory_rate, target=0.9),
        ScorePathRow(label="模型识别", current=user.model_identify_rate, target=0.85),
        ScorePathRow(label="计算准确", current=user.calculation_accuracy, target=0.95),
        ScorePathRow(label="审题准确", current=user.reading_accuracy, target=0.9),
    ]

    # 趋势数据：近 30 天每日正确率折算 150 分
    thirty_days_ago = datetime.now(timezone.utc) - timedelta(days=30)
    day_col = func.date_trunc("day", Question.created_at)
    trend_result = await db.execute(
        select(
            day_col.label("day"),
            func.count().label("total"),
            func.count().filter(Question.is_correct == True).label("correct"),
        ).where(
            Question.student_id == user.id,
            Question.created_at >= thirty_days_ago,
        ).group_by(day_col).order_by(day_col)
    )
    trend_data = [
        TrendPoint(
            date=row.day.strftime("%Y-%m-%d"),
            score=round(row.correct / row.total * 150, 1) if row.total > 0 else 0,
        )
        for row in trend_result.all()
    ]

    return PredictionResponse(
        predicted_score=user.predicted_score,
        target_score=getattr(user, 'target_score', None) or 90.0,
        trend_data=trend_data,
        priority_models=priority_models,
        score_path=score_path,
    )
