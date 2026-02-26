"""add learning session tables (learning_sessions + learning_messages)

Revision ID: c3d4e5f6g7h8
Revises: b2c3d4e5f6g7
Create Date: 2026-02-26 18:30:00.000000
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID

revision: str = "c3d4e5f6g7h8"
down_revision: Union[str, None] = "b2c3d4e5f6g7"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # learning_sessions 表
    op.create_table(
        "learning_sessions",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("student_id", UUID(as_uuid=True), sa.ForeignKey("students.id"), nullable=False),
        sa.Column("knowledge_point_id", sa.String(50), nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="active"),
        sa.Column("source", sa.String(30), nullable=False, server_default="self_study"),
        sa.Column("current_step", sa.Integer(), nullable=False, server_default=sa.text("1")),
        sa.Column("max_steps", sa.Integer(), nullable=False, server_default=sa.text("5")),
        sa.Column("mastery_before", sa.Float(), nullable=True),
        sa.Column("mastery_after", sa.Float(), nullable=True),
        sa.Column("level_before", sa.String(5), nullable=True),
        sa.Column("level_after", sa.String(5), nullable=True),
        sa.Column("system_prompt", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    op.create_index("idx_ls_student", "learning_sessions", ["student_id"])
    op.create_index("idx_ls_status", "learning_sessions", ["student_id", "status"])

    # learning_messages 表
    op.create_table(
        "learning_messages",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column(
            "session_id",
            UUID(as_uuid=True),
            sa.ForeignKey("learning_sessions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("role", sa.String(10), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("step", sa.Integer(), nullable=False),
        sa.Column("token_count", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    op.create_index("idx_learn_msg_session", "learning_messages", ["session_id", "created_at"])


def downgrade() -> None:
    op.drop_index("idx_learn_msg_session", table_name="learning_messages")
    op.drop_table("learning_messages")

    op.drop_index("idx_ls_status", table_name="learning_sessions")
    op.drop_index("idx_ls_student", table_name="learning_sessions")
    op.drop_table("learning_sessions")
