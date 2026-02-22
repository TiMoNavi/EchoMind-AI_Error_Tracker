"""Student model — 表1"""
import uuid
from datetime import datetime

from sqlalchemy import String, Integer, Float, DateTime, func
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Student(Base):
    __tablename__ = "students"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    phone: Mapped[str] = mapped_column(String(20), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(128), nullable=False)
    nickname: Mapped[str | None] = mapped_column(String(50))
    avatar_url: Mapped[str | None] = mapped_column(String(500))

    # 注册信息
    region_id: Mapped[str] = mapped_column(String(30), nullable=False)
    subject: Mapped[str] = mapped_column(String(20), nullable=False)
    target_score: Mapped[int] = mapped_column(Integer, nullable=False)

    # 卷面策略
    exam_strategy: Mapped[dict | None] = mapped_column(JSONB)

    # 三维画像
    formula_memory_rate: Mapped[float] = mapped_column(Float, default=0)
    model_identify_rate: Mapped[float] = mapped_column(Float, default=0)
    calculation_accuracy: Mapped[float] = mapped_column(Float, default=0)
    reading_accuracy: Mapped[float] = mapped_column(Float, default=0)

    # 闭环统计
    total_closures_today: Mapped[int] = mapped_column(Integer, default=0)
    total_closures_week: Mapped[int] = mapped_column(Integer, default=0)

    # 预测
    predicted_score: Mapped[float | None] = mapped_column(Float)
    last_prediction_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
