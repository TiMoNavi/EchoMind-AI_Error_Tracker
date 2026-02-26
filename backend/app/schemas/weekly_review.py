"""Weekly review schemas."""
from pydantic import BaseModel, Field


class WeeklyProgress(BaseModel):
    total_questions: int = Field(description="本周做题总数")
    correct_count: int = Field(description="本周正确题数")
    error_count: int = Field(description="本周错题数")
    new_mastered: int = Field(description="本周新掌握的知识点/模型数量")


class WeeklyReviewResponse(BaseModel):
    score_change: float = Field(description="周间正确率变化值，正数表示提升，负数表示下降")
    weekly_progress: WeeklyProgress = Field(description="本周做题统计")
    dashboard_stats: dict = Field(description="仪表盘快照数据")
    next_week_focus: list[str] = Field(description="下周重点关注的知识点/模型 ID 列表")
    last_week_score: float = Field(description="上周预测分（正确率×150）")
    this_week_score: float = Field(description="本周预测分（正确率×150）")
    progress_items: list[str] = Field(default_factory=list, description="本周新掌握的知识点/模型名称列表")
    focus_item_names: list[str] = Field(default_factory=list, description="下周重点的知识点/模型名称列表")
