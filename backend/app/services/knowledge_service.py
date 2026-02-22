"""Knowledge point service."""
import uuid
from collections import defaultdict

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.knowledge_point import KnowledgePoint
from app.models.student_mastery import StudentMastery
from app.schemas.knowledge import ChapterNode, SectionNode, KnowledgePointItem, KnowledgePointDetail


async def get_knowledge_tree(db: AsyncSession) -> list[ChapterNode]:
    result = await db.execute(select(KnowledgePoint).order_by(KnowledgePoint.chapter, KnowledgePoint.section))
    rows = result.scalars().all()

    chapters: dict[str, dict[str, list]] = defaultdict(lambda: defaultdict(list))
    for kp in rows:
        chapters[kp.chapter][kp.section].append(
            KnowledgePointItem(id=kp.id, name=kp.name, conclusion_level=kp.conclusion_level, description=kp.description)
        )

    return [
        ChapterNode(chapter=ch, sections=[SectionNode(section=sec, items=items) for sec, items in secs.items()])
        for ch, secs in chapters.items()
    ]


async def get_knowledge_detail(db: AsyncSession, kp_id: str, student_id: uuid.UUID) -> KnowledgePointDetail | None:
    result = await db.execute(select(KnowledgePoint).where(KnowledgePoint.id == kp_id))
    kp = result.scalar_one_or_none()
    if not kp:
        return None

    mastery_result = await db.execute(
        select(StudentMastery).where(
            StudentMastery.student_id == student_id,
            StudentMastery.target_type == "kp",
            StudentMastery.target_id == kp_id,
        )
    )
    m = mastery_result.scalar_one_or_none()

    return KnowledgePointDetail(
        id=kp.id, name=kp.name, conclusion_level=kp.conclusion_level,
        description=kp.description, chapter=kp.chapter, section=kp.section,
        related_model_ids=kp.related_model_ids,
        mastery_level=m.current_level if m else None,
        mastery_value=getattr(m, "mastery_value", None) if m else None,
        error_count=m.error_count if m else 0,
        correct_count=m.correct_count if m else 0,
    )
