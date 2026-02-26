"""add regional_template message fields (key_message, vs_lower, vs_higher)

Revision ID: b2c3d4e5f6g7
Revises: a1b2c3d4e5f6
Create Date: 2026-02-26 06:00:00.000000
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = "b2c3d4e5f6g7"
down_revision: Union[str, None] = "a1b2c3d4e5f6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("regional_templates", sa.Column("key_message", sa.Text(), nullable=True))
    op.add_column("regional_templates", sa.Column("vs_lower", sa.Text(), nullable=True))
    op.add_column("regional_templates", sa.Column("vs_higher", sa.Text(), nullable=True))


def downgrade() -> None:
    op.drop_column("regional_templates", "vs_higher")
    op.drop_column("regional_templates", "vs_lower")
    op.drop_column("regional_templates", "key_message")
