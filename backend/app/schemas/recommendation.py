"""Recommendation schemas."""
from pydantic import BaseModel


class RecommendationItem(BaseModel):
    target_type: str
    target_id: str
    target_name: str
    current_level: int
    error_count: int
    is_unstable: bool
