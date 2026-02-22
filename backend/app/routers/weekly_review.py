"""Weekly review router."""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.weekly_review import WeeklyReviewResponse
from app.services import weekly_review_service

router = APIRouter(prefix="/weekly-review", tags=["weekly-review"])


@router.get("", response_model=WeeklyReviewResponse)
async def get_weekly_review(
    db: AsyncSession = Depends(get_db),
    user: Student = Depends(get_current_user),
):
    return await weekly_review_service.get_weekly_review(db, user)
