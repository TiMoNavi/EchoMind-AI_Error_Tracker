"""Alembic env — async migration support."""
import asyncio
from logging.config import fileConfig

from alembic import context
from sqlalchemy.ext.asyncio import create_async_engine

from app.core.config import settings
from app.core.database import Base

# import all models so metadata is populated
from app.models.student import Student  # noqa: F401
from app.models.knowledge_point import KnowledgePoint  # noqa: F401
from app.models.model import Model  # noqa: F401
from app.models.student_mastery import StudentMastery  # noqa: F401
from app.models.question import Question  # noqa: F401
from app.models.regional_template import RegionalTemplate  # noqa: F401
from app.models.upload_batch import UploadBatch  # noqa: F401
from app.models.confusion_group import ConfusionGroup  # noqa: F401
from app.models.diagnosis_session import DiagnosisSessionModel  # noqa: F401
from app.models.diagnosis_message import DiagnosisMessageModel  # noqa: F401
from app.models.learning_session import LearningSessionModel  # noqa: F401
from app.models.learning_message import LearningMessageModel  # noqa: F401
from app.models.training_session import TrainingSessionModel  # noqa: F401
from app.models.training_message import TrainingMessageModel  # noqa: F401
from app.models.training_step_result import TrainingStepResultModel  # noqa: F401

config = context.config
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata


def run_migrations_offline():
    context.configure(url=settings.database_url, target_metadata=target_metadata, literal_binds=True)
    with context.begin_transaction():
        context.run_migrations()


def do_run_migrations(connection):
    context.configure(connection=connection, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()


async def run_migrations_online():
    engine = create_async_engine(settings.database_url)
    async with engine.connect() as conn:
        await conn.run_sync(do_run_migrations)
    await engine.dispose()


if context.is_offline_mode():
    run_migrations_offline()
else:
    asyncio.run(run_migrations_online())
