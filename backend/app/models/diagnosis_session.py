"""DiagnosisSession model — 诊断会话表"""
import uuid
from datetime import datetime

from sqlalchemy import String, SmallInteger, Text, DateTime, ForeignKey, Index, func
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class DiagnosisSessionModel(Base):
    __tablename__ = "diagnosis_sessions"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    student_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("students.id"), nullable=False
    )
    question_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("questions.id"), nullable=False
    )
    status: Mapped[str] = mapped_column(
        String(20), nullable=False, default="active"
    )
    current_round: Mapped[int] = mapped_column(
        SmallInteger, nullable=False, default=0
    )
    max_rounds: Mapped[int] = mapped_column(
        SmallInteger, nullable=False, default=5
    )
    system_prompt: Mapped[str | None] = mapped_column(Text)
    diagnosis_result: Mapped[dict | None] = mapped_column(JSONB)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    __table_args__ = (
        Index("idx_diag_session_student", "student_id"),
        Index("idx_diag_session_question", "question_id"),
        Index(
            "idx_diag_session_active",
            "student_id",
            "question_id",
            unique=True,
            postgresql_where=(status == "active"),
        ),
    )
