# Claymorphism 风格美化 — 全页面任务规划

## 已完成

| # | 页面 | 文件数 | 状态 |
|---|------|--------|------|
| 01 | home (首页) | 6 | ✅ 已完成 |
| 02 | global_knowledge (全局知识点) | 3 | ✅ 已完成 |
| 03 | global_model (全局模型) | 3 | ✅ 已完成 |
| 04 | global_exam (全局高考卷) | 5 | ✅ 已完成 |
| 05 | upload_menu (上传页) | 3 | ✅ 已完成 |
| 06 | register_strategy (考试策略) | 3 | ✅ 已完成 |
| T01 | prediction_center (预测中心) | 6 | ✅ 已完成 |
| T02 | profile (个人中心) | 7 | ✅ 已完成 |
| T03 | weekly_review (周报) | 6 | ✅ 已完成 |
| T04 | question_aggregate (题目聚合) | 5 | ✅ 已完成 |
| T05 | question_detail (题目详情) | 6 | ✅ 已完成 |
| T06 | upload_history (上传历史) | 4 | ✅ 已完成 |
| T07 | model_detail (模型详情) | 6 | ✅ 已完成 |
| T08 | knowledge_detail (知识点详情) | 5 | ✅ 已完成 |
| T09 | ai_diagnosis (AI 诊断) | 2 | ✅ 已完成 |
| T10 | model_training (模型训练) | 4 | ✅ 已完成 |
| T11 | knowledge_learning (知识学习) | 4 | ✅ 已完成 |
| T12 | memory (记忆系统) | 4 | ✅ 已完成 |
| T13 | flashcard_review (闪卡复习) | 3 | ✅ 已完成 |
| T14 | community (社区) | 6 | ✅ 已完成 |

## 待美化 (14 个页面)

### 第一批：核心数据页 (高频使用)

| 任务 | 页面 | 涉及文件 | 改造要点 |
|------|------|----------|----------|
| T01 | prediction_center (预测中心) | prediction_center_page.dart, top_frame_widget.dart, score_card_widget.dart, trend_card_widget.dart, priority_model_list_widget.dart, score_path_table_widget.dart | 加 Blobs 背景；score_card 升级为 Hero Card (渐变背景+圆形进度环)；趋势图包裹 ClayCard；优先模型列表用 ClayCard+渐变图标球；路径表格用 Clay 内凹行 |
| T02 | profile (个人中心) | profile_page.dart, top_frame_widget.dart, user_info_card_widget.dart, learning_stats_widget.dart, target_score_card_widget.dart, three_row_navigation_widget.dart, two_row_navigation_widget.dart | 加 Blobs 背景；用户信息卡升级为 Hero Card (头像球+渐变)；统计行用 Clay Stat Orb；目标分卡用 ClayCard+进度条；导航行用 ClayCard+渐变图标 |
| T03 | weekly_review (周报) | weekly_review_page.dart, top_frame_widget.dart, weekly_dashboard_widget.dart, score_change_widget.dart, weekly_progress_widget.dart, next_week_focus_widget.dart | 加 Blobs 背景；仪表盘用 ClayCard+Nunito 大号数字；分数变化用渐变箭头+Clay 对比卡；进度/聚焦列表用 ClayCard |

### 第二批：题目详情链路

| 任务 | 页面 | 涉及文件 | 改造要点 |
|------|------|----------|----------|
| T04 | question_aggregate (题目聚合) | question_aggregate_page.dart, top_frame_widget.dart, single_question_dashboard_widget.dart, exam_analysis_widget.dart, question_history_list_widget.dart | 加 Blobs 背景；仪表盘用 ClayCard+Nunito 统计数字；考试分析用 ClayCard+标签药丸；历史列表用 ClayCard 行 |
| T05 | question_detail (题目详情) | question_detail_page.dart, top_frame_widget.dart, answer_result_widget.dart, question_source_widget.dart, question_content_widget.dart, question_relations_widget.dart | 加 Blobs 背景；答题结果用状态色 ClayCard (对/错/待诊断)；题目来源用 ClayCard+MUST 标签；题目内容/关联用 ClayCard |
| T06 | upload_history (上传历史) | upload_history_page.dart, top_frame_widget.dart, history_filter_widget.dart, history_record_list_widget.dart, history_date_scroll_widget.dart, history_panel_widget.dart, history_timeline_widget.dart | 加 Blobs 背景；筛选器用 Clay 内凹药丸；记录列表用 ClayCard 行；日期滚动/时间线用 Clay 风格 |

### 第三批：知识/模型详情

