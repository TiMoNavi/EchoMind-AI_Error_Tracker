"""Questions router — upload + history."""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.question import QuestionUploadRequest, QuestionResponse, HistoryDateGroup
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
