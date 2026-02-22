"""Recommendations router."""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.recommendation import RecommendationItem
from app.services import recommendation_service

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.get("", response_model=list[RecommendationItem])
async def recommendations(db: AsyncSession = Depends(get_db), user: Student = Depends(get_current_user)):
    return await recommendation_service.get_recommendations(db, user.id)
