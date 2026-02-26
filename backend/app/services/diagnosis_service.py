"""AI 诊断业务逻辑 — T019 by claude-4

依赖：
- claude-3: DiagnosisSessionModel / DiagnosisMessageModel (ORM)
- claude-2: LLMClient + create_llm_client (app/core/llm_client.py, app/core/llm_factory.py)
"""
from __future__ import annotations

import json
import logging
import re
import uuid
from datetime import datetime, timezone

from fastapi import HTTPException, status
from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.question import Question
from app.models.student import Student
from app.models.student_mastery import StudentMastery
from app.models.diagnosis_session import DiagnosisSessionModel
from app.models.diagnosis_message import DiagnosisMessageModel
from app.services.prompt_builder import DiagnosisPromptBuilder, MAX_ROUNDS
from app.core.llm_factory import create_llm_client

logger = logging.getLogger(__name__)

_prompt_builder = DiagnosisPromptBuilder()


# ---------------------------------------------------------------------------
# LLM 调用封装（含降级策略）
# ---------------------------------------------------------------------------

async def _call_llm(messages: list[dict]) -> str:
    """调用 LLM 并返回文本内容。超时/限流/格式错误时返回友好提示。"""
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
        return "抱歉，AI 助手暂时响应较慢，请稍后再试。你可以先想想这道题的解题思路。"
    except Exception as e:
        logger.error("LLM 调用异常: %s", e, exc_info=True)
        return "抱歉，AI 助手遇到了一点问题。请稍后再试，或者先尝试自己分析一下这道题。"


# ---------------------------------------------------------------------------
# 5W JSON 解析
# ---------------------------------------------------------------------------

_JSON_BLOCK_RE = re.compile(r"```json\s*(\{.*?\})\s*```", re.DOTALL)


def _parse_diagnosis_json(ai_text: str) -> dict | None:
    """从 AI 回复中提取 ```json 代码块并解析为 dict。

    解析失败时返回 None（不崩溃）。
    """
    match = _JSON_BLOCK_RE.search(ai_text)
    if not match:
        return None
    try:
        return json.loads(match.group(1))
    except (json.JSONDecodeError, ValueError) as e:
        logger.warning("5W JSON 解析失败: %s", e)
        return None


def _is_final_round(current_round: int, ai_text: str) -> bool:
    """判断是否为最后一轮（第 5 轮或 AI 输出了 JSON 结论）。"""
    if current_round >= MAX_ROUNDS:
        return True
    return _JSON_BLOCK_RE.search(ai_text) is not None


# ---------------------------------------------------------------------------
# 内部辅助：加载上下文数据
# ---------------------------------------------------------------------------

async def _load_question(question_id: uuid.UUID, student_id: uuid.UUID, db: AsyncSession) -> Question:
    """加载题目并校验归属。"""
    result = await db.execute(
        select(Question).where(
            Question.id == question_id,
            Question.student_id == student_id,
        )
    )
    question = result.scalar_one_or_none()
    if question is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="题目不存在或不属于当前用户",
        )
    return question


async def _load_mastery(student_id: uuid.UUID, db: AsyncSession) -> list[StudentMastery]:
    """加载学生掌握度记录。"""
    result = await db.execute(
        select(StudentMastery).where(StudentMastery.student_id == student_id)
    )
    return list(result.scalars().all())


# ---------------------------------------------------------------------------
# 公开 API：start_session
# ---------------------------------------------------------------------------

