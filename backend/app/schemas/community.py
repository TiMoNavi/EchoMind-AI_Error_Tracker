"""Community schemas — 需求投票 + 反馈"""
from datetime import datetime
from pydantic import BaseModel, Field


# ── FeatureRequest ──────────────────────────────────────

class FeatureRequestCreate(BaseModel):
    title: str = Field(max_length=200, description="需求标题")
    description: str = Field(description="需求详细描述")
    tag: str | None = Field(default=None, max_length=50, description="标签分类")


class FeatureRequestResponse(BaseModel):
    id: str = Field(description="需求 ID (UUID)")
    title: str
    description: str
    vote_count: int
    tag: str | None
    student_id: str
    voted: bool = Field(default=False, description="当前用户是否已投票")
    created_at: datetime

    model_config = {"from_attributes": True}


# ── Vote ────────────────────────────────────────────────

class VoteResponse(BaseModel):
    request_id: str
    vote_count: int
    voted: bool = Field(description="操作后的投票状态")


# ── Feedback ────────────────────────────────────────────

class FeedbackCreate(BaseModel):
    content: str = Field(description="反馈内容")
    feedback_type: str = Field(max_length=30, description="反馈类型: bug / suggestion / other")


class FeedbackResponse(BaseModel):
    id: str
    content: str
    feedback_type: str
    student_id: str
    created_at: datetime

    model_config = {"from_attributes": True}
