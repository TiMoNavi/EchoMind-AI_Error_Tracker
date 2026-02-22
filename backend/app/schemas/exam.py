"""Exam schemas."""
from datetime import datetime
from pydantic import BaseModel


class ExamItem(BaseModel):
    id: str
    name: str
    score: float | None = None
    total_score: float = 150
    date: str


class HeatmapPoint(BaseModel):
    date: str
    count: int
