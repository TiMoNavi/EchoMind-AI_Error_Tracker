"""Model training session router — 6 endpoints."""
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.training import (
    TrainingStartRequest,
    TrainingInteractRequest,
    TrainingNextStepRequest,
    TrainingCompleteRequest,
    TrainingSession,
)
from app.services import training_service

router = APIRouter(prefix="/models/training", tags=["模型训练"])


@router.post("/start", status_code=status.HTTP_201_CREATED)
async def start_session(
    req: TrainingStartRequest,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """创建训练会话，路由入口步骤，AI 生成开场白。"""
    return await training_service.start_session(
        student_id=user.id,
        model_id=req.model_id,
        source=req.source,
        db=db,
        question_id=req.question_id,
        diagnosis_result=req.diagnosis_result,
    )


@router.post("/interact")
async def interact(
    req: TrainingInteractRequest,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """发送消息并获取 AI 回复 + 步骤判定。"""
    return await training_service.interact(
        session_id=req.session_id,
        content=req.content,
        student_id=user.id,
        db=db,
    )


@router.post("/next-step")
async def next_step(
    req: TrainingNextStepRequest,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """显式推进到下一步骤，切换 prompt 并生成新步骤开场白。"""
    return await training_service.next_step(
        session_id=req.session_id,
        student_id=user.id,
        db=db,
    )


@router.get("/session/{session_id}")
async def get_session_by_id(
    session_id: str,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取指定训练会话详情（含消息历史 + 步骤结果）。"""
    return await training_service.get_session(
        session_id=session_id,
        student_id=user.id,
        db=db,
    )


@router.get("/session", response_model=TrainingSession)
async def get_active_session(
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取当前活跃训练会话（兼容旧前端）。"""
    active = await training_service.get_active_session(
        student_id=user.id,
        db=db,
    )
    if active is None:
        return {
            "model_id": "",
            "model_name": "",
            "current_step": 0,
            "dialogues": [],
        }
    return {
        "model_id": active.get("model_id", ""),
        "model_name": active.get("model_name", ""),
        "current_step": active.get("current_step", 0),
        "dialogues": [
            {"role": m["role"], "content": m["content"]}
            for m in active.get("messages", [])
        ],
    }


@router.post("/complete")
async def complete_session(
    req: TrainingCompleteRequest,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """手动完成训练会话。"""
    return await training_service.complete_session(
        session_id=req.session_id,
        student_id=user.id,
        db=db,
    )
