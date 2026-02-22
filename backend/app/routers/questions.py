"""Questions router — upload + history."""
from collections import defaultdict

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.question import Question
from app.models.student import Student
from app.schemas.question import QuestionUploadRequest, QuestionResponse, HistoryDateGroup

router = APIRouter(prefix="/questions", tags=["questions"])


@router.post("/upload", response_model=QuestionResponse, status_code=201)
async def upload_question(
    req: QuestionUploadRequest,
    db: AsyncSession = Depends(get_db),
    user: Student = Depends(get_current_user),
):
    q = Question(student_id=user.id, image_url=req.image_url, is_correct=req.is_correct, source=req.source)
    db.add(q)
    await db.commit()
    await db.refresh(q)
    return QuestionResponse(
        id=str(q.id), image_url=q.image_url, is_correct=q.is_correct,
        source=q.source, diagnosis_status=q.diagnosis_status, created_at=q.created_at,
    )


@router.get("/history", response_model=list[HistoryDateGroup])
async def question_history(db: AsyncSession = Depends(get_db), user: Student = Depends(get_current_user)):
    """上传历史，按日期分组"""
    result = await db.execute(
        select(Question).where(Question.student_id == user.id).order_by(Question.created_at.desc())
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
