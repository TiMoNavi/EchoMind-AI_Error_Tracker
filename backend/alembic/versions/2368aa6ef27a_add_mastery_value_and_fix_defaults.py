"""add mastery_value and fix defaults

Revision ID: 2368aa6ef27a
Revises:
Create Date: 2026-02-22 20:30:00.000000
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = '2368aa6ef27a'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Student: 4个雷达字段添加 server_default
    for col in ('formula_memory_rate', 'model_identify_rate', 'calculation_accuracy', 'reading_accuracy'):
        op.alter_column('students', col, server_default=sa.text('0'))

    # StudentMastery: 添加 mastery_value 字段
    op.add_column('student_mastery', sa.Column('mastery_value', sa.Float(), server_default=sa.text('0'), nullable=False))


def downgrade() -> None:
    op.drop_column('student_mastery', 'mastery_value')

    for col in ('formula_memory_rate', 'model_identify_rate', 'calculation_accuracy', 'reading_accuracy'):
        op.alter_column('students', col, server_default=None)
