"""StrategyService — 卷面策略生成服务（纯规则，零 LLM 成本）"""
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.regional_template import RegionalTemplate
from app.models.student import Student


class TemplateNotFoundError(Exception):
    """未找到匹配的地区模板"""
    pass


class StrategyService:
    """卷面策略生成服务"""

    async def generate(
        self,
        db: AsyncSession,
        student: Student,
        target_score: int | None = None,
    ) -> dict:
        """
        生成卷面策略。
        1. 确定目标分数
        2. 查找精确匹配的地区模板
        3. 如无精确匹配，找最近的分数档
        4. 组装 exam_strategy JSON
        5. 写入 student.exam_strategy
        """
        score = target_score or student.target_score

        # 精确匹配
        template = await self._find_template(db, student.region_id, student.subject, score)

        # 最近分数档匹配
        if not template:
            template = await self._find_nearest_template(db, student.region_id, student.subject, score)

        if not template:
            raise TemplateNotFoundError(
                f"未找到 {student.region_id}/{student.subject} 的模板"
            )

        # 组装策略
        strategy = {
            "target_score": score,
            "total_score": template.total_score,
            "region_id": template.region_id,
            "subject": template.subject,
            "template_id": template.id,
            "key_message": template.key_message,
            "vs_lower": template.vs_lower,
            "vs_higher": template.vs_higher,
            "question_strategies": template.question_strategies,
            "exam_structure": template.exam_structure,
            "diagnosis_path": template.diagnosis_path,
            "generated_at": datetime.now(timezone.utc).isoformat(),
        }

        # 写入学生记录
        student.exam_strategy = strategy
        if target_score:
            student.target_score = score
        await db.commit()
        await db.refresh(student)

        return strategy

    async def compare_strategies(
        self, old_strategy: dict, new_strategy: dict
    ) -> dict:
        """对比新旧策略，生成变更摘要"""
        old_map = {
            s["question_range"]: s for s in old_strategy.get("question_strategies", [])
        }
        new_map = {
            s["question_range"]: s for s in new_strategy.get("question_strategies", [])
        }

        upgraded = []
        downgraded = []
        attitude_rank = {"must": 3, "try": 2, "skip": 1}

        for qr, new_s in new_map.items():
            old_s = old_map.get(qr)
            if not old_s:
                continue
            old_rank = attitude_rank.get(old_s["attitude"], 0)
            new_rank = attitude_rank.get(new_s["attitude"], 0)
            if new_rank > old_rank:
                upgraded.append({
                    "question_range": qr,
                    "old_attitude": old_s["attitude"],
                    "new_attitude": new_s["attitude"],
                })
            elif new_rank < old_rank:
                downgraded.append({
                    "question_range": qr,
                    "old_attitude": old_s["attitude"],
                    "new_attitude": new_s["attitude"],
                })

        return {
            "upgraded_to_must": upgraded,
            "downgraded": downgraded,
            "key_message_diff": new_strategy.get("vs_lower", "") or "",
        }

    async def get_available_templates(
        self, db: AsyncSession, region_id: str, subject: str
    ) -> list[RegionalTemplate]:
        """获取指定地区/科目的所有模板"""
        result = await db.execute(
            select(RegionalTemplate)
            .where(
                RegionalTemplate.region_id == region_id,
                RegionalTemplate.subject == subject,
            )
            .order_by(RegionalTemplate.target_score)
        )
        return list(result.scalars().all())

    # ── 私有方法 ─────────────────────────────────────────────

    async def _find_template(
        self, db: AsyncSession, region_id: str, subject: str, score: int
    ) -> RegionalTemplate | None:
        """精确匹配分数档"""
        result = await db.execute(
            select(RegionalTemplate).where(
                RegionalTemplate.region_id == region_id,
                RegionalTemplate.subject == subject,
                RegionalTemplate.target_score == score,
            )
        )
        return result.scalar_one_or_none()

    async def _find_nearest_template(
        self, db: AsyncSession, region_id: str, subject: str, score: int
    ) -> RegionalTemplate | None:
        """最近分数档匹配（向下取整）"""
        result = await db.execute(
            select(RegionalTemplate)
            .where(
                RegionalTemplate.region_id == region_id,
                RegionalTemplate.subject == subject,
                RegionalTemplate.target_score <= score,
            )
            .order_by(RegionalTemplate.target_score.desc())
            .limit(1)
        )
        return result.scalar_one_or_none()
