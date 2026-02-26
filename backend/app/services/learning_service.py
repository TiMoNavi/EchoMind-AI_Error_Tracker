"""知识点学习业务逻辑 — Knowledge Learning Service

依赖：
- LearningSessionModel / LearningMessageModel (ORM)
- LLMClient + create_llm_client (app/core/llm_client.py, app/core/llm_factory.py)
- LearningPromptBuilder (app/services/learning_prompt_builder.py)
"""
from __future__ import annotations

import logging
import re
import uuid
from datetime import datetime, timezone

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.student import Student
from app.models.student_mastery import StudentMastery
from app.models.knowledge_point import KnowledgePoint
from app.models.learning_session import LearningSessionModel
from app.models.learning_message import LearningMessageModel
from app.services.learning_prompt_builder import LearningPromptBuilder
from app.core.llm_factory import create_llm_client

logger = logging.getLogger(__name__)

_prompt_builder = LearningPromptBuilder()

MAX_STEPS = 5

# Step 标记正则
_STEP_ADVANCE_RE = re.compile(r"\[STEP_ADVANCE:(\d+)\]")
_STEP_COMPLETE_RE = re.compile(r"\[STEP_COMPLETE:(\d+)\]")


# ---------------------------------------------------------------------------
# LLM 调用封装
# ---------------------------------------------------------------------------

async def _call_llm(messages: list[dict]) -> str:
    """调用 LLM 并返回文本。超时/异常时返回友好提示。"""
    try:
        llm = create_llm_client()
        response = await llm.chat(
            messages=messages,
            temperature=0.7,
            max_tokens=1024,
        )
        return response["content"]
    except TimeoutError:
        logger.warning("LLM 调用超时")
        return "抱歉，AI 助手暂时响应较慢，请稍后再试。"
    except Exception as e:
        logger.error("LLM 调用异常: %s", e, exc_info=True)
        return "抱歉，AI 助手遇到了一点问题。请稍后再试。"


# ---------------------------------------------------------------------------
# 内部辅助
# ---------------------------------------------------------------------------

async def _load_knowledge_point(kp_id: str, db: AsyncSession) -> KnowledgePoint:
    """加载知识点，不存在则 404。"""
    result = await db.execute(
        select(KnowledgePoint).where(KnowledgePoint.id == kp_id)
    )
    kp = result.scalar_one_or_none()
    if kp is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="知识点不存在",
        )
    return kp


async def _load_mastery_for_kp(
    student_id: uuid.UUID, kp_id: str, db: AsyncSession
) -> StudentMastery | None:
    """加载学生对某知识点的掌握度记录。"""
    result = await db.execute(
        select(StudentMastery).where(
            StudentMastery.student_id == student_id,
            StudentMastery.target_type == "kp",
            StudentMastery.target_id == kp_id,
        )
    )
    return result.scalar_one_or_none()


def _parse_step_markers(ai_text: str, current_step: int) -> tuple[int, bool]:
    """解析 AI 回复中的步骤标记。

    Returns:
        (new_step, is_complete): 新步骤编号 + 是否学习完成
    """
    # 检查完成标记
    complete_match = _STEP_COMPLETE_RE.search(ai_text)
    if complete_match:
        return current_step, True

    # 检查推进标记
    advance_match = _STEP_ADVANCE_RE.search(ai_text)
    if advance_match:
        next_step = int(advance_match.group(1))
        if 1 <= next_step <= MAX_STEPS:
            return next_step, False

    return current_step, False


def _strip_markers(text: str) -> str:
    """移除 AI 回复中的步骤标记，返回干净文本。"""
    text = _STEP_ADVANCE_RE.sub("", text)
    text = _STEP_COMPLETE_RE.sub("", text)
    return text.strip()


async def _session_to_dict(session: LearningSessionModel, db: AsyncSession) -> dict:
    """将会话 ORM 对象转为 dict（含消息历史）。"""
    msg_result = await db.execute(
        select(LearningMessageModel)
        .where(LearningMessageModel.session_id == session.id)
        .order_by(LearningMessageModel.created_at)
    )
    messages = msg_result.scalars().all()

    return {
        "session_id": str(session.id),
        "status": session.status,
        "knowledge_point_id": session.knowledge_point_id,
        "knowledge_point_name": "",  # 后续可从 KP 表补充
        "current_step": session.current_step,
        "max_steps": session.max_steps,
        "source": session.source,
        "mastery_before": session.mastery_before,
        "mastery_after": session.mastery_after,
        "level_before": session.level_before,
        "level_after": session.level_after,
        "messages": [
            {
                "id": str(m.id),
                "role": m.role,
                "content": m.content,
                "step": m.step,
                "created_at": m.created_at.isoformat(),
            }
            for m in messages
        ],
        "created_at": session.created_at.isoformat() if session.created_at else None,
        "updated_at": session.updated_at.isoformat() if session.updated_at else None,
    }


