"""Knowledge learning session schemas."""
from pydantic import BaseModel, Field


# ---------- Request ----------

class LearningStartRequest(BaseModel):
    knowledge_point_id: str = Field(..., description="知识点 ID")
    source: str = Field(default="self_study", description="来源路径: self_study | diagnosis_redirect | model_training | weekly_review")


class LearningChatRequest(BaseModel):
    session_id: str = Field(..., description="学习会话 ID")
    content: str = Field(..., min_length=1, description="学生发送的消息")


class LearningCompleteRequest(BaseModel):
    session_id: str = Field(..., description="要完成的学习会话 ID")


# ---------- Response ----------

class LearningMessageResponse(BaseModel):
    id: str
    role: str
    content: str
    step: int
    created_at: str


class LearningSessionResponse(BaseModel):
    session_id: str
    status: str
    knowledge_point_id: str
    knowledge_point_name: str = ""
    current_step: int
    max_steps: int = 5
    source: str = "self_study"
    mastery_before: float | None = None
    mastery_after: float | None = None
    level_before: str | None = None
    level_after: str | None = None
    messages: list[LearningMessageResponse] = []
    created_at: str | None = None
    updated_at: str | None = None


class LearningChatResponse(BaseModel):
    message: LearningMessageResponse
    session: dict


class LearningCompleteResponse(BaseModel):
    session_id: str
    status: str
    mastery_before: float | None = None
    mastery_after: float | None = None
    level_before: str | None = None
    level_after: str | None = None
    message: str = "学习会话已完成"


# ---------- 兼容旧前端 ----------

class LearningDialogue(BaseModel):
    role: str = Field(default="", description="对话角色")
    content: str = Field(default="", description="对话文本内容")


class LearningSession(BaseModel):
    """兼容旧前端 GET /session 的空结构"""
    knowledge_point_id: str = Field(default="", description="知识点 ID")
    knowledge_point_name: str = Field(default="", description="知识点名称")
    current_step: int = Field(default=0, description="当前步骤")
    dialogues: list[LearningDialogue] = Field(default=[], description="对话列表")
