"""Prediction schemas."""
from pydantic import BaseModel


class TrendPoint(BaseModel):
    date: str
    score: float


class PriorityModel(BaseModel):
    model_id: str
    model_name: str
    current_level: int
    error_count: int


class ScorePathRow(BaseModel):
    label: str
    current: float
    target: float


class PredictionResponse(BaseModel):
    predicted_score: float | None
    trend_data: list[TrendPoint]
    priority_models: list[PriorityModel]
    score_path: list[ScorePathRow]