# ---------------------------------------------------------------------------
# 公开 API：start_session
# ---------------------------------------------------------------------------

async def start_session(
    student_id: uuid.UUID,
    knowledge_point_id: str,
    source: str,
    db: AsyncSession,
) -> dict:
    """创建学习会话 + 调 LLM 生成开场白。"""
    # 1. 校验知识点存在
    kp = await _load_knowledge_point(knowledge_point_id, db)

    # 2. 检查是否已有活跃会话
    existing = await db.execute(
        select(LearningSessionModel).where(
            LearningSessionModel.student_id == student_id,
            LearningSessionModel.knowledge_point_id == knowledge_point_id,
            LearningSessionModel.status == "active",
        )
    )
    active_session = existing.scalar_one_or_none()
    if active_session:
        return await _session_to_dict(active_session, db)

    # 3. 加载掌握度
    mastery = await _load_mastery_for_kp(student_id, knowledge_point_id, db)
    mastery_value = mastery.mastery_value if mastery else 0.0
    mastery_level = _prompt_builder.mastery_to_level(mastery_value)

    # 4. 判定起始 Step
    if source == "diagnosis_redirect" and mastery_value >= 20:
        start_step = 4  # 有基础，直接检测
    elif mastery_value >= 40:
        start_step = 4
    else:
        start_step = 1  # 完整流程

    # 5. 拼接 system prompt
    system_prompt = _prompt_builder.build_system_prompt(
        kp_name=kp.name,
        mastery_level=mastery_level,
        mastery_value=mastery_value,
        source=source,
        current_step=start_step,
        definition=kp.description or "",
    )

    # 6. 调用 LLM 生成开场白
    opening_messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": "请开始帮我学习这个知识点。"},
    ]
    ai_reply = await _call_llm(opening_messages)
    clean_reply = _strip_markers(ai_reply)

    # 7. 持久化会话 + 首条消息
    session_id = uuid.uuid4()
    now = datetime.now(timezone.utc)

    session = LearningSessionModel(
        id=session_id,
        student_id=student_id,
        knowledge_point_id=knowledge_point_id,
        status="active",
        source=source,
        current_step=start_step,
        max_steps=MAX_STEPS,
        mastery_before=mastery_value,
        level_before=mastery_level,
        system_prompt=system_prompt,
        created_at=now,
        updated_at=now,
    )
    db.add(session)
    await db.flush()

    msg = LearningMessageModel(
        session_id=session_id,
        role="assistant",
        content=clean_reply,
        step=start_step,
        created_at=now,
    )
    db.add(msg)
    await db.commit()

    return {
        "session_id": str(session_id),
        "status": "active",
        "knowledge_point_id": knowledge_point_id,
        "knowledge_point_name": kp.name,
        "current_step": start_step,
        "max_steps": MAX_STEPS,
        "mastery_level": mastery_level,
        "mastery_value": mastery_value,
        "messages": [
            {
                "id": str(msg.id),
                "role": "assistant",
                "content": clean_reply,
                "step": start_step,
                "created_at": now.isoformat(),
            }
        ],
    }


# ---------------------------------------------------------------------------
# 公开 API：chat
# ---------------------------------------------------------------------------

