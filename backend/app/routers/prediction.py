"""Prediction router."""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.prediction import PredictionResponse
from app.services import prediction_service

router = APIRouter(prefix="/prediction", tags=["prediction"])


@router.get("/score", response_model=PredictionResponse)
async def get_prediction(
    db: AsyncSession = Depends(get_db),
    user: Student = Depends(get_current_user),
):
    return await prediction_service.get_prediction(db, user)
