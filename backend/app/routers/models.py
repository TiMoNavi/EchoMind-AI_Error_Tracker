"""Model router — tree + detail."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.model import ModelChapterNode, ModelDetail
from app.services import model_service

router = APIRouter(prefix="/models", tags=["models"])


@router.get("/tree", response_model=list[ModelChapterNode])
async def model_tree(db: AsyncSession = Depends(get_db)):
    return await model_service.get_model_tree(db)


@router.get("/{model_id}", response_model=ModelDetail)
async def model_detail(model_id: str, db: AsyncSession = Depends(get_db), user: Student = Depends(get_current_user)):
    result = await model_service.get_model_detail(db, model_id, user.id)
    if not result:
        raise HTTPException(status_code=404, detail="Model not found")
    return result