async def chat(
    session_id: uuid.UUID,
    content: str,
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict:
    """发送消息 + 调 LLM + 解析步骤标记。"""
    # 1. 校验 session 归属 + 状态
    result = await db.execute(
        select(LearningSessionModel).where(
            LearningSessionModel.id == session_id,
            LearningSessionModel.student_id == student_id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=404, detail="会话不存在")
    if session.status != "active":
        raise HTTPException(status_code=400, detail="会话已结束")

    # 2. 加载历史消息，组装 LLM messages
    msg_result = await db.execute(
        select(LearningMessageModel)
        .where(LearningMessageModel.session_id == session_id)
        .order_by(LearningMessageModel.created_at)
    )
    history = msg_result.scalars().all()
    llm_messages = [{"role": "system", "content": session.system_prompt}]
    for m in history:
        llm_messages.append({"role": m.role, "content": m.content})
    llm_messages.append({"role": "user", "content": content})

    # 3. 持久化用户消息
    now = datetime.now(timezone.utc)
    user_msg = LearningMessageModel(
        session_id=session_id,
        role="user",
        content=content,
        step=session.current_step,
        created_at=now,
    )
    db.add(user_msg)

    # 4. 调用 LLM
    ai_reply = await _call_llm(llm_messages)

    # 5. 解析步骤标记
    new_step, is_complete = _parse_step_markers(ai_reply, session.current_step)
    clean_reply = _strip_markers(ai_reply)

    new_status = "completed" if is_complete else "active"

    # 6. 持久化 AI 消息 + 更新会话状态
    ai_msg = LearningMessageModel(
        session_id=session_id,
        role="assistant",
        content=clean_reply,
        step=new_step,
        created_at=now,
    )
    db.add(ai_msg)

    session.current_step = new_step
    session.status = new_status
    session.updated_at = now

    # 7. 如果学习完成，更新掌握度
    if is_complete:
        mastery = await _load_mastery_for_kp(student_id, session.knowledge_point_id, db)
        old_value = mastery.mastery_value if mastery else 0.0
        # 简化掌握度更新：完成学习 → 提升到 L3 区间起始值(40)或更高
        new_value = max(old_value + 15, 40.0)
        new_value = min(new_value, 100.0)
        new_level = _prompt_builder.mastery_to_level(new_value)

        if mastery:
            mastery.mastery_value = new_value
            mastery.current_level = int(new_level[1])  # "L3" → 3
        session.mastery_after = new_value
        session.level_after = new_level

    await db.commit()

    return {
        "message": {
            "id": str(ai_msg.id),
            "role": "assistant",
            "content": clean_reply,
            "step": new_step,
            "created_at": now.isoformat(),
        },
        "session": {
            "session_id": str(session_id),
            "status": new_status,
            "current_step": new_step,
        },
    }


# ---------------------------------------------------------------------------
# 公开 API：get_session
# ---------------------------------------------------------------------------

async def get_session(
    session_id: uuid.UUID,
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict:
    """获取会话详情（含完整消息历史）。"""
    result = await db.execute(
        select(LearningSessionModel).where(
            LearningSessionModel.id == session_id,
            LearningSessionModel.student_id == student_id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=404, detail="会话不存在")
    return await _session_to_dict(session, db)


# ---------------------------------------------------------------------------
# 公开 API：get_active_session
# ---------------------------------------------------------------------------

async def get_active_session(
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict | None:
    """获取当前活跃学习会话。无活跃会话时返回 None。"""
    result = await db.execute(
        select(LearningSessionModel).where(
            LearningSessionModel.student_id == student_id,
            LearningSessionModel.status == "active",
        ).order_by(LearningSessionModel.updated_at.desc()).limit(1)
    )
    session = result.scalar_one_or_none()
    if session is None:
        return None
    return await _session_to_dict(session, db)


# ---------------------------------------------------------------------------
# 公开 API：complete_session
# ---------------------------------------------------------------------------

async def complete_session(
    session_id: uuid.UUID,
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict:
    """手动结束学习会话（学生主动退出）。

    将会话状态设为 expired，不更新掌握度。
    """
    result = await db.execute(
        select(LearningSessionModel).where(
            LearningSessionModel.id == session_id,
            LearningSessionModel.student_id == student_id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=404, detail="会话不存在")
    if session.status != "active":
        raise HTTPException(status_code=400, detail="会话已结束")

    session.status = "expired"
    session.updated_at = datetime.now(timezone.utc)
    await db.commit()

    return {
        "session_id": str(session.id),
        "status": "expired",
        "message": "学习会话已手动结束",
    }


# ---------------------------------------------------------------------------
# 兼容旧前端：get_session_compat
# ---------------------------------------------------------------------------

async def get_session_compat(
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict:
    """兼容旧前端 GET /session 的空结构返回。

    有活跃会话时返回简化结构，无活跃会话时返回空结构。
    """
    active = await get_active_session(student_id, db)
    if active is None:
        return {
            "knowledge_point_id": "",
            "knowledge_point_name": "",
            "current_step": 0,
            "dialogues": [],
        }
    return {
        "knowledge_point_id": active["knowledge_point_id"],
        "knowledge_point_name": active.get("knowledge_point_name", ""),
        "current_step": active["current_step"],
        "dialogues": [
            {"role": m["role"], "content": m["content"]}
            for m in active.get("messages", [])
        ],
    }
