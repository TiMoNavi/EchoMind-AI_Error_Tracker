"""Question schemas."""
from datetime import datetime
from pydantic import BaseModel


class QuestionUploadRequest(BaseModel):
    image_url: str | None = None
    is_correct: bool | None = None
    source: str = "manual"


class QuestionResponse(BaseModel):
    id: str
    image_url: str | None
    is_correct: bool | None
    source: str
    diagnosis_status: str
    created_at: datetime

    model_config = {"from_attributes": True}


class QuestionDetailResponse(BaseModel):
    id: str
    image_url: str | None = None
    is_correct: bool | None = None
    source: str
    diagnosis_status: str
    diagnosis_result: dict | None = None
    created_at: datetime
    primary_model_id: str | None = None
    related_kp_ids: list[str] | None = None

    model_config = {"from_attributes": True}


class HistoryDateGroup(BaseModel):
    date: str
    questions: list[QuestionResponse]
