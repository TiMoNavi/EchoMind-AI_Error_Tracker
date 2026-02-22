"""Question — 表5"""
import uuid
from datetime import datetime

from sqlalchemy import String, Boolean, Integer, DateTime, ForeignKey, Index, func
from sqlalchemy.dialects.postgresql import UUID, JSONB, ARRAY, TEXT
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Question(Base):
    __tablename__ = "questions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("students.id"), nullable=False)
    source: Mapped[str] = mapped_column(String(20), nullable=False)
    upload_batch_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True))
    image_url: Mapped[str | None] = mapped_column(String(500))

    is_correct: Mapped[bool | None] = mapped_column(Boolean)
    primary_model_id: Mapped[str | None] = mapped_column(String(50))
    related_kp_ids: Mapped[list[str] | None] = mapped_column(ARRAY(TEXT))
    exam_question_number: Mapped[int | None] = mapped_column(Integer)

    diagnosis_status: Mapped[str] = mapped_column(String(20), default="pending")
    diagnosis_result: Mapped[dict | None] = mapped_column(JSONB)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        Index("idx_questions_student", "student_id", created_at.desc()),
        Index("idx_questions_model", "primary_model_id"),
    )
