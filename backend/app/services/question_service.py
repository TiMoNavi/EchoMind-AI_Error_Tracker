"""Question service."""
import uuid
from collections import defaultdict

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.question import Question
from app.models.model import Model
from app.models.knowledge_point import KnowledgePoint
from app.schemas.question import QuestionUploadRequest, QuestionResponse, QuestionDetailResponse, HistoryDateGroup, AggregateItem
from app.services.mastery_service import update_mastery, update_student_dimensions, update_predicted_score


async def create_question(db: AsyncSession, req: QuestionUploadRequest, student_id: uuid.UUID) -> QuestionResponse:
    q = Question(
        student_id=student_id, image_url=req.image_url, is_correct=req.is_correct,
        source=req.source, primary_model_id=req.primary_model_id, related_kp_ids=req.related_kp_ids,
    )
    db.add(q)

    # 如果有正误判断，更新掌握度
    if req.is_correct is not None and q.primary_model_id:
        await update_mastery(db, student_id, "model", q.primary_model_id, req.is_correct)
    if req.is_correct is not None and q.related_kp_ids:
        for kp_id in q.related_kp_ids:
            await update_mastery(db, student_id, "kp", kp_id, req.is_correct)

    # 聚合更新 Student 四维能力 + 预测分数
    if req.is_correct is not None:
        await update_student_dimensions(db, student_id)
        await update_predicted_score(db, student_id)

    await db.commit()
    await db.refresh(q)
    return QuestionResponse(
        id=str(q.id), image_url=q.image_url, is_correct=q.is_correct,
        source=q.source, diagnosis_status=q.diagnosis_status, created_at=q.created_at,
    )


async def get_history(db: AsyncSession, student_id: uuid.UUID) -> list[HistoryDateGroup]:
    result = await db.execute(
        select(Question).where(Question.student_id == student_id).order_by(Question.created_at.desc())
    )
    rows = result.scalars().all()

    groups: dict[str, list] = defaultdict(list)
    for q in rows:
        date_key = q.created_at.strftime("%Y-%m-%d")
        groups[date_key].append(QuestionResponse(
            id=str(q.id), image_url=q.image_url, is_correct=q.is_correct,
            source=q.source, diagnosis_status=q.diagnosis_status, created_at=q.created_at,
        ))

    return [HistoryDateGroup(date=d, questions=qs) for d, qs in groups.items()]


async def get_question_detail(db: AsyncSession, question_id: str, student_id: uuid.UUID) -> QuestionDetailResponse | None:
    result = await db.execute(
        select(Question).where(Question.id == question_id, Question.student_id == student_id)
    )
    q = result.scalar_one_or_none()
    if not q:
        return None
    return QuestionDetailResponse(
        id=str(q.id), image_url=q.image_url, is_correct=q.is_correct,
        source=q.source, diagnosis_status=q.diagnosis_status,
        diagnosis_result=q.diagnosis_result, created_at=q.created_at,
        primary_model_id=q.primary_model_id, related_kp_ids=q.related_kp_ids,
    )


async def get_aggregate(db: AsyncSession, student_id: uuid.UUID, group_by: str) -> list[AggregateItem]:
    """按模型或知识点聚合错题分布。"""
    result = await db.execute(
        select(Question).where(Question.student_id == student_id)
    )
    questions = result.scalars().all()

    counts: dict[str, dict] = defaultdict(lambda: {"total": 0, "error_count": 0})

    if group_by == "model":
        for q in questions:
            if q.primary_model_id:
                counts[q.primary_model_id]["total"] += 1
                if q.is_correct is False:
                    counts[q.primary_model_id]["error_count"] += 1
        # 获取名称
        if counts:
            rows = await db.execute(select(Model.id, Model.name).where(Model.id.in_(counts.keys())))
            name_map = {r.id: r.name for r in rows.all()}
        else:
            name_map = {}
    else:  # kp
        for q in questions:
            for kp_id in (q.related_kp_ids or []):
                counts[kp_id]["total"] += 1
                if q.is_correct is False:
                    counts[kp_id]["error_count"] += 1
        if counts:
            rows = await db.execute(select(KnowledgePoint.id, KnowledgePoint.name).where(KnowledgePoint.id.in_(counts.keys())))
            name_map = {r.id: r.name for r in rows.all()}
        else:
            name_map = {}

    return [
        AggregateItem(target_id=tid, target_name=name_map.get(tid, tid), total=c["total"], error_count=c["error_count"])
        for tid, c in sorted(counts.items(), key=lambda x: x[1]["error_count"], reverse=True)
    ]
