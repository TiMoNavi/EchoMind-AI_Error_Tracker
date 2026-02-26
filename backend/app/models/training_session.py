"""TrainingSession model — 模型训练会话表"""
import uuid
from datetime import datetime

from sqlalchemy import String, Integer, Float, Text, DateTime, ForeignKey, Index, func
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class TrainingSessionModel(Base):
    __tablename__ = "training_sessions"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    student_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("students.id"), nullable=False
    )
    model_id: Mapped[str] = mapped_column(
        String(50), nullable=False
    )
    model_name: Mapped[str | None] = mapped_column(String(100))
    status: Mapped[str] = mapped_column(
        String(20), nullable=False, default="active"
    )
    current_step: Mapped[int] = mapped_column(
        Integer, nullable=False, default=1
    )
    entry_step: Mapped[int] = mapped_column(
        Integer, nullable=False, default=1
    )
    source: Mapped[str] = mapped_column(
        String(30), nullable=False, default="self_study"
    )
    question_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("questions.id"), nullable=True
    )
    diagnosis_result: Mapped[dict | None] = mapped_column(JSONB)
    system_prompt: Mapped[str | None] = mapped_column(Text)
    mastery_snapshot: Mapped[dict | None] = mapped_column(JSONB)
    training_result: Mapped[dict | None] = mapped_column(JSONB)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    __table_args__ = (
        Index("idx_train_session_student", "student_id"),
        Index("idx_train_session_model", "model_id"),
        Index(
            "idx_train_session_active",
            "student_id",
            "model_id",
            unique=True,
            postgresql_where=(status == "active"),
        ),
    )
