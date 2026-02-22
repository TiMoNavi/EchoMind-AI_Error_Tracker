"""Knowledge point router — tree + detail."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.knowledge import ChapterNode, KnowledgePointDetail
from app.services import knowledge_service

router = APIRouter(prefix="/knowledge", tags=["knowledge"])


@router.get("/tree", response_model=list[ChapterNode])
async def knowledge_tree(db: AsyncSession = Depends(get_db)):
    return await knowledge_service.get_knowledge_tree(db)


@router.get("/{kp_id}", response_model=KnowledgePointDetail)
async def knowledge_detail(kp_id: str, db: AsyncSession = Depends(get_db), user: Student = Depends(get_current_user)):
    result = await knowledge_service.get_knowledge_detail(db, kp_id, user.id)
    if not result:
        raise HTTPException(status_code=404, detail="Knowledge point not found")
    return result
