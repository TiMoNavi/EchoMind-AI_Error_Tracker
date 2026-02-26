"""Prediction schemas."""
from pydantic import BaseModel, Field


class TrendPoint(BaseModel):
    date: str = Field(description="日期，格式 YYYY-MM-DD")
    score: float = Field(description="该日期的预测/实际分数")


class PriorityModel(BaseModel):
    model_id: str = Field(description="解题模型 ID")
    model_name: str = Field(description="解题模型名称")
    current_level: int = Field(description="当前掌握等级 (0-4)")
    error_count: int = Field(description="错题数量")


class ScorePathRow(BaseModel):
    label: str = Field(description="提分维度名称（如「公式记忆」「模型识别」等）")
    current: float = Field(description="当前得分")
    target: float = Field(description="目标得分")


class PredictionResponse(BaseModel):
    predicted_score: float | None = Field(description="AI 预测分数，无数据时为 null")
    target_score: float = Field(description="学生目标分数，来自 students.target_score")
    trend_data: list[TrendPoint] = Field(description="分数趋势数据（按日期排列）")
    priority_models: list[PriorityModel] = Field(description="优先提升的解题模型列表")
    score_path: list[ScorePathRow] = Field(description="提分路径表（各维度当前 vs 目标）")
