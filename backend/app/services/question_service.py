"""Question service."""
import uuid
from collections import defaultdict

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.question import Question
from app.schemas.question import QuestionUploadRequest, QuestionResponse, HistoryDateGroup
from app.services.mastery_service import update_mastery


async def create_question(db: AsyncSession, req: QuestionUploadRequest, student_id: uuid.UUID) -> QuestionResponse:
    q = Question(student_id=student_id, image_url=req.image_url, is_correct=req.is_correct, source=req.source)
    db.add(q)

    # 如果有正误判断，更新掌握度
    if req.is_correct is not None and q.primary_model_id:
        await update_mastery(db, student_id, "model", q.primary_model_id, req.is_correct)
    if req.is_correct is not None and q.related_kp_ids:
        for kp_id in q.related_kp_ids:
            await update_mastery(db, student_id, "kp", kp_id, req.is_correct)

    await db.commit()
    await db.refresh(q)
    return QuestionResponse(
        id=str(q.id), image_url=q.image_url, is_correct=q.is_correct,
        source=q.source, diagnosis_status=q.diagnosis_status, created_at=q.created_at,
    )


async def get_history(db: AsyncSession, student_id: uuid.UUID) -> list[HistoryDateGroup]:
    result = await db.execute(
        select(Question).where(Question.student_id == student_id).order_by(Question.created_at.desc())
    )
    rows = result.scalars().all()

    groups: dict[str, list] = defaultdict(list)
    for q in rows:
        date_key = q.created_at.strftime("%Y-%m-%d")
        groups[date_key].append(QuestionResponse(
            id=str(q.id), image_url=q.image_url, is_correct=q.is_correct,
            source=q.source, diagnosis_status=q.diagnosis_status, created_at=q.created_at,
        ))

    return [HistoryDateGroup(date=d, questions=qs) for d, qs in groups.items()]
