"""Knowledge point router — tree + detail."""
from collections import defaultdict

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.knowledge_point import KnowledgePoint
from app.models.student import Student
from app.models.student_mastery import StudentMastery
from app.schemas.knowledge import ChapterNode, SectionNode, KnowledgePointItem, KnowledgePointDetail

router = APIRouter(prefix="/knowledge", tags=["knowledge"])


@router.get("/tree", response_model=list[ChapterNode])
async def knowledge_tree(db: AsyncSession = Depends(get_db)):
    """三级树：章 → 节 → 知识点（无需认证）"""
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


@router.get("/{kp_id}", response_model=KnowledgePointDetail)
async def knowledge_detail(kp_id: str, db: AsyncSession = Depends(get_db), user: Student = Depends(get_current_user)):
    """知识点详情 + 当前用户掌握度（需认证）"""
    result = await db.execute(select(KnowledgePoint).where(KnowledgePoint.id == kp_id))
    kp = result.scalar_one_or_none()
    if not kp:
        raise HTTPException(status_code=404, detail="Knowledge point not found")

    mastery_result = await db.execute(
        select(StudentMastery.current_level).where(
            StudentMastery.student_id == user.id,
            StudentMastery.target_type == "kp",
            StudentMastery.target_id == kp_id,
        )
    )
    level = mastery_result.scalar_one_or_none()

    return KnowledgePointDetail(
        id=kp.id, name=kp.name, conclusion_level=kp.conclusion_level,
        description=kp.description, chapter=kp.chapter, section=kp.section,
        related_model_ids=kp.related_model_ids, mastery_level=level,
    )
