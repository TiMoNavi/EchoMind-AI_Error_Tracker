"""Weekly review schemas."""
from pydantic import BaseModel


class WeeklyProgress(BaseModel):
    total_questions: int
    correct_count: int
    error_count: int
    new_mastered: int


class WeeklyReviewResponse(BaseModel):
    score_change: float
    weekly_progress: WeeklyProgress
    dashboard_stats: dict
    next_week_focus: list[str]
