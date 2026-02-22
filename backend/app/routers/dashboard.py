"""Dashboard router."""
from fastapi import APIRouter, Depends
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.question import Question
from app.models.student import Student
from app.models.student_mastery import StudentMastery
from app.schemas.dashboard import DashboardResponse

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("", response_model=DashboardResponse)
async def dashboard(db: AsyncSession = Depends(get_db), user: Student = Depends(get_current_user)):
    # 题目总数
    total = (await db.execute(
        select(func.count()).select_from(Question).where(Question.student_id == user.id)
    )).scalar() or 0

    # 错题数
    errors = (await db.execute(
        select(func.count()).select_from(Question).where(Question.student_id == user.id, Question.is_correct == False)
    )).scalar() or 0

    # 掌握度统计
    mastery_rows = (await db.execute(
        select(StudentMastery.current_level).where(StudentMastery.student_id == user.id)
    )).scalars().all()

    mastery_count = sum(1 for lv in mastery_rows if lv >= 3)
    weak_count = sum(1 for lv in mastery_rows if lv <= 1)

    return DashboardResponse(
        total_questions=total, error_count=errors,
        mastery_count=mastery_count, weak_count=weak_count,
        predicted_score=user.predicted_score,
        formula_memory_rate=user.formula_memory_rate,
        model_identify_rate=user.model_identify_rate,
        calculation_accuracy=user.calculation_accuracy,
        reading_accuracy=user.reading_accuracy,
    )