| 任务 | 页面 | 涉及文件 | 改造要点 |
|------|------|----------|----------|
| T07 | model_detail (模型详情) | model_detail_page.dart, top_frame_widget.dart, mastery_dashboard_widget.dart, training_record_list_widget.dart, prerequisite_knowledge_list_widget.dart, related_question_list_widget.dart | 加 Blobs 背景；掌握度漏斗用 ClayCard+渐变条；训练记录用 ClayCard 行；前置知识/关联题用 ClayCard+渐变图标 |
| T08 | knowledge_detail (知识点详情) | knowledge_detail_page.dart, top_frame_widget.dart, mastery_dashboard_widget.dart, concept_test_records_widget.dart, related_models_widget.dart | 加 Blobs 背景；掌握度圆环用 ClayCard+Clay 色阶徽章；检测记录用 ClayCard 行；关联模型用 ClayCard |

### 第四批：AI 对话页 (聊天 UI)

| 任务 | 页面 | 涉及文件 | 改造要点 |
|------|------|----------|----------|
| T09 | ai_diagnosis (AI 诊断) | ai_diagnosis_page.dart, top_frame_widget.dart | 加 Blobs 背景；顶栏用 Nunito 标题；聊天气泡已有基础样式，微调圆角/阴影 |
| T10 | model_training (模型训练) | model_training_page.dart, top_frame_widget.dart, step1~step6 widgets, step_stage_nav_widget.dart | 加 Blobs 背景；阶段导航用 Clay 药丸；各 step widget 的卡片/按钮用 ClayCard+Clay Button |
| T11 | knowledge_learning (知识学习) | knowledge_learning_page.dart, top_frame_widget.dart, step1~step5 widgets, step_stage_nav_widget.dart | 加 Blobs 背景；阶段导航用 Clay 药丸；各 step widget 的卡片/按钮用 ClayCard+Clay Button |

### 第五批：辅助页面

| 任务 | 页面 | 涉及文件 | 改造要点 |
|------|------|----------|----------|
| T12 | memory (记忆系统) | memory_page.dart, top_frame_widget.dart, review_dashboard_widget.dart, card_category_list_widget.dart | 加 Blobs 背景；待复习数字用 Hero 大号 Nunito；统计行用 Clay Stat Orb；分类列表用 ClayCard+彩色标签球 |
| T13 | flashcard_review (闪卡复习) | flashcard_review_page.dart, top_frame_widget.dart, flashcard_widget.dart | 加 Blobs 背景；闪卡用 ClayCard (加强阴影层)；反馈按钮用 Clay Button (渐变+squish)；标签药丸用 Clay 风格 |
| T14 | community (社区) | community_page.dart, community_detail_page.dart, top_frame_and_tabs_widget.dart, board_my_requests_widget.dart, board_feature_boost_widget.dart, board_feedback_widget.dart | 加 Blobs 背景；Tab 栏用 Clay 内凹切换；需求卡片用 ClayCard+投票数高亮；提交按钮用 Clay Button |

## 每个任务的标准改造清单

对每个页面，按以下顺序执行：

1. **主页面文件** (`xxx_page.dart`)
   - 引入 `ClayBackgroundBlobs`，用 `Stack` 包裹 Blobs + 内容
   - `ListView` 加 `clipBehavior: Clip.none`
   - 调整 widget 间距 (section 间 24px，紧密组件间 10-12px)

2. **顶栏** (`top_frame_widget.dart`)
   - 标题用 `AppTheme.heading(size: 28)`
   - 如有 Tab 切换，用 Clay 内凹容器 (`shadowClayPressed` + `#EFEBF5`)
   - 激活 Tab 弹出白色 + 双层阴影

3. **内容 widget**
   - 所有卡片容器替换为 `ClayCard` (32px 圆角 + 4 层阴影)
   - 标题文字用 `AppTheme.heading(size: 18)`
   - 正文用 `AppTheme.body()`，标签用 `AppTheme.label()`
   - 数字/统计用 `GoogleFonts.nunito` w800/w900
   - 图标容器用渐变球 (gradient orb) + 彩色投影
   - 按钮用渐变背景 (`gradientPrimary`) + `shadowClayButton`
   - 列表项之间用 `SizedBox(height: 10)` 而非 `Divider`
   - 水平内边距统一 20px

4. **验证**
   - `getDiagnostics` 零错误
   - 视觉检查：确认 Blobs 可见、卡片有深度感、文字层次清晰

## 文件总计

- 已完成：6 个页面，约 20 个文件
- 待美化：14 个页面，约 65 个文件
- 预计每个任务改 4-7 个文件
