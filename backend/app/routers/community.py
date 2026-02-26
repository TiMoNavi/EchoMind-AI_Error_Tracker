"""Community router — 需求投票 + 反馈"""
import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.community import (
    FeatureRequestCreate,
    FeatureRequestResponse,
    VoteResponse,
    FeedbackCreate,
    FeedbackResponse,
)
from app.services.community_service import CommunityService

router = APIRouter(prefix="/community", tags=["社区"])
_svc = CommunityService()


@router.get("/requests", response_model=dict)
async def list_requests(
    offset: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """需求列表（分页，按投票数排序）"""
    items, total = await _svc.list_requests(db, user.id, offset, limit)
    return {"items": items, "total": total}


@router.post("/requests", response_model=FeatureRequestResponse, status_code=201)
async def create_request(
    req: FeatureRequestCreate,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """提交需求"""
    return await _svc.create_request(db, user.id, req.title, req.description, req.tag)


@router.post("/requests/{request_id}/vote", response_model=VoteResponse)
async def vote_request(
    request_id: uuid.UUID,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """投票"""
    return await _svc.vote(db, user.id, request_id)


@router.delete("/requests/{request_id}/vote", response_model=VoteResponse)
async def unvote_request(
    request_id: uuid.UUID,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """取消投票"""
    return await _svc.unvote(db, user.id, request_id)


@router.get("/feedback", response_model=dict)
async def list_feedback(
    offset: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """反馈列表"""
    items, total = await _svc.list_feedback(db, offset, limit)
    return {"items": items, "total": total}


@router.post("/feedback", response_model=FeedbackResponse, status_code=201)
async def create_feedback(
    req: FeedbackCreate,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """提交反馈"""
    return await _svc.create_feedback(db, user.id, req.content, req.feedback_type)
