"""Model service."""
import uuid
from collections import defaultdict

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.model import Model
from app.models.student_mastery import StudentMastery
from app.schemas.model import ModelChapterNode, ModelSectionNode, ModelItem, ModelDetail


async def get_model_tree(db: AsyncSession) -> list[ModelChapterNode]:
    result = await db.execute(select(Model).order_by(Model.chapter, Model.section))
    rows = result.scalars().all()

    chapters: dict[str, dict[str, list]] = defaultdict(lambda: defaultdict(list))
    for m in rows:
        chapters[m.chapter][m.section].append(
            ModelItem(id=m.id, name=m.name, description=m.description)
        )

    return [
        ModelChapterNode(chapter=ch, sections=[ModelSectionNode(section=sec, items=items) for sec, items in secs.items()])
        for ch, secs in chapters.items()
    ]


async def get_model_detail(db: AsyncSession, model_id: str, student_id: uuid.UUID) -> ModelDetail | None:
    result = await db.execute(select(Model).where(Model.id == model_id))
    m = result.scalar_one_or_none()
    if not m:
        return None

    mastery_result = await db.execute(
        select(StudentMastery).where(
            StudentMastery.student_id == student_id,
            StudentMastery.target_type == "model",
            StudentMastery.target_id == model_id,
        )
    )
    ms = mastery_result.scalar_one_or_none()

    return ModelDetail(
        id=m.id, name=m.name, description=m.description,
        chapter=m.chapter, section=m.section,
        prerequisite_kp_ids=m.prerequisite_kp_ids,
        confusion_group_ids=m.confusion_group_ids,
        mastery_level=ms.current_level if ms else None,
        mastery_value=getattr(ms, "mastery_value", None) if ms else None,
        error_count=ms.error_count if ms else 0,
        correct_count=ms.correct_count if ms else 0,
    )
