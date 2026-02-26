"""Knowledge learning session router — 6 endpoints."""
import uuid

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.learning import (
    LearningStartRequest,
    LearningChatRequest,
    LearningCompleteRequest,
    LearningSession,
)
from app.services import learning_service

router = APIRouter(prefix="/knowledge/learning", tags=["知识学习"])


@router.post("/start", status_code=status.HTTP_201_CREATED)
async def start_session(
    req: LearningStartRequest,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """创建学习会话，绑定知识点，AI 生成开场白。"""
    return await learning_service.start_session(
        student_id=user.id,
        knowledge_point_id=req.knowledge_point_id,
        source=req.source,
        db=db,
    )


@router.post("/chat")
async def chat(
    req: LearningChatRequest,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """发送消息并获取 AI 回复。"""
    return await learning_service.chat(
        session_id=uuid.UUID(req.session_id),
        content=req.content,
        student_id=user.id,
        db=db,
    )


@router.get("/session/{session_id}")
async def get_session_by_id(
    session_id: str,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取指定会话详情（含消息历史）。"""
    return await learning_service.get_session(
        session_id=uuid.UUID(session_id),
        student_id=user.id,
        db=db,
    )


@router.get("/session", response_model=LearningSession)
async def get_active_session(
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取当前活跃学习会话（兼容旧前端）。"""
    return await learning_service.get_session_compat(
        student_id=user.id,
        db=db,
    )


@router.post("/complete")
async def complete_session(
    req: LearningCompleteRequest,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """手动结束学习会话。"""
    return await learning_service.complete_session(
        session_id=uuid.UUID(req.session_id),
        student_id=user.id,
        db=db,
    )
