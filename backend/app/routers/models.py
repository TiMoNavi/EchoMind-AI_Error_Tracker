"""Model router — tree + detail."""
from collections import defaultdict

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.model import Model
from app.models.student import Student
from app.models.student_mastery import StudentMastery
from app.schemas.model import ModelChapterNode, ModelSectionNode, ModelItem, ModelDetail

router = APIRouter(prefix="/models", tags=["models"])


@router.get("/tree", response_model=list[ModelChapterNode])
async def model_tree(db: AsyncSession = Depends(get_db)):
    """三级树：章 → 节 → 模型（无需认证）"""
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


@router.get("/{model_id}", response_model=ModelDetail)
async def model_detail(model_id: str, db: AsyncSession = Depends(get_db), user: Student = Depends(get_current_user)):
    """模型详情 + 当前用户掌握度（需认证）"""
    result = await db.execute(select(Model).where(Model.id == model_id))
    m = result.scalar_one_or_none()
    if not m:
        raise HTTPException(status_code=404, detail="Model not found")

    mastery_result = await db.execute(
        select(StudentMastery.current_level).where(
            StudentMastery.student_id == user.id,
            StudentMastery.target_type == "model",
            StudentMastery.target_id == model_id,
        )
    )
    level = mastery_result.scalar_one_or_none()

    return ModelDetail(
        id=m.id, name=m.name, description=m.description,
        chapter=m.chapter, section=m.section,
        prerequisite_kp_ids=m.prerequisite_kp_ids,
        confusion_group_ids=m.confusion_group_ids,
        mastery_level=level,
    )
