"""Flashcards router."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.flashcard import FlashcardItem, FlashcardReviewRequest
from app.services import flashcard_service

router = APIRouter(prefix="/flashcards", tags=["flashcards"])


@router.get("", response_model=list[FlashcardItem])
async def list_flashcards(db: AsyncSession = Depends(get_db), user: Student = Depends(get_current_user)):
    return await flashcard_service.get_flashcards(db, user.id)


@router.post("/{mastery_id}/review")
async def review_flashcard(
    mastery_id: str,
    req: FlashcardReviewRequest,
    db: AsyncSession = Depends(get_db),
    user: Student = Depends(get_current_user),
):
    ok = await flashcard_service.submit_review(db, mastery_id, user.id, req.quality)
    if not ok:
        raise HTTPException(404, "Flashcard not found")
    return {"ok": True}
