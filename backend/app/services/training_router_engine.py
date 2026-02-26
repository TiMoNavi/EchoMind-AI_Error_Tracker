"""模型训练路由引擎（纯规则，不调 LLM）"""
from datetime import datetime, timedelta, timezone

# 步骤名称映射
STEP_NAMES = {
    1: "过程拆分+识别",
    2: "决策（公式选择）",
    3: "步骤（标准解题）",
    4: "陷阱（常见错误）",
    5: "回归（分步填空）",
    6: "变式（变式题）",
}

# 诊断错误子类型 → 入口 Step 映射
DIAGNOSIS_STEP_MAP = {
    "identify": 1,
    "decide": 2,
    "step": 3,
    "subject": 3,
    "substitution": 3,
    "calculation": 3,
}

# Level → 默认入口 Step（优先级4）
LEVEL_STEP_MAP = {0: 1, 1: 1, 2: 2, 3: 3, 4: 5, 5: 6}

# 久未练习阈值（天）
INACTIVE_THRESHOLD_DAYS = 14


class TrainingRouterEngine:
    """模型训练路由引擎（纯规则，不调 LLM）"""

    def determine_entry_step(
        self,
        source: str,
        current_level: int,
        peak_level: int,
        last_active: datetime | None,
        diagnosis_result: dict | None,
    ) -> int:
        """判定训练入口步骤，返回 Step 编号 1-6。按优先级从上到下匹配，命中即停。"""

        # 优先级1：从没学过
        if peak_level == 0:
            return 1

        # 优先级2：从错题诊断分流进来
        if source == "error_diagnosis" and diagnosis_result:
            subtype = diagnosis_result.get("error_subtype", "")
            return DIAGNOSIS_STEP_MAP.get(subtype, 1)

        # 优先级3：久未练习（非错题场景）
        if peak_level > 0 and last_active is not None:
            now = datetime.now(timezone.utc)
            if (now - last_active) > timedelta(days=INACTIVE_THRESHOLD_DAYS):
                # 久未练习 → Step 5（回归验证）
                return 5

        # 优先级4：正常路由（Level 即入口）
        return LEVEL_STEP_MAP.get(current_level, 1)

    def determine_next_step(
        self,
        current_step: int,
        step_passed: bool,
        entry_step: int,
        current_level: int,
    ) -> int | None:
        """判定下一步骤，返回 None 表示训练完成。"""

        if not step_passed:
            # Step 5 失败 → 退回（简化：退回 entry_step 或 Step 1）
            if current_step == 5:
                return max(entry_step, 1)
            # Step 6 失败 → 退回 Step 5
            if current_step == 6:
                return 5
            # 其他步骤失败 → 留在当前步骤（由 Service 层处理重试）
            return current_step

        # 通过后的正常推进
        next_map = {1: 2, 2: 3, 3: 4, 4: 5, 5: 6}
        if current_step == 6:
            return None  # 训练完成
        return next_map.get(current_step)

    def calculate_mastery_update(
        self,
        step_results: list[dict],
        current_mastery: float,
        current_level: int,
    ) -> dict:
        """根据训练结果计算掌握度更新。"""
        mastery = current_mastery

        for result in step_results:
            step = result.get("step", 0)
            passed = result.get("passed", False)
            # Step 1-2 权重 1.2，Step 3-6 权重 1.0
            weight = 1.2 if step <= 2 else 1.0

            if passed:
                reward = 10 * (1 - mastery / 100) * weight
                mastery += reward
            else:
                penalty = 15 * (mastery / 100) * weight
                mastery -= penalty

        mastery = max(5.0, min(100.0, mastery))
        new_level = self._mastery_to_level(mastery)

        return {
            "mastery_value": round(mastery, 2),
            "new_level": new_level,
            "previous_level": current_level,
            "previous_value": current_mastery,
        }

    @staticmethod
    def _mastery_to_level(value: float) -> int:
        if value == 0:
            return 0
        if value < 20:
            return 1
        if value < 40:
            return 2
        if value < 60:
            return 3
        if value < 80:
            return 4
        return 5

    @staticmethod
    def get_step_name(step: int) -> str:
        return STEP_NAMES.get(step, f"Step {step}")
