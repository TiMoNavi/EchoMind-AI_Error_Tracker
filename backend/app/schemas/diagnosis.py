"""Diagnosis schemas — 诊断会话请求/响应模型"""
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


# ── 请求 Schema ──────────────────────────────────────────────


class DiagnosisStartRequest(BaseModel):
    question_id: UUID = Field(description="要诊断的错题 ID (UUID)")


class DiagnosisChatRequest(BaseModel):
    session_id: UUID = Field(description="诊断会话 ID (UUID)")
    content: str = Field(min_length=1, description="学生发送的消息文本")


class DiagnosisCompleteRequest(BaseModel):
    session_id: UUID = Field(description="要结束的诊断会话 ID (UUID)")


# ── 响应 Schema ──────────────────────────────────────────────


class DiagnosisMessageResponse(BaseModel):
    id: UUID = Field(description="消息唯一 ID (UUID)")
    role: str = Field(description="消息角色：user 学生 / assistant AI 助手 / system 系统")
    content: str = Field(description="消息文本内容")
    round: int = Field(description="所属对话轮次（从 1 开始）")
    created_at: datetime = Field(description="消息创建时间 (ISO 8601)")

    model_config = {"from_attributes": True}


class DiagnosisResultResponse(BaseModel):
    four_layer: dict | None = Field(
        default=None,
        description="四层定位结果：modeling/equation/execution 各层 pass|fail|unreached",
    )
    root_category: str | None = Field(
        default=None,
        description="错误根源大类：careless 粗心 / knowledge_gap 知识缺口 / model_application 模型应用",
    )
    root_subcategory: str | None = Field(
        default=None,
        description="错误根源子类：identify/decide/step/subject/substitution（仅 model_application 时有值）",
    )
    evidence_5w: dict | None = Field(
        default=None,
        description="5W 证据 JSON：what_description, when_stage, root_cause_id, ai_explanation, confidence",
    )
    next_action: dict | None = Field(
        default=None,
        description="后续引导动作：type(knowledge_learning/model_training/careless_drill), target_id, message",
    )


class DiagnosisSessionResponse(BaseModel):
    session_id: UUID = Field(description="诊断会话唯一 ID (UUID)")
    question_id: UUID = Field(description="关联的错题 ID (UUID)")
    status: str = Field(description="会话状态：active 进行中 / completed 已完成 / expired 已过期")
    round: int = Field(description="当前对话轮次")
    max_rounds: int = Field(default=5, description="最大对话轮次（默认 5）")
    diagnosis_result: DiagnosisResultResponse | None = Field(
        default=None, description="诊断结论（仅 completed 时有值）"
    )
    messages: list[DiagnosisMessageResponse] = Field(
        default=[], description="对话消息列表（按时间正序）"
    )
    created_at: datetime = Field(description="会话创建时间 (ISO 8601)")

    model_config = {"from_attributes": True}
