"""StudentMastery — 表4：学生掌握度（核心状态表）"""
import uuid
from datetime import datetime

from sqlalchemy import String, SmallInteger, Integer, Boolean, DateTime, ForeignKey, UniqueConstraint, Index, func
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class StudentMastery(Base):
    __tablename__ = "student_mastery"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("students.id"), nullable=False)
    target_type: Mapped[str] = mapped_column(String(10), nullable=False)  # 'kp' or 'model'
    target_id: Mapped[str] = mapped_column(String(50), nullable=False)

    current_level: Mapped[int] = mapped_column(SmallInteger, default=0)
    peak_level: Mapped[int] = mapped_column(SmallInteger, default=0)
    last_active: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    error_count: Mapped[int] = mapped_column(Integer, default=0)
    correct_count: Mapped[int] = mapped_column(Integer, default=0)
    recent_results: Mapped[list[bool] | None] = mapped_column(ARRAY(Boolean), default=[])
    last_error_subtype: Mapped[str | None] = mapped_column(String(30))
    is_unstable: Mapped[bool] = mapped_column(Boolean, default=False)
    next_retest_date: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        UniqueConstraint("student_id", "target_type", "target_id"),
        Index("idx_mastery_student", "student_id"),
        Index("idx_mastery_level", "student_id", "current_level"),
    )
