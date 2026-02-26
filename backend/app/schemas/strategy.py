"""Strategy schemas — 卷面策略请求/响应模型"""
from pydantic import BaseModel, Field


# ── 请求 Schema ──────────────────────────────────────────────


class StrategyGenerateRequest(BaseModel):
    target_score: int | None = Field(
        default=None, ge=30, le=150,
        description="目标分数（不传则使用学生当前 target_score）",
    )


class TargetScoreUpdateRequest(BaseModel):
    new_target_score: int = Field(
        ..., ge=30, le=150,
        description="新目标分数",
    )


# ── 响应子结构 ────────────────────────────────────────────────


class QuestionDetail(BaseModel):
    question_number: int | str
    max_score: int
    difficulty: str
    typical_models: list[str] = []
    typical_kps: list[str] = []


class ExamSection(BaseModel):
    section_name: str
    questions: list[QuestionDetail]


class QuestionStrategy(BaseModel):
    question_range: str
    max_score: int
    target_score: int
    attitude: str  # must / try / skip
    note: str
    display_text: str


class DiagnosisPathItem(BaseModel):
    tier: int
    model_id: str
    score_impact: str
    reason: str
    skippable: bool = False


# ── 响应 Schema ──────────────────────────────────────────────


class StrategyData(BaseModel):
    target_score: int
    total_score: int
    region_id: str
    subject: str
    template_id: str
    key_message: str | None = None
    vs_lower: str | None = None
    vs_higher: str | None = None
    question_strategies: list[QuestionStrategy]
    exam_structure: list[ExamSection]
    diagnosis_path: list[DiagnosisPathItem]
    generated_at: str


class StrategyResponse(BaseModel):
    has_strategy: bool
    strategy: StrategyData | None = None


class AttitudeChange(BaseModel):
    question_range: str
    old_attitude: str
    new_attitude: str


class StrategyChanges(BaseModel):
    upgraded_to_must: list[AttitudeChange]
    downgraded: list[AttitudeChange]
    key_message_diff: str


class TargetScoreUpdateResponse(BaseModel):
    old_target_score: int
    new_target_score: int
    strategy: StrategyData
    changes: StrategyChanges


class TemplateListResponse(BaseModel):
    region_id: str
    subject: str
    available_scores: list[int]
