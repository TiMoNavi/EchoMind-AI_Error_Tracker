"""模型训练提示词拼接引擎 — 6 步独立 system prompt 模板"""


class TrainingPromptBuilder:
    """每个 Step 有独立的 system prompt，会话创建/步骤切换时一次性拼接。"""

    def build_step_prompt(
        self,
        step: int,
        model_name: str,
        preset_content: dict,
        student_context: dict,
    ) -> str:
        """根据步骤编号选择对应模板并拼接"""
        templates = {
            1: self._build_step1_prompt,
            2: self._build_step2_prompt,
            3: self._build_step3_prompt,
            4: self._build_step4_prompt,
            5: self._build_step5_prompt,
            6: self._build_step6_prompt,
        }
        builder = templates.get(step, self._build_step1_prompt)
        return builder(model_name, preset_content, student_context)

    # ---- 通用片段 ----

    @staticmethod
    def _header(model_name: str, ctx: dict) -> str:
        return (
            f"你是 EchoMind 模型训练助手，正在帮助学生训练「{model_name}」。\n\n"
            "[行为准则]\n"
            "- 语气简洁严格，不放水\n"
            "- 每次回复不超过 3 句话\n"
            "- 正向引导：不说'你不行'，只说'再想想'\n\n"
            "[学生画像]\n"
            f"- 掌握度：L{ctx.get('current_level', 0)}（峰值 L{ctx.get('peak_level', 0)}）\n"
            f"- 来源：{ctx.get('source', 'self_study')}\n"
            f"- 不稳定：{'是' if ctx.get('is_unstable') else '否'}\n"
        )

    @staticmethod
    def _output_format() -> str:
        return (
            "\n[输出格式]\n"
            "- 正常对话：自然语言引导\n"
            "- 判定通过：回复末尾附加 [STEP_PASS]\n"
            "- 判定失败：回复末尾附加 [STEP_FAIL]\n"
            "- 需要重试：回复末尾附加 [NEED_RETRY]\n"
        )

    # ---- Step 1: 过程拆分+识别 ----

    def _build_step1_prompt(self, model_name: str, preset: dict, ctx: dict) -> str:
        question = preset.get("question_summary", "（题目待加载）")
        candidates = preset.get("candidate_models", [])
        candidates_str = "、".join(candidates) if candidates else "（候选模型待加载）"

        return (
            self._header(model_name, ctx)
            + "\n[训练任务 — Step 1 过程拆分+识别]\n"
            "引导学生完成：\n"
            "1. 拆分运动过程（这道题有几个阶段？）\n"
            "2. 确定每个过程的研究对象（主语是谁？）\n"
            "3. 从候选模型中选择正确的模型\n\n"
            f"[预设内容]\n题目：{question}\n候选模型：{candidates_str}\n\n"
            "[特殊规则]\n"
            "- 穷举所有选项 → 逐个排除 → 锁定正确路径\n"
            "- 如果学生是'主语错'进来的，重点引导'对谁列式？对哪个过程？'\n"
            + self._output_format()
        )

    # ---- Step 2: 决策（公式选择） ----

    def _build_step2_prompt(self, model_name: str, preset: dict, ctx: dict) -> str:
        formulas = preset.get("candidate_formulas", [])
        formulas_str = "\n".join(
            f"- {f.get('formula', '')}（{'适用' if f.get('applicable') else '不适用'}）"
            for f in formulas
        ) if formulas else "（公式列表待加载）"

        return (
            self._header(model_name, ctx)
            + "\n[训练任务 — Step 2 决策（公式选择）]\n"
            "在已确定的过程+主语下，引导学生穷举公式并排除：\n"
            "1. 展示可用公式列表\n"
            "2. 学生逐个判断是否适用\n"
            "3. 排除不适用的，锁定正确公式\n\n"
            f"[预设内容]\n公式列表：\n{formulas_str}\n"
            + self._output_format()
        )

    # ---- Step 3: 步骤（标准解题） ----

    def _build_step3_prompt(self, model_name: str, preset: dict, ctx: dict) -> str:
        steps = preset.get("standard_steps", [])
        steps_str = "\n".join(
            f"{i+1}. {s}" for i, s in enumerate(steps)
        ) if steps else "（标准步骤待加载）"

        return (
            self._header(model_name, ctx)
            + "\n[训练任务 — Step 3 步骤（标准解题）]\n"
            "讲解该模型的标准解题流程，确认学生理解每一步：\n"
            "1. 逐步展示标准解题步骤\n"
            "2. 每步让学生复述或确认理解\n"
            "3. 全部理解后判定通过\n\n"
            f"[预设内容]\n标准解题步骤：\n{steps_str}\n"
            + self._output_format()
        )

    # ---- Step 4: 陷阱（常见错误） ----

    def _build_step4_prompt(self, model_name: str, preset: dict, ctx: dict) -> str:
        traps = preset.get("common_traps", [])
        traps_str = "\n".join(
            f"- {t}" for t in traps
        ) if traps else "（常见陷阱待加载）"

        return (
            self._header(model_name, ctx)
            + "\n[训练任务 — Step 4 陷阱（常见错误）]\n"
            "展示该模型的常见错误，让学生判断对错：\n"
            "1. 逐个展示常见错误案例\n"
            "2. 学生判断每个案例是否正确\n"
            "3. 全部判断正确后通过\n\n"
            f"[预设内容]\n常见陷阱：\n{traps_str}\n"
            + self._output_format()
        )

    # ---- Step 5: 回归（分步填空） ----

    def _build_step5_prompt(self, model_name: str, preset: dict, ctx: dict) -> str:
        blanks = preset.get("fill_in_blanks", [])
        blanks_str = "\n".join(
            f"第{i+1}空：{b}" for i, b in enumerate(blanks)
        ) if blanks else "（填空题待加载）"

        return (
            self._header(model_name, ctx)
            + "\n[训练任务 — Step 5 回归（分步填空）]\n"
            "全流程验证，分步骤填空：\n"
            "1. 给出 3-5 步填空题\n"
            "2. 学生逐步填写\n"
            "3. AI 逐步判定 + 即时反馈\n\n"
            f"[预设内容]\n填空题：\n{blanks_str}\n\n"
            "[特殊规则]\n"
            "- 超 90 秒不输入触发'不敢写'检测，主动鼓励\n"
            "- 填空全对 → [STEP_PASS]\n"
            "- 关键步骤错误 → [STEP_FAIL]，需定位出错层\n"
            + self._output_format()
        )

    # ---- Step 6: 变式（变式题） ----

    def _build_step6_prompt(self, model_name: str, preset: dict, ctx: dict) -> str:
        variant = preset.get("variant_question", "（变式题待加载）")

        return (
            self._header(model_name, ctx)
            + "\n[训练任务 — Step 6 变式（变式题）]\n"
            "换场景/数值验证迁移能力：\n"
            "1. 给出变式题（换场景或数值）\n"
            "2. 学生完整解答\n"
            "3. AI 判定解答是否正确\n\n"
            f"[预设内容]\n变式题：{variant}\n\n"
            "[特殊规则]\n"
            "- 变式题对 → [STEP_PASS]，训练完成\n"
            "- 变式题错 → [STEP_FAIL]，降级处理\n"
            + self._output_format()
        )
