"""CommunityService — 需求投票 + 反馈 CRUD"""
import uuid

from fastapi import HTTPException, status
from sqlalchemy import select, func, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.community import FeatureRequest, Vote, Feedback


class CommunityService:
    """社区功能业务逻辑"""

    # ── FeatureRequest ──────────────────────────────────

    async def list_requests(
        self, db: AsyncSession, student_id: uuid.UUID,
        offset: int = 0, limit: int = 20,
    ) -> tuple[list[dict], int]:
        """分页列表，按 vote_count 降序。返回 (items, total)。"""
        # total
        count_q = select(func.count()).select_from(FeatureRequest)
        total = (await db.execute(count_q)).scalar() or 0

        # items
        q = (
            select(FeatureRequest)
            .order_by(FeatureRequest.vote_count.desc(), FeatureRequest.created_at.desc())
            .offset(offset).limit(limit)
        )
        rows = (await db.execute(q)).scalars().all()

        # 批量查当前用户的投票
        if rows:
            req_ids = [r.id for r in rows]
            voted_q = select(Vote.request_id).where(
                Vote.student_id == student_id,
                Vote.request_id.in_(req_ids),
            )
            voted_set = set((await db.execute(voted_q)).scalars().all())
        else:
            voted_set = set()

        items = [self._request_to_dict(r, r.id in voted_set) for r in rows]
        return items, total

    async def create_request(
        self, db: AsyncSession, student_id: uuid.UUID,
        title: str, description: str, tag: str | None,
    ) -> dict:
        """提交需求。"""
        fr = FeatureRequest(
            student_id=student_id,
            title=title,
            description=description,
            tag=tag,
        )
        db.add(fr)
        await db.commit()
        await db.refresh(fr)
        return self._request_to_dict(fr, voted=False)

    # ── Vote ────────────────────────────────────────────

    async def vote(
        self, db: AsyncSession, student_id: uuid.UUID, request_id: uuid.UUID,
    ) -> dict:
        """投票（幂等：重复投票不报错）。"""
        fr = await self._get_request(db, request_id)

        # 检查是否已投
        existing = await db.execute(
            select(Vote).where(
                Vote.student_id == student_id,
                Vote.request_id == request_id,
            )
        )
        if existing.scalar_one_or_none():
            return {"request_id": str(request_id), "vote_count": fr.vote_count, "voted": True}

        # 新增投票 + 原子更新 vote_count
        db.add(Vote(student_id=student_id, request_id=request_id))
        fr.vote_count = FeatureRequest.vote_count + 1
        await db.commit()
        await db.refresh(fr)
        return {"request_id": str(request_id), "vote_count": fr.vote_count, "voted": True}

    async def unvote(
        self, db: AsyncSession, student_id: uuid.UUID, request_id: uuid.UUID,
    ) -> dict:
        """取消投票（幂等：未投票不报错）。"""
        fr = await self._get_request(db, request_id)

        result = await db.execute(
            delete(Vote).where(
                Vote.student_id == student_id,
                Vote.request_id == request_id,
            )
        )
        if result.rowcount > 0:
            fr.vote_count = FeatureRequest.vote_count - 1
            await db.commit()
            await db.refresh(fr)

        return {"request_id": str(request_id), "vote_count": fr.vote_count, "voted": False}

    # ── Feedback ────────────────────────────────────────

    async def list_feedback(
        self, db: AsyncSession, offset: int = 0, limit: int = 20,
    ) -> tuple[list[dict], int]:
        """反馈列表，按时间倒序。"""
        count_q = select(func.count()).select_from(Feedback)
        total = (await db.execute(count_q)).scalar() or 0

        q = (
            select(Feedback)
            .order_by(Feedback.created_at.desc())
            .offset(offset).limit(limit)
        )
        rows = (await db.execute(q)).scalars().all()
        items = [self._feedback_to_dict(f) for f in rows]
        return items, total

    async def create_feedback(
        self, db: AsyncSession, student_id: uuid.UUID,
        content: str, feedback_type: str,
    ) -> dict:
        """提交反馈。"""
        fb = Feedback(
            student_id=student_id,
            content=content,
            feedback_type=feedback_type,
        )
        db.add(fb)
        await db.commit()
        await db.refresh(fb)
        return self._feedback_to_dict(fb)

    # ── 私有方法 ────────────────────────────────────────

    async def _get_request(self, db: AsyncSession, request_id: uuid.UUID) -> FeatureRequest:
        result = await db.execute(
            select(FeatureRequest).where(FeatureRequest.id == request_id)
        )
        fr = result.scalar_one_or_none()
        if fr is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="需求不存在")
        return fr

    @staticmethod
    def _request_to_dict(fr: FeatureRequest, voted: bool) -> dict:
        return {
            "id": str(fr.id),
            "title": fr.title,
            "description": fr.description,
            "vote_count": fr.vote_count,
            "tag": fr.tag,
            "student_id": str(fr.student_id),
            "voted": voted,
            "created_at": fr.created_at,
        }

    @staticmethod
    def _feedback_to_dict(fb: Feedback) -> dict:
        return {
            "id": str(fb.id),
            "content": fb.content,
            "feedback_type": fb.feedback_type,
            "student_id": str(fb.student_id),
            "created_at": fb.created_at,
        }
