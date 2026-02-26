"""AI 诊断路由 — T019 by claude-4

5 个端点，全部 JWT 鉴权。

依赖：
- claude-3: DiagnosisSessionModel / DiagnosisMessageModel (ORM) + Schema 更新
- claude-2: LLMClient (间接，通过 diagnosis_service)
"""
from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.diagnosis import (
    DiagnosisChatRequest,
    DiagnosisCompleteRequest,
    DiagnosisStartRequest,
)
from app.services import diagnosis_service

router = APIRouter(prefix="/diagnosis", tags=["AI诊断"])


# ---------------------------------------------------------------------------
# POST /diagnosis/start — 创建诊断会话
# ---------------------------------------------------------------------------

@router.post("/start", status_code=status.HTTP_201_CREATED)
async def start_diagnosis(
    body: DiagnosisStartRequest,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """创建新的诊断会话，绑定到一道错题，并生成 AI 开场白。"""
    return await diagnosis_service.start_session(
        student_id=user.id,
        question_id=body.question_id,
        db=db,
    )


# ---------------------------------------------------------------------------
# POST /diagnosis/chat — 发送消息并获取 AI 回复
# ---------------------------------------------------------------------------

@router.post("/chat")
async def chat_diagnosis(
    body: DiagnosisChatRequest,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """学生发送消息，获取 AI 诊断回复。最后一轮会包含诊断结论。"""
    return await diagnosis_service.chat(
        session_id=body.session_id,
        content=body.content,
        student_id=user.id,
        db=db,
    )


# ---------------------------------------------------------------------------
# GET /diagnosis/session — 获取当前活跃会话（无参路由优先注册）
# ---------------------------------------------------------------------------

@router.get("/session")
async def get_active_session(
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取当前用户最近的活跃会话（兼容现有前端 aiDiagnosisProvider）。

    无活跃会话时返回 null。
    """
    return await diagnosis_service.get_active_session(
        student_id=user.id,
        db=db,
    )


# ---------------------------------------------------------------------------
# GET /diagnosis/session/{session_id} — 获取会话详情
# ---------------------------------------------------------------------------

@router.get("/session/{session_id}")
async def get_session(
    session_id: uuid.UUID,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取指定会话详情，含完整消息历史。"""
    return await diagnosis_service.get_session(
        session_id=session_id,
        student_id=user.id,
        db=db,
    )


# ---------------------------------------------------------------------------
# POST /diagnosis/complete — 手动结束会话
# ---------------------------------------------------------------------------

@router.post("/complete")
async def complete_diagnosis(
    body: DiagnosisCompleteRequest,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """手动结束诊断会话（学生主动退出时调用）。"""
    return await diagnosis_service.complete_session(
        session_id=body.session_id,
        student_id=user.id,
        db=db,
    )
