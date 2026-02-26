"""Strategy router — 卷面策略端点"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.student import Student
from app.schemas.strategy import (
    StrategyGenerateRequest,
    StrategyResponse,
    StrategyData,
    TargetScoreUpdateRequest,
    TargetScoreUpdateResponse,
    StrategyChanges,
    TemplateListResponse,
)
from app.services.strategy_service import StrategyService, TemplateNotFoundError

router = APIRouter(prefix="/strategy", tags=["卷面策略"])
_svc = StrategyService()


@router.post("/generate", response_model=StrategyData)
async def generate_strategy(
    req: StrategyGenerateRequest = StrategyGenerateRequest(),
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """生成/重新生成卷面策略"""
    try:
        strategy = await _svc.generate(db, user, req.target_score)
    except TemplateNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    return strategy


@router.get("", response_model=StrategyResponse)
async def get_strategy(
    user: Student = Depends(get_current_user),
):
    """获取当前用户的卷面策略"""
    if not user.exam_strategy:
        return {"has_strategy": False, "strategy": None}
    return {"has_strategy": True, "strategy": user.exam_strategy}


@router.put("/target-score", response_model=TargetScoreUpdateResponse)
async def update_target_score(
    req: TargetScoreUpdateRequest,
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """修改目标分数并重新生成策略"""
    old_score = user.target_score
    old_strategy = user.exam_strategy or {}

    try:
        new_strategy = await _svc.generate(db, user, req.new_target_score)
    except TemplateNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))

    changes = await _svc.compare_strategies(old_strategy, new_strategy)

    return {
        "old_target_score": old_score,
        "new_target_score": req.new_target_score,
        "strategy": new_strategy,
        "changes": changes,
    }


@router.get("/templates", response_model=TemplateListResponse)
async def list_templates(
    user: Student = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取当前用户所在地区可用的模板列表"""
    templates = await _svc.get_available_templates(db, user.region_id, user.subject)
    return {
        "region_id": user.region_id,
        "subject": user.subject,
        "available_scores": [t.target_score for t in templates],
    }
