"""Flashcard service — SM-2 based review."""
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.student_mastery import StudentMastery
from app.models.knowledge_point import KnowledgePoint
from app.models.model import Model
from app.schemas.flashcard import FlashcardItem


async def get_flashcards(db: AsyncSession, student_id) -> list[FlashcardItem]:
    """返回待复习卡片列表，按 mastery_value 升序（薄弱优先）。"""
    now = datetime.now(timezone.utc)
    result = await db.execute(
        select(StudentMastery).where(
            StudentMastery.student_id == student_id,
        ).order_by(StudentMastery.mastery_value.asc()).limit(50)
    )
    rows = result.scalars().all()

    # 批量获取名称
    kp_ids = [r.target_id for r in rows if r.target_type == "kp"]
    model_ids = [r.target_id for r in rows if r.target_type == "model"]
    name_map: dict[str, str] = {}

    if kp_ids:
        kps = await db.execute(select(KnowledgePoint.id, KnowledgePoint.name).where(KnowledgePoint.id.in_(kp_ids)))
        name_map.update({r.id: r.name for r in kps.all()})
    if model_ids:
        ms = await db.execute(select(Model.id, Model.name).where(Model.id.in_(model_ids)))
        name_map.update({r.id: r.name for r in ms.all()})

    return [
        FlashcardItem(
            id=str(r.id),
            target_type=r.target_type,
            target_id=r.target_id,
            target_name=name_map.get(r.target_id, r.target_id),
            mastery_value=r.mastery_value,
            due=r.next_retest_date is not None and r.next_retest_date <= now,
        )
        for r in rows
    ]


async def submit_review(db: AsyncSession, mastery_id: str, student_id, quality: int) -> bool:
    """提交复习结果，更新 mastery_value。quality: 0-5 SM-2 评分。"""
    result = await db.execute(
        select(StudentMastery).where(
            StudentMastery.id == mastery_id,
            StudentMastery.student_id == student_id,
        )
    )
    m = result.scalar_one_or_none()
    if not m:
        return False

    # 简化 SM-2: quality >= 3 加分，否则扣分
    delta = (quality - 2.5) * 10
    m.mastery_value = max(0, min(100, m.mastery_value + delta))
    await db.commit()
    return True
