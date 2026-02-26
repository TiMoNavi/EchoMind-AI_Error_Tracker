"""LearningSession model — 知识点学习会话表"""
import uuid
from datetime import datetime

from sqlalchemy import String, Integer, Float, Text, DateTime, ForeignKey, Index, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class LearningSessionModel(Base):
    __tablename__ = "learning_sessions"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    student_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("students.id"), nullable=False
    )
    knowledge_point_id: Mapped[str] = mapped_column(
        String(50), nullable=False
    )
    status: Mapped[str] = mapped_column(
        String(20), nullable=False, default="active"
    )
    source: Mapped[str] = mapped_column(
        String(30), nullable=False, default="self_study"
    )
    current_step: Mapped[int] = mapped_column(
        Integer, nullable=False, default=1
    )
    max_steps: Mapped[int] = mapped_column(
        Integer, nullable=False, default=5
    )
    mastery_before: Mapped[float | None] = mapped_column(Float)
    mastery_after: Mapped[float | None] = mapped_column(Float)
    level_before: Mapped[str | None] = mapped_column(String(5))
    level_after: Mapped[str | None] = mapped_column(String(5))
    system_prompt: Mapped[str | None] = mapped_column(Text)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    __table_args__ = (
        Index("idx_ls_student", "student_id"),
        Index("idx_ls_status", "student_id", "status"),
    )