async def start_session(
    student_id: uuid.UUID,
    question_id: uuid.UUID,
    db: AsyncSession,
) -> dict:
    """创建诊断会话 + 调 LLM 生成开场白。

    返回会话信息 dict（供 router 序列化）。
    """
    # 1. 校验题目归属
    question = await _load_question(question_id, student_id, db)

    # 2. 检查是否已有活跃会话（同一题同一时间只允许一个）
    existing = await db.execute(
        select(DiagnosisSessionModel).where(
            DiagnosisSessionModel.student_id == student_id,
            DiagnosisSessionModel.question_id == question_id,
            DiagnosisSessionModel.status == "active",
        )
    )
    active_session = existing.scalar_one_or_none()
    if active_session:
        return await _session_to_dict(active_session, db)

    # 3. 加载上下文数据
    mastery_records = await _load_mastery(student_id, db)

    # 4. 拼接 system prompt
    system_prompt = await _prompt_builder.build_system_prompt(
        question=question,
        student=await _load_student(student_id, db),
        mastery_records=mastery_records,
        db=db,
    )

    # 5. 调用 LLM 生成开场白
    opening_messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": "请开始诊断这道错题。"},
    ]
    ai_reply = await _call_llm(opening_messages)

    # 6. 持久化会话 + 首条消息
    session_id = uuid.uuid4()
    now = datetime.now(timezone.utc)

    session = DiagnosisSessionModel(
        id=session_id, student_id=student_id, question_id=question_id,
        status="active", current_round=1, max_rounds=MAX_ROUNDS,
        system_prompt=system_prompt, created_at=now, updated_at=now,
    )
    db.add(session)
    await db.flush()  # 先落库 session，满足 FK 约束
    msg = DiagnosisMessageModel(
        session_id=session_id, role="assistant", content=ai_reply,
        round=1, created_at=now,
    )
    db.add(msg)
    await db.commit()

    return {
        "session_id": str(session_id),
        "status": "active",
        "question_id": str(question_id),
        "round": 1,
        "max_rounds": MAX_ROUNDS,
        "messages": [
            {
                "id": str(msg.id),
                "role": "assistant",
                "content": ai_reply,
                "round": 1,
                "created_at": now.isoformat(),
            }
        ],
    }


async def _session_to_dict(session: DiagnosisSessionModel, db: AsyncSession) -> dict:
    """将会话 ORM 对象转为 dict（含消息历史）。"""
    msg_result = await db.execute(
        select(DiagnosisMessageModel)
        .where(DiagnosisMessageModel.session_id == session.id)
        .order_by(DiagnosisMessageModel.created_at)
    )
    messages = msg_result.scalars().all()
    return {
        "session_id": str(session.id),
        "question_id": str(session.question_id),
        "status": session.status,
        "round": session.current_round,
        "max_rounds": session.max_rounds,
        "diagnosis_result": session.diagnosis_result,
        "messages": [
            {
                "id": str(m.id),
                "role": m.role,
                "content": m.content,
                "round": m.round,
                "created_at": m.created_at.isoformat(),
            }
            for m in messages
        ],
        "created_at": session.created_at.isoformat(),
    }


async def _load_student(student_id: uuid.UUID, db: AsyncSession) -> Student:
    """加载学生对象。"""
    result = await db.execute(select(Student).where(Student.id == student_id))
    student = result.scalar_one_or_none()
    if student is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="学生不存在",
        )
    return student


# ---------------------------------------------------------------------------
# 公开 API：chat
# ---------------------------------------------------------------------------

