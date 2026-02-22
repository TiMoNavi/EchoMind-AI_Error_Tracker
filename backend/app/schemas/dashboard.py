"""Dashboard schemas."""
from pydantic import BaseModel


class DashboardResponse(BaseModel):
    total_questions: int
    error_count: int
    mastery_count: int
    weak_count: int
    predicted_score: float | None
    formula_memory_rate: float
    model_identify_rate: float
    calculation_accuracy: float
    reading_accuracy: float
