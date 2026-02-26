"""Model training session schemas."""
from pydantic import BaseModel, Field


# ---------- Request ----------

class TrainingStartRequest(BaseModel):
    model_id: str = Field(..., description="训练的模型 UUID")
    source: str = Field(
        default="self_study",
        description="来源: error_diagnosis | self_study | quick_check | recommendation",
    )
    question_id: str | None = Field(default=None, description="关联错题 UUID（可选）")
    diagnosis_result: dict | None = Field(default=None, description="诊断结果（可选）")


class TrainingInteractRequest(BaseModel):
    session_id: str = Field(..., description="训练会话 ID")
    content: str = Field(..., min_length=1, description="学生发送的消息")


class TrainingNextStepRequest(BaseModel):
    session_id: str = Field(..., description="训练会话 ID")


class TrainingCompleteRequest(BaseModel):
    session_id: str = Field(..., description="要完成的训练会话 ID")


# ---------- Response ----------

class TrainingMessageResponse(BaseModel):
    id: str
    role: str
    content: str
    step: int
    created_at: str


class MasterySnapshot(BaseModel):
    current_level: int = 0
    peak_level: int = 0
    mastery_value: float = 0.0


class StepResult(BaseModel):
    step: int
    passed: bool
    ai_summary: str | None = None
    details: dict | None = None


class NextStepHint(BaseModel):
    next_step: int
    step_name: str = ""
    auto_advance: bool = False


class TrainingSessionResponse(BaseModel):
    session_id: str
    model_id: str
    model_name: str = ""
    status: str
    current_step: int
    entry_step: int = 1
    source: str = "self_study"
    mastery: MasterySnapshot | None = None
    messages: list[TrainingMessageResponse] = []
    step_results: list[StepResult] = []
    created_at: str | None = None
    updated_at: str | None = None


class SessionBrief(BaseModel):
    session_id: str
    status: str
    current_step: int


class TrainingInteractResponse(BaseModel):
    message: TrainingMessageResponse
    step_status: str = "in_progress"
    step_result: StepResult | None = None
    next_step_hint: NextStepHint | None = None
    session: SessionBrief


class StepInfo(BaseModel):
    step: int
    step_name: str = ""
    preset_content: dict | None = None


class TrainingNextStepResponse(BaseModel):
    session: SessionBrief
    step_info: StepInfo | None = None
    messages: list[TrainingMessageResponse] = []
    training_result: dict | None = None


class TrainingCompleteResponse(BaseModel):
    session_id: str
    status: str
    training_result: dict | None = None
    message: str = "训练会话已完成"


# ---------- 兼容旧前端 ----------

class TrainingDialogue(BaseModel):
    role: str = Field(default="", description="对话角色")
    content: str = Field(default="", description="对话文本内容")


class TrainingSession(BaseModel):
    """兼容旧前端 GET /session 的空结构"""
    model_id: str = Field(default="", description="模型 ID")
    model_name: str = Field(default="", description="模型名称")
    current_step: int = Field(default=0, description="当前步骤")
    dialogues: list[TrainingDialogue] = Field(default=[], description="对话列表")
