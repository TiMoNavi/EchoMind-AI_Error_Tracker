# 页面模块中文解析（与标注图编号对应）

说明：
- 对照文件：`page-annotations/README.md`
- 每页编号以 `annotated/<page>-annotated.png` 为准。

## index
1. `top-frame`：状态栏 + 页面大标题（主页）。
2. `top-dashboard`：今日统计 + 预测分入口 + 快速开始区域。
3. `recommendation-list`：推荐学习列表区域。
4. `recent-upload`：最近上传摘要区域。
5. `action-overlay`：右下角悬浮加号与上传弹层。

## community
1. `top-frame-and-tabs`：状态栏 + 页面标题 + 三选栏。
2. `board-my-requests`：我的需求板块。
3. `board-feature-boost`：新功能加速板块（切换后显示）。
4. `board-feedback`：改版建议板块（切换后显示）。

## flashcard-review
1. `top-frame`：状态栏 + 返回导航 + 复习进度条。
2. `flashcard`：闪卡本体（翻转）及记忆反馈按钮区域。

## global-exam
1. `top-frame`：状态栏 + 全局标题 + 顶部三选栏。
2. `exam-heatmap`：卷面热力图（按题号参数与掌握状态动态变化）。
3. `question-type-browser`：按题型浏览列表。
4. `recent-exams`：最近卷子列表。

## global-knowledge
1. `top-frame`：状态栏 + 全局标题 + 顶部三选栏。
2. `knowledge-tree`：可折叠展开的多层知识点树组件。

## global-model
1. `top-frame`：状态栏 + 全局标题 + 顶部三选栏。
2. `model-tree`：可折叠展开的多层模型树组件。

## knowledge-detail
1. `top-frame`：状态栏 + 返回导航。
2. `mastery-dashboard`：当前掌握度总结仪表区（含开始学习入口）。
3. `concept-test-records`：概念检测记录列表区。
4. `related-models`：关联模型列表区。

## knowledge-learning
1. `top-frame`：状态栏 + 返回导航。
2. `step-stage-nav`：顶部 5 阶段导航栏（可点击切换）。
3. `step-1-concept-present`：步骤 1 顶部 step 卡片。
4. `step-2-understanding-check`：步骤 2 顶部 step 卡片。
5. `step-3-discrimination-training`：步骤 3 顶部 step 卡片（默认）。
6. `step-4-practical-application`：步骤 4 顶部 step 卡片。
7. `step-5-concept-test`：步骤 5 顶部 step 卡片。
8. `action-overlay`：贴底 AI 输入区。
说明：步骤切换只更新顶部 step 卡片，下面对话区保持不变。

## memory
1. `top-frame`：状态栏 + 页面标题。
2. `review-dashboard`：顶部复习情况 dashboard 区域。
3. `card-category-list`：卡片分类列表区域。

## model-detail
1. `top-frame`：状态栏 + 返回导航。
2. `mastery-dashboard`：知识点/模型掌握程度 dashboard 区域。
3. `prerequisite-knowledge-list`：前置知识点列表区域。
4. `related-question-list`：相关题目列表区域。
5. `training-record-list`：训练记录列表区域。

## model-training
1. `top-frame`：状态栏 + 返回导航。
2. `step-stage-nav`：顶部阶段导航栏（可点击切换）。
3. `step-1-identification-training`：识别训练顶部 step 卡片。
4. `step-2-decision-training`：决策训练顶部 step 卡片（默认）。
5. `step-3-equation-training`：列式训练顶部 step 卡片。
6. `step-4-trap-analysis`：陷阱辨析顶部 step 卡片。
7. `step-5-complete-solve`：完整求解顶部 step 卡片。
8. `step-6-variation-training`：变式训练顶部 step 卡片。
9. `training-dialogue`：训练对话区（步骤切换时保持不变）。
10. `action-overlay`：贴底输入区。

## prediction-center
1. `top-frame`：状态栏 + 返回导航。
2. `score-card`：预测分数卡片。
3. `trend-card`：预测分数趋势卡片（折线图）。
4. `score-path-table`：提分路径表格区域。
5. `priority-model-list`：优先训练模型列表区域。

## profile
1. `top-frame`：状态栏 + 页面标题。
2. `user-info-card`：用户信息卡片。
3. `target-score-card`：目标分数卡片。
4. `three-row-navigation`：3 行跳转区域。
5. `two-row-navigation`：2 行跳转区域。
6. `learning-stats`：学习统计区域。

## question-aggregate
1. `top-frame`：状态栏 + 返回导航。
2. `single-question-dashboard`：单题统计 dashboard 区域。
3. `exam-analysis`：考情分析区域。
4. `question-history-list`：做过的题列表区域。

## question-detail
1. `top-frame`：状态栏 + 返回导航。
2. `question-content`：题库题目区域。
3. `answer-result`：答题结果区域（含诊断入口）。
4. `question-relations`：题目关联区域（模型/知识点）。
5. `question-source`：题目来源区域。

## upload-history
1. `top-frame`：状态栏 + 返回导航。
2. `history-panel`：整体历史区域（L1）。
3. `history-filter`：筛选器（L2）。
4. `history-date-scroll`：按日期滚动排序区（L2）。
5. `history-record-list`：下拉刷新做题历史列表区（L2）。

## weekly-review
1. `top-frame`：状态栏 + 返回导航。
2. `weekly-dashboard`：本周做题 dashboard 区域。
3. `score-change`：分数变化区域。
4. `weekly-progress`：本周进展区域。
5. `next-week-focus`：下周重点区域。

## 其他页面
1. `top-frame`：状态栏 + 标题/返回导航区。
2. `main-content`：页面核心内容区（如有 `action-overlay` 则额外包含底部输入/浮层）。
