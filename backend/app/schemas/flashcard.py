"""Flashcard schemas."""
from pydantic import BaseModel


class FlashcardItem(BaseModel):
    id: str
    target_type: str
    target_id: str
    target_name: str
    mastery_value: float
    due: bool


class FlashcardReviewRequest(BaseModel):
    quality: int  # 0-5 SM-2 quality
