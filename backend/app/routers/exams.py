"""Exams router."""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.exam import ExamItem, HeatmapPoint
from app.services import exam_service

router = APIRouter(prefix="/exams", tags=["exams"])


@router.get("/recent", response_model=list[ExamItem])
async def recent_exams(db: AsyncSession = Depends(get_db), user: Student = Depends(get_current_user)):
    return await exam_service.get_recent_exams(db, user.id)


@router.get("/heatmap", response_model=list[HeatmapPoint])
async def heatmap(db: AsyncSession = Depends(get_db), user: Student = Depends(get_current_user)):
    return await exam_service.get_heatmap(db, user.id)