async def chat(
    session_id: uuid.UUID,
    content: str,
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict:
    """发送消息 + 调 LLM + 解析输出。

    返回 dict 包含 message / session / diagnosis_result(可选)。
    """
    # 1. 校验 session 归属 + 状态
    result = await db.execute(
        select(DiagnosisSessionModel).where(
            DiagnosisSessionModel.id == session_id,
            DiagnosisSessionModel.student_id == student_id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=404, detail="会话不存在")
    if session.status != "active":
        raise HTTPException(status_code=400, detail="会话已结束")
    if session.current_round >= session.max_rounds:
        raise HTTPException(status_code=400, detail="已达最大对话轮次")

    # 2. 加载历史消息，组装 LLM messages
    msg_result = await db.execute(
        select(DiagnosisMessageModel)
        .where(DiagnosisMessageModel.session_id == session_id)
        .order_by(DiagnosisMessageModel.created_at)
    )
    history = msg_result.scalars().all()
    llm_messages = [{"role": "system", "content": session.system_prompt}]
    for m in history:
        llm_messages.append({"role": m.role, "content": m.content})
    llm_messages.append({"role": "user", "content": content})

    # 3. 持久化用户消息
    now = datetime.now(timezone.utc)
    current_round = session.current_round + 1

    user_msg = DiagnosisMessageModel(
        session_id=session_id, role="user", content=content,
        round=current_round, created_at=now,
    )
    db.add(user_msg)

    # 4. 调用 LLM
    ai_reply = await _call_llm(llm_messages)

    # 5. 解析是否为最终轮
    is_final = _is_final_round(current_round, ai_reply)
    diagnosis_result = None

    if is_final:
        diagnosis_result = _parse_diagnosis_json(ai_reply)
        if diagnosis_result is None and current_round >= MAX_ROUNDS:
            # 5 轮后仍无 JSON → 输出最佳猜测
            diagnosis_result = {
                "evidence_5w": {
                    "confidence": "guess",
                    "ai_explanation": "对话轮次已用完，未能确定根因",
                },
            }

    new_status = "completed" if is_final else "active"

    # 6. 持久化 AI 消息 + 更新会话状态
    ai_msg = DiagnosisMessageModel(
        session_id=session_id, role="assistant", content=ai_reply,
        round=current_round, created_at=now,
    )
    db.add(ai_msg)
    session.current_round = current_round
    session.status = new_status
    if diagnosis_result:
        session.diagnosis_result = diagnosis_result
    session.updated_at = now
    await db.commit()

    # 7. 如果诊断完成，更新 Question.diagnosis_result
    if is_final and diagnosis_result:
        question = await db.get(Question, session.question_id)
        if question:
            question.diagnosis_status = "diagnosed"
            question.diagnosis_result = diagnosis_result
            await db.commit()

    response: dict = {
        "message": {
            "id": str(ai_msg.id),
            "role": "assistant",
            "content": ai_reply,
            "round": current_round,
            "created_at": now.isoformat(),
        },
        "session": {
            "session_id": str(session_id),
            "status": new_status,
            "round": current_round,
            "max_rounds": MAX_ROUNDS,
        },
    }
    if diagnosis_result:
        response["diagnosis_result"] = diagnosis_result

    return response


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
        select(DiagnosisSessionModel).where(
            DiagnosisSessionModel.id == session_id,
            DiagnosisSessionModel.student_id == student_id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=404, detail="会话不存在")

    msg_result = await db.execute(
        select(DiagnosisMessageModel)
        .where(DiagnosisMessageModel.session_id == session_id)
        .order_by(DiagnosisMessageModel.created_at)
    )
    messages = msg_result.scalars().all()

    return {
        "session_id": str(session.id),
        "question_id": str(session.question_id),
        "status": session.status,
        "round": session.current_round,
        "max_rounds": session.max_rounds,
        "diagnosis_result": session.diagnosis_result,
        "messages": [
            {
                "id": str(m.id),
                "role": m.role,
                "content": m.content,
                "round": m.round,
                "created_at": m.created_at.isoformat(),
            }
            for m in messages
        ],
        "created_at": session.created_at.isoformat(),
    }


# ---------------------------------------------------------------------------
# 公开 API：get_active_session
# ---------------------------------------------------------------------------

async def get_active_session(
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict | None:
    """获取当前活跃会话（兼容现有前端 aiDiagnosisProvider）。

    无活跃会话时返回 None。
    """
    result = await db.execute(
        select(DiagnosisSessionModel).where(
            DiagnosisSessionModel.student_id == student_id,
            DiagnosisSessionModel.status == "active",
        ).order_by(DiagnosisSessionModel.updated_at.desc()).limit(1)
    )
    session = result.scalar_one_or_none()
    if session is None:
        return None
    return await get_session(session.id, student_id, db)


# ---------------------------------------------------------------------------
# 公开 API：complete_session
# ---------------------------------------------------------------------------

async def complete_session(
    session_id: uuid.UUID,
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict:
    """手动结束会话（学生主动退出诊断）。

    将会话状态设为 expired，不生成诊断结论。
    """
    result = await db.execute(
        select(DiagnosisSessionModel).where(
            DiagnosisSessionModel.id == session_id,
            DiagnosisSessionModel.student_id == student_id,
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
        "message": "诊断会话已手动结束",
    }
