"""Recommendation service."""
import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.knowledge_point import KnowledgePoint
from app.models.model import Model
from app.models.student_mastery import StudentMastery
from app.schemas.recommendation import RecommendationItem


async def get_recommendations(db: AsyncSession, student_id: uuid.UUID) -> list[RecommendationItem]:
    result = await db.execute(
        select(StudentMastery)
        .where(StudentMastery.student_id == student_id)
        .order_by(StudentMastery.current_level.asc())
        .limit(20)
    )
    masteries = result.scalars().all()

    kp_ids = [m.target_id for m in masteries if m.target_type == "kp"]
    model_ids = [m.target_id for m in masteries if m.target_type == "model"]

    names: dict[str, str] = {}
    if kp_ids:
        rows = await db.execute(select(KnowledgePoint.id, KnowledgePoint.name).where(KnowledgePoint.id.in_(kp_ids)))
        names.update({r.id: r.name for r in rows})
    if model_ids:
        rows = await db.execute(select(Model.id, Model.name).where(Model.id.in_(model_ids)))
        names.update({r.id: r.name for r in rows})

    return [
        RecommendationItem(
            target_type=m.target_type, target_id=m.target_id,
            target_name=names.get(m.target_id, ""),
            current_level=m.current_level, error_count=m.error_count,
            is_unstable=m.is_unstable,
        )
        for m in masteries
    ]
