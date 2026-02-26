"""TrainingStepResult model — 模型训练步骤结果表"""
import uuid
from datetime import datetime

from sqlalchemy import SmallInteger, Boolean, Text, DateTime, ForeignKey, Index, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class TrainingStepResultModel(Base):
    __tablename__ = "training_step_results"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    session_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("training_sessions.id", ondelete="CASCADE"),
        nullable=False,
    )
    step: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    passed: Mapped[bool] = mapped_column(Boolean, nullable=False)
    ai_summary: Mapped[str | None] = mapped_column(Text)
    details: Mapped[dict | None] = mapped_column(JSONB)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    __table_args__ = (
        UniqueConstraint("session_id", "step", name="uq_train_step_session_step"),
        Index("idx_train_step_session", "session_id"),
    )
