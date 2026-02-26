"""诊断提示词拼接引擎 — T019 by claude-4

依赖：
- claude-3: DiagnosisSessionModel / DiagnosisMessageModel (ORM)
- claude-2: LLMClient (app/core/llm_client.py)
"""
from __future__ import annotations

import uuid
from typing import TYPE_CHECKING

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.question import Question
from app.models.student import Student
from app.models.student_mastery import StudentMastery

if TYPE_CHECKING:
    pass

# ---------------------------------------------------------------------------
# 常量
# ---------------------------------------------------------------------------
MAX_ROUNDS = 5

_SYSTEM_PROMPT_TEMPLATE = """\
[角色定义]
你是 EchoMind AI 诊断助手，专门帮助高中生分析物理错题的错误根源。

[行为准则]
- 正向引导：永远不说"你不行"，只说"你还差一步"
- 最多进行 {max_rounds} 轮对话
- 对话节奏：快检→追问→深挖→确认→收敛
- 用高中生能理解的语言，避免学术术语

[题目信息]
学生做错了这道题：{question_summary}
涉及知识点：{related_knowledge_points}
涉及模型：{related_models}

[学生画像]
- 目标分数：{target_score}
- 卷面策略：{exam_strategy}
- 知识点掌握情况：{knowledge_mastery}
- 模型掌握情况：{model_mastery}
- 常见错误类型：{common_errors}

[诊断任务]
通过对话判断错误根源属于以下哪类：
1. 粗心/计算错误
2. 知识点不理解（基础概念/公式/条件不清楚）
3. 模型应用问题，子类：
   a. 识别错（不知道用哪个模型）
   b. 决策错（模型对但公式选错）
   c. 步骤错（公式对但执行出错）
   d. 主语错（公式对但对错了对象/过程）
   e. 代入错（公式结构对但物理量代入错）

额外检查维度：
- 学生这个式子对谁列的？对哪个过程列的？
- 这个字母代的是哪个物理量？是哪个过程的？

[输出格式]
诊断完成时，在最后一条回复中同时输出：

A. 学生可见的三段式话术（自然语言）：
   1. 【定位问题】指出具体错在哪一步
   2. 【说明可解决】肯定做对的部分，说明只差一步
   3. 【关联目标分数】解决后对分数的影响

B. 以 ```json 代码块包裹的 5W 证据 JSON：
{{
  "four_layer": {{
    "modeling": "pass|fail|unreached",
    "equation": "pass|fail|unreached",
    "execution": "pass|fail|unreached",
    "bottleneck_layer": "modeling|equation|execution",
    "bottleneck_detail": "具体描述"
  }},
  "root_category": "careless|knowledge_gap|model_application",
  "root_subcategory": "null|identify|decide|step|subject|substitution",
  "evidence_5w": {{
    "what_description": "...",
    "when_stage": "read|split|identify|select|target|equation|substitute|solve|check",
    "root_cause_id": "...",
    "ai_explanation": "...",
    "confidence": "confirmed|probable|guess"
  }},
  "next_action": {{
    "type": "knowledge_learning|model_training|careless_drill",
    "target_id": "kp_xxx 或 model_xxx",
    "message": "给学生的引导语"
  }}
}}
"""


class DiagnosisPromptBuilder:
    """诊断提示词拼接引擎"""

    async def build_system_prompt(
        self,
        question: Question,
        student: Student,
        mastery_records: list[StudentMastery],
        db: AsyncSession,
    ) -> str:
        """拼接完整 system prompt。

        Args:
            question: 当前错题 ORM 对象
            student: 当前学生 ORM 对象
            mastery_records: 该学生的掌握度记录列表
            db: 数据库会话（用于查询历史错因）
        """
        question_summary = self._build_question_summary(question)
        related_kps = self._format_knowledge_points(question)
        related_models = question.primary_model_id or "未标注"
        knowledge_mastery = self._format_mastery(mastery_records, "kp")
        model_mastery = self._format_mastery(mastery_records, "model")
        common_errors = await self._get_common_errors(student.id, db)
        exam_strategy = self._format_exam_strategy(student)

        return _SYSTEM_PROMPT_TEMPLATE.format(
            max_rounds=MAX_ROUNDS,
            question_summary=question_summary,
            related_knowledge_points=related_kps,
            related_models=related_models,
            target_score=student.target_score,
            exam_strategy=exam_strategy,
            knowledge_mastery=knowledge_mastery,
            model_mastery=model_mastery,
            common_errors=common_errors,
        )

    # ------------------------------------------------------------------
    # 内部辅助方法
    # ------------------------------------------------------------------

    @staticmethod
    def _build_question_summary(question: Question) -> str:
        """从 Question 提取题目摘要。"""
        parts: list[str] = []
        if question.image_url:
            parts.append(f"题目图片: {question.image_url}")
        if question.exam_question_number is not None:
            parts.append(f"题号: 第{question.exam_question_number}题")
        if question.source:
            parts.append(f"来源: {question.source}")
        return "；".join(parts) if parts else "（题目信息待补充）"

    @staticmethod
    def _format_knowledge_points(question: Question) -> str:
        """格式化关联知识点列表。"""
        if question.related_kp_ids:
            return "、".join(question.related_kp_ids)
        return "未标注"

    @staticmethod
    def _format_mastery(records: list[StudentMastery], target_type: str) -> str:
        """格式化掌握度记录为可读文本。"""
        filtered = [r for r in records if r.target_type == target_type]
        if not filtered:
            return "暂无数据"
        lines: list[str] = []
        for r in filtered[:10]:  # 最多展示 10 条，避免 prompt 过长
            level_desc = f"Lv{r.current_level}"
            mastery_pct = f"{r.mastery_value:.0f}%"
            lines.append(f"  - {r.target_id}: {level_desc} ({mastery_pct})")
        return "\n".join(lines)

    @staticmethod
    def _format_exam_strategy(student: Student) -> str:
        """格式化卷面策略 JSON 为可读文本。"""
        if not student.exam_strategy:
            return "未设置"
        strategy = student.exam_strategy
        if isinstance(strategy, dict):
            parts = [f"{k}: {v}" for k, v in strategy.items()]
            return "；".join(parts)
        return str(strategy)

    @staticmethod
    async def _get_common_errors(
        student_id: uuid.UUID, db: AsyncSession
    ) -> str:
        """查询该学生历史诊断结果，聚合常见错因。"""
        stmt = (
            select(Question.diagnosis_result)
            .where(
                Question.student_id == student_id,
                Question.diagnosis_result.isnot(None),
            )
            .order_by(Question.created_at.desc())
            .limit(10)
        )
        result = await db.execute(stmt)
        rows = result.scalars().all()

        if not rows:
            return "暂无历史诊断数据"

        error_types: dict[str, int] = {}
        for diag in rows:
            if isinstance(diag, dict):
                cat = diag.get("root_category", "unknown")
                sub = diag.get("root_subcategory")
                key = f"{cat}/{sub}" if sub else cat
                error_types[key] = error_types.get(key, 0) + 1

        if not error_types:
            return "暂无历史诊断数据"

        sorted_errors = sorted(error_types.items(), key=lambda x: x[1], reverse=True)
        return "、".join(f"{k}({v}次)" for k, v in sorted_errors[:5])
