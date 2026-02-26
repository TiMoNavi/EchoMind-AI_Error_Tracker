"""模型训练业务逻辑 — Training Service

依赖：
- TrainingSessionModel / TrainingMessageModel / TrainingStepResultModel (ORM)
- LLMClient + create_llm_client (app/core/llm_client.py)
- TrainingRouterEngine (app/services/training_router_engine.py)
- TrainingPromptBuilder (app/services/training_prompt_builder.py)
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
from app.models.model import Model
from app.models.training_session import TrainingSessionModel
from app.models.training_message import TrainingMessageModel
from app.models.training_step_result import TrainingStepResultModel
from app.services.training_router_engine import TrainingRouterEngine
from app.services.training_prompt_builder import TrainingPromptBuilder
from app.core.llm_factory import create_llm_client

logger = logging.getLogger(__name__)

_router_engine = TrainingRouterEngine()
_prompt_builder = TrainingPromptBuilder()

MAX_STEPS = 6

# Step 标记正则
_STEP_PASS_RE = re.compile(r"\[STEP_PASS\]")
_STEP_FAIL_RE = re.compile(r"\[STEP_FAIL\]")
_NEED_RETRY_RE = re.compile(r"\[NEED_RETRY\]")


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

async def _load_model(model_id: str, db: AsyncSession) -> Model:
    """加载模型，不存在则 404。"""
    result = await db.execute(
        select(Model).where(Model.id == model_id)
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="模型不存在",
        )
    return model


async def _load_mastery_for_model(
    student_id: uuid.UUID, model_id: str, db: AsyncSession
) -> StudentMastery | None:
    """加载学生对某模型的掌握度记录。"""
    result = await db.execute(
        select(StudentMastery).where(
            StudentMastery.student_id == student_id,
            StudentMastery.target_type == "model",
            StudentMastery.target_id == model_id,
        )
    )
    return result.scalar_one_or_none()


def _parse_step_markers(ai_text: str) -> str:
    """解析 AI 回复中的步骤标记。

    Returns:
        "pass" | "fail" | "retry" | "none"
    """
    if _STEP_PASS_RE.search(ai_text):
        return "pass"
    if _STEP_FAIL_RE.search(ai_text):
        return "fail"
    if _NEED_RETRY_RE.search(ai_text):
        return "retry"
    return "none"


def _strip_markers(text: str) -> str:
    """移除 AI 回复中的步骤标记，返回干净文本。"""
    text = _STEP_PASS_RE.sub("", text)
    text = _STEP_FAIL_RE.sub("", text)
    text = _NEED_RETRY_RE.sub("", text)
    return text.strip()


async def _session_to_dict(session: TrainingSessionModel, db: AsyncSession) -> dict:
    """将会话 ORM 对象转为 dict（含消息历史 + 步骤结果）。"""
    msg_result = await db.execute(
        select(TrainingMessageModel)
        .where(TrainingMessageModel.session_id == session.id)
        .order_by(TrainingMessageModel.created_at)
    )
    messages = msg_result.scalars().all()

    step_result = await db.execute(
        select(TrainingStepResultModel)
        .where(TrainingStepResultModel.session_id == session.id)
        .order_by(TrainingStepResultModel.step)
    )
    step_results = step_result.scalars().all()

    mastery = session.mastery_snapshot or {}

    return {
        "session_id": str(session.id),
        "model_id": str(session.model_id),
        "model_name": session.model_name or "",
        "status": session.status,
        "current_step": session.current_step,
        "entry_step": session.entry_step,
        "source": session.source,
        "mastery": {
            "current_level": mastery.get("current_level", 0),
            "peak_level": mastery.get("peak_level", 0),
            "mastery_value": mastery.get("mastery_value", 0.0),
        },
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
        "step_results": [
            {
                "step": sr.step,
                "passed": sr.passed,
                "ai_summary": sr.ai_summary,
                "details": sr.details,
            }
            for sr in step_results
        ],
        "created_at": session.created_at.isoformat() if session.created_at else None,
        "updated_at": session.updated_at.isoformat() if session.updated_at else None,
    }


# ---------------------------------------------------------------------------
# 公开 API：start_session
# ---------------------------------------------------------------------------

async def start_session(
    student_id: uuid.UUID,
    model_id: str,
    source: str,
    db: AsyncSession,
    question_id: str | None = None,
    diagnosis_result: dict | None = None,
) -> dict:
    """创建训练会话 + 路由入口步骤 + 调 LLM 生成开场白。"""
    # 1. 校验模型存在
    model = await _load_model(model_id, db)

    # 2. 检查是否已有活跃会话
    existing = await db.execute(
        select(TrainingSessionModel).where(
            TrainingSessionModel.student_id == student_id,
            TrainingSessionModel.model_id == model_id,
            TrainingSessionModel.status == "active",
        )
    )
    active_session = existing.scalar_one_or_none()
    if active_session:
        return await _session_to_dict(active_session, db)

    # 3. 加载掌握度
    mastery = await _load_mastery_for_model(student_id, model_id, db)
    current_level = mastery.current_level if mastery else 0
    peak_level = mastery.peak_level if mastery else 0
    mastery_value = mastery.mastery_value if mastery else 0.0
    last_active = mastery.last_active if mastery else None

    # 4. 路由引擎判定入口步骤
    entry_step = _router_engine.determine_entry_step(
        source=source,
        current_level=current_level,
        peak_level=peak_level,
        last_active=last_active,
        diagnosis_result=diagnosis_result,
    )

    # 5. 拼接 system prompt
    student_context = {
        "current_level": current_level,
        "peak_level": peak_level,
        "source": source,
        "is_unstable": (peak_level - current_level) >= 2,
    }
    preset_content = model.preset_content or {} if hasattr(model, "preset_content") else {}
    system_prompt = _prompt_builder.build_step_prompt(
        step=entry_step,
        model_name=model.name,
        preset_content=preset_content,
        student_context=student_context,
    )

    # 6. 调用 LLM 生成开场白
    opening_messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": "请开始训练。"},
    ]
    ai_reply = await _call_llm(opening_messages)
    clean_reply = _strip_markers(ai_reply)

    # 7. 持久化会话 + 首条消息
    session_id = uuid.uuid4()
    now = datetime.now(timezone.utc)
    mastery_snap = {
        "current_level": current_level,
        "peak_level": peak_level,
        "mastery_value": mastery_value,
    }

    session = TrainingSessionModel(
        id=session_id,
        student_id=student_id,
        model_id=model_id,
        model_name=model.name,
        status="active",
        current_step=entry_step,
        entry_step=entry_step,
        source=source,
        question_id=question_id,
        diagnosis_result=diagnosis_result,
        system_prompt=system_prompt,
        mastery_snapshot=mastery_snap,
        created_at=now,
        updated_at=now,
    )
    db.add(session)
    await db.flush()

    msg = TrainingMessageModel(
        session_id=session_id,
        role="assistant",
        content=clean_reply,
        step=entry_step,
        created_at=now,
    )
    db.add(msg)
    await db.commit()

    return {
        "session_id": str(session_id),
        "model_id": model_id,
        "model_name": model.name,
        "status": "active",
        "current_step": entry_step,
        "entry_step": entry_step,
        "source": source,
        "mastery": mastery_snap,
        "messages": [
            {
                "id": str(msg.id),
                "role": "assistant",
                "content": clean_reply,
                "step": entry_step,
                "created_at": now.isoformat(),
            }
        ],
        "step_results": [],
        "created_at": now.isoformat(),
        "updated_at": now.isoformat(),
    }


# ---------------------------------------------------------------------------
# 公开 API：interact
# ---------------------------------------------------------------------------

async def interact(
    session_id: str,
    content: str,
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict:
    """学生发送消息 + 调 LLM + 解析步骤标记 + 记录步骤结果。"""
    # 1. 校验 session 归属 + 状态
    result = await db.execute(
        select(TrainingSessionModel).where(
            TrainingSessionModel.id == session_id,
            TrainingSessionModel.student_id == student_id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=404, detail="训练会话不存在")
    if session.status != "active":
        raise HTTPException(status_code=400, detail="训练会话已结束")

    # 2. 加载历史消息，组装 LLM messages
    msg_result = await db.execute(
        select(TrainingMessageModel)
        .where(TrainingMessageModel.session_id == session.id)
        .order_by(TrainingMessageModel.created_at)
    )
    history = msg_result.scalars().all()
    llm_messages = [{"role": "system", "content": session.system_prompt}]
    for m in history:
        llm_messages.append({"role": m.role, "content": m.content})
    llm_messages.append({"role": "user", "content": content})

    # 3. 持久化用户消息
    now = datetime.now(timezone.utc)
    user_msg = TrainingMessageModel(
        session_id=session.id,
        role="user",
        content=content,
        step=session.current_step,
        created_at=now,
    )
    db.add(user_msg)

    # 4. 调用 LLM
    ai_reply = await _call_llm(llm_messages)

    # 5. 解析步骤标记
    marker = _parse_step_markers(ai_reply)
    clean_reply = _strip_markers(ai_reply)

    # 6. 持久化 AI 消息
    ai_msg = TrainingMessageModel(
        session_id=session.id,
        role="assistant",
        content=clean_reply,
        step=session.current_step,
        created_at=now,
    )
    db.add(ai_msg)

    # 7. 根据标记处理步骤结果
    step_status = "in_progress"
    step_result_data = None
    next_step_hint = None

    if marker in ("pass", "fail"):
        passed = marker == "pass"
        step_status = "passed" if passed else "failed"

        # 记录步骤结果
        sr = TrainingStepResultModel(
            session_id=session.id,
            step=session.current_step,
            passed=passed,
            ai_summary=clean_reply[:200],
            created_at=now,
        )
        db.add(sr)

        step_result_data = {
            "step": session.current_step,
            "passed": passed,
            "ai_summary": clean_reply[:200],
        }

        # 路由引擎判定下一步
        next_step = _router_engine.determine_next_step(
            current_step=session.current_step,
            step_passed=passed,
            entry_step=session.entry_step,
            current_level=(session.mastery_snapshot or {}).get("current_level", 0),
        )

        if next_step is not None:
            next_step_hint = {
                "next_step": next_step,
                "step_name": _router_engine.get_step_name(next_step),
                "auto_advance": False,
            }

    session.updated_at = now
    await db.commit()

    return {
        "message": {
            "id": str(ai_msg.id),
            "role": "assistant",
            "content": clean_reply,
            "step": session.current_step,
            "created_at": now.isoformat(),
        },
        "step_status": step_status,
        "step_result": step_result_data,
        "next_step_hint": next_step_hint,
        "session": {
            "session_id": str(session.id),
            "status": session.status,
            "current_step": session.current_step,
        },
    }


# ---------------------------------------------------------------------------
# 公开 API：next_step
# ---------------------------------------------------------------------------

async def next_step(
    session_id: str,
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict:
    """显式推进到下一步骤，切换 system prompt 并生成新步骤开场白。"""
    # 1. 校验 session
    result = await db.execute(
        select(TrainingSessionModel).where(
            TrainingSessionModel.id == session_id,
            TrainingSessionModel.student_id == student_id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=404, detail="训练会话不存在")
    if session.status != "active":
        raise HTTPException(status_code=400, detail="训练会话已结束")

    # 2. 查找最近一次步骤结果，判定下一步
    sr_result = await db.execute(
        select(TrainingStepResultModel)
        .where(
            TrainingStepResultModel.session_id == session.id,
            TrainingStepResultModel.step == session.current_step,
        )
    )
    last_sr = sr_result.scalar_one_or_none()
    step_passed = last_sr.passed if last_sr else True

    next_s = _router_engine.determine_next_step(
        current_step=session.current_step,
        step_passed=step_passed,
        entry_step=session.entry_step,
        current_level=(session.mastery_snapshot or {}).get("current_level", 0),
    )

    # 3. 训练完成
    if next_s is None:
        return await _finalize_session(session, db)

    # 4. 切换步骤 + 重建 system prompt
    model = await _load_model(str(session.model_id), db)
    student_context = {
        "current_level": (session.mastery_snapshot or {}).get("current_level", 0),
        "peak_level": (session.mastery_snapshot or {}).get("peak_level", 0),
        "source": session.source,
        "is_unstable": False,
    }
    preset_content = model.preset_content or {} if hasattr(model, "preset_content") else {}
    new_prompt = _prompt_builder.build_step_prompt(
        step=next_s,
        model_name=model.name,
        preset_content=preset_content,
        student_context=student_context,
    )

    # 5. 调 LLM 生成新步骤开场白
    opening_messages = [
        {"role": "system", "content": new_prompt},
        {"role": "user", "content": f"请开始 Step {next_s} 的训练。"},
    ]
    ai_reply = await _call_llm(opening_messages)
    clean_reply = _strip_markers(ai_reply)

    # 6. 更新会话 + 持久化消息
    now = datetime.now(timezone.utc)
    session.current_step = next_s
    session.system_prompt = new_prompt
    session.updated_at = now

    msg = TrainingMessageModel(
        session_id=session.id,
        role="assistant",
        content=clean_reply,
        step=next_s,
        created_at=now,
    )
    db.add(msg)
    await db.commit()

    return {
        "session": {
            "session_id": str(session.id),
            "status": session.status,
            "current_step": next_s,
        },
        "step_info": {
            "step": next_s,
            "step_name": _router_engine.get_step_name(next_s),
        },
        "messages": [
            {
                "id": str(msg.id),
                "role": "assistant",
                "content": clean_reply,
                "step": next_s,
                "created_at": now.isoformat(),
            }
        ],
        "training_result": None,
    }


# ---------------------------------------------------------------------------
# 内部：_finalize_session（训练完成，计算掌握度更新）
# ---------------------------------------------------------------------------

async def _finalize_session(
    session: TrainingSessionModel,
    db: AsyncSession,
) -> dict:
    """训练完成：汇总步骤结果 → 计算掌握度更新 → 关闭会话。"""
    now = datetime.now(timezone.utc)

    # 1. 加载所有步骤结果
    sr_result = await db.execute(
        select(TrainingStepResultModel)
        .where(TrainingStepResultModel.session_id == session.id)
        .order_by(TrainingStepResultModel.step)
    )
    step_results = sr_result.scalars().all()
    results_list = [
        {"step": sr.step, "passed": sr.passed}
        for sr in step_results
    ]

    # 2. 计算掌握度更新
    mastery_snap = session.mastery_snapshot or {}
    current_mastery = mastery_snap.get("mastery_value", 0.0)
    current_level = mastery_snap.get("current_level", 0)

    update = _router_engine.calculate_mastery_update(
        step_results=results_list,
        current_mastery=current_mastery,
        current_level=current_level,
    )

    # 3. 更新 StudentMastery 表
    mastery_record = await _load_mastery_for_model(
        session.student_id, str(session.model_id), db
    )
    if mastery_record:
        mastery_record.mastery_value = update["mastery_value"]
        mastery_record.current_level = update["new_level"]
        if update["new_level"] > mastery_record.peak_level:
            mastery_record.peak_level = update["new_level"]
        mastery_record.updated_at = now

    # 4. 关闭会话
    training_result = {
        "step_results": results_list,
        "mastery_update": update,
        "completed_at": now.isoformat(),
    }
    session.status = "completed"
    session.training_result = training_result
    session.updated_at = now
    await db.commit()

    return {
        "session": {
            "session_id": str(session.id),
            "status": "completed",
            "current_step": session.current_step,
        },
        "step_info": None,
        "messages": [],
        "training_result": training_result,
    }


# ---------------------------------------------------------------------------
# 公开 API：get_session
# ---------------------------------------------------------------------------

async def get_session(
    session_id: str,
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict:
    """获取训练会话详情（含完整消息历史 + 步骤结果）。"""
    result = await db.execute(
        select(TrainingSessionModel).where(
            TrainingSessionModel.id == session_id,
            TrainingSessionModel.student_id == student_id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=404, detail="训练会话不存在")
    return await _session_to_dict(session, db)


# ---------------------------------------------------------------------------
# 公开 API：get_active_session
# ---------------------------------------------------------------------------

async def get_active_session(
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict | None:
    """获取当前活跃训练会话。无活跃会话时返回 None。"""
    result = await db.execute(
        select(TrainingSessionModel).where(
            TrainingSessionModel.student_id == student_id,
            TrainingSessionModel.status == "active",
        ).order_by(TrainingSessionModel.updated_at.desc()).limit(1)
    )
    session = result.scalar_one_or_none()
    if session is None:
        return None
    return await _session_to_dict(session, db)


# ---------------------------------------------------------------------------
# 公开 API：complete_session
# ---------------------------------------------------------------------------

async def complete_session(
    session_id: str,
    student_id: uuid.UUID,
    db: AsyncSession,
) -> dict:
    """手动完成训练会话。

    如果有步骤结果则计算掌握度更新，否则标记为 expired。
    """
    result = await db.execute(
        select(TrainingSessionModel).where(
            TrainingSessionModel.id == session_id,
            TrainingSessionModel.student_id == student_id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=404, detail="训练会话不存在")
    if session.status != "active":
        raise HTTPException(status_code=400, detail="训练会话已结束")

    # 检查是否有步骤结果
    sr_result = await db.execute(
        select(TrainingStepResultModel)
        .where(TrainingStepResultModel.session_id == session.id)
    )
    step_results = sr_result.scalars().all()

    now = datetime.now(timezone.utc)
    training_result = None

    if step_results:
        # 有步骤结果 → 正常完成，计算掌握度
        results_list = [
            {"step": sr.step, "passed": sr.passed}
            for sr in step_results
        ]
        mastery_snap = session.mastery_snapshot or {}
        update = _router_engine.calculate_mastery_update(
            step_results=results_list,
            current_mastery=mastery_snap.get("mastery_value", 0.0),
            current_level=mastery_snap.get("current_level", 0),
        )

        # 更新 StudentMastery
        mastery_record = await _load_mastery_for_model(
            session.student_id, str(session.model_id), db
        )
        if mastery_record:
            mastery_record.mastery_value = update["mastery_value"]
            mastery_record.current_level = update["new_level"]
            if update["new_level"] > mastery_record.peak_level:
                mastery_record.peak_level = update["new_level"]
            mastery_record.updated_at = now

        training_result = {
            "step_results": results_list,
            "mastery_update": update,
            "completed_at": now.isoformat(),
        }
        session.status = "completed"
    else:
        # 无步骤结果 → 标记为 expired（学生主动退出）
        session.status = "expired"

    session.training_result = training_result
    session.updated_at = now
    await db.commit()

    return {
        "session_id": str(session.id),
        "status": session.status,
        "training_result": training_result,
        "message": "训练会话已完成" if session.status == "completed" else "训练会话已手动结束",
    }
