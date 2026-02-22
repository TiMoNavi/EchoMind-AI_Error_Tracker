"""Question schemas."""
from datetime import datetime
from pydantic import BaseModel


class QuestionUploadRequest(BaseModel):
    image_url: str
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


class HistoryDateGroup(BaseModel):
    date: str
    questions: list[QuestionResponse]
