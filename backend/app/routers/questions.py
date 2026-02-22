"""Questions router — upload + history + detail."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.question import QuestionUploadRequest, QuestionResponse, QuestionDetailResponse, HistoryDateGroup
from app.services import question_service

router = APIRouter(prefix="/questions", tags=["questions"])


@router.post("/upload", response_model=QuestionResponse, status_code=201)
async def upload_question(
    req: QuestionUploadRequest,
    db: AsyncSession = Depends(get_db),
    user: Student = Depends(get_current_user),
):
    return await question_service.create_question(db, req, user.id)


@router.get("/history", response_model=list[HistoryDateGroup])
async def question_history(db: AsyncSession = Depends(get_db), user: Student = Depends(get_current_user)):
    return await question_service.get_history(db, user.id)


@router.get("/{question_id}", response_model=QuestionDetailResponse)
async def question_detail(
    question_id: str,
    db: AsyncSession = Depends(get_db),
    user: Student = Depends(get_current_user),
):
    result = await question_service.get_question_detail(db, question_id, user.id)
    if not result:
        raise HTTPException(404, "Question not found")
    return result
