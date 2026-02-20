# Flutter前端需求规划（功能分区组件版，HTML范围）

## 0. 文档目标与范围
- 目标：将当前 HTML 原型转为可执行的 Flutter 前端需求规格。
- 规划方式：按功能分区拆分，而非代码细粒度拆分。
- 分层规则：`页面布局区(L1) -> 功能组件(L2) -> 列表项模板(L3，仅必要时)`。
- 页面范围：仅 `示例html前端` 的 18 个页面。

## 1. 分层标准与命名规范
## 1.1 分层定义
- L1（页面布局区）：页面的大功能区域，负责一类完整业务。
- L2（功能组件）：该区域内可独立开发/联调的业务模块。
- L3（列表项模板，可选）：仅用于“列表项/卡片项”这类重复结构，避免继续拆到按钮级。

## 1.2 命名规范
- L1 统一后缀：`...Region`
- L2 统一后缀：`...Module`
- L3 统一后缀：`...ItemTemplate`
- 例：
  - `TopDashboardRegion`
  - `RecommendationListModule`
  - `DemandCardItemTemplate`

## 1.3 粒度约束
- 允许每页 3-5 个 L1 分区，按页面布局实际决定。
- 禁止拆分到按钮/标签/图标级别作为独立组件。
- 只在“列表重复项”场景新增 L3。

## 2. 文档内接口类型约定
```ts
type PageRegionSpec = {
  page_id: string;               // html 文件名
  region_name: string;           // L1 分区名
  region_goal: string;           // 分区业务目标
  children_modules: string[];    // 包含的 L2 组件
}

type FunctionalModuleSpec = {
  module_name: string;           // L2 名称
  business_purpose: string;      // 业务职责
  inputs: string[];              // 展示或交互输入
  outputs: string[];             // 事件输出
  target_route?: string[];       // 触发跳转目标
}

type ItemTemplateSpec = {
  template_name: string;         // L3 名称
  used_by_module: string;        // 所属 L2
  fields: string[];              // 列表项字段
}
```

## 3. 固定复用组件（布局级，7个）
| 组件 | 定义 | 典型页面 |
|---|---|---|
| `TopFrameRegion` | 状态栏 + 顶栏标题/返回 + 可选子切换栏 | 几乎所有页面 |
| `BottomTabRegion` | 底部主导航栏（主页/全局/记忆/社区/我的） | `index.html`、`global-*`、`memory.html`、`community.html`、`profile.html` |
| `FilterSwitchRegion` | 筛选条、学科切换条、状态筛选条 | `global-knowledge.html`、`global-model.html`、`upload-history.html` |
| `ListTimelineRegion` | 分组列表、时间线列表、卡片列表容器 | `upload-history.html`、`question-aggregate.html`、`community.html` |
| `ChatTrainingRegion` | 对话区 + 输入区（学习/训练/诊断共形态） | `ai-diagnosis.html`、`model-training.html`、`knowledge-learning.html` |
| `ProgressStatusRegion` | 进度条、掌握状态、趋势图展示区 | `model-training.html`、`knowledge-learning.html`、`prediction-center.html` |
| `ActionOverlayRegion` | 悬浮操作入口 + 底部弹层/模态层 | `index.html` |

## 4. 页面功能分区组件树（18页）

## 4.1 `index.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `TopDashboardRegion` | `TodayStatsModule` | 展示今日/本周核心学习指标 | `today_closure_count`、`study_duration`、`week_closure_count` | 无 | - |
| `TopDashboardRegion` | `PredictionEntryModule` | 展示预测分入口与迷你趋势 | `predicted_score`、`target_score`、`score_trend_points[]` | 跳转 `prediction-center.html` | - |
| `TopDashboardRegion` | `QuickStartModule` | 一键进入当前最高优先任务 | `top_task_name`、`estimated_minutes` | 跳转 `model-training.html` | - |
| `RecommendationRegion` | `RecommendationListModule` | 展示推荐学习列表 | `recommendation_items[]` | 跳转 `ai-diagnosis.html` / `model-detail.html` / `knowledge-detail.html` | `RecommendationItemTemplate` |
| `RecentUploadRegion` | `RecentUploadSummaryModule` | 展示最近上传摘要与待诊断数量 | `recent_upload_summary`、`pending_diagnosis_count` | 跳转 `upload-history.html` | - |
| `ActionOverlayRegion` | `UploadFabModule` | 悬浮加号入口 | 无 | 打开上传菜单 | - |
| `ActionOverlayRegion` | `UploadMenuSheetModule` | 上传类型选择弹层 | `upload_type_options[]` | 跳转 `upload-menu.html`（占位） | `UploadMenuOptionTemplate` |
| `BottomTabRegion` | `MainTabBarModule` | 主导航切换 | `active_tab` | 主Tab跳转 | - |

## 4.2 `community.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `CommunityTopRegion` | `CommunityTitleModule` | 显示社区页标题 | `title` | 无 | - |
| `CommunityTopRegion` | `CommunityTabSwitchModule` | 三选栏切换：我的需求/新功能加速/改版建议 | `active_comm_tab` | 切换本页内容区 | - |
| `CommunityContentRegion` | `MyDemandBoardModule` | “我的需求”板块：提交入口 + 需求列表 | `demand_list[]` | 提交需求（本页动作） | `DemandCardItemTemplate` |
| `CommunityContentRegion` | `FeatureBoostBoardModule` | “新功能加速”板块内容/空状态 | `vote_items[]` 或空状态文案 | 本页交互 | - |
| `CommunityContentRegion` | `FeedbackBoardModule` | “改版建议”板块内容/空状态 | `feedback_items[]` 或空状态文案 | 本页交互 | - |
| `BottomTabRegion` | `MainTabBarModule` | 主导航切换 | `active_tab` | 主Tab跳转 | - |

## 4.3 `global-knowledge.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `GlobalTopSwitchRegion` | `GlobalSubTabModule` | 全局子Tab切换（知识点/模型/高考） | `active_global_tab` | 跳转 `global-model.html` / `global-exam.html` | - |
| `SubjectFilterRegion` | `SubjectSwitchModule` | 物理/数学切换 | `subject_options[]`、`active_subject` | 本页筛选切换 | - |
| `KnowledgeTreeRegion` | `KnowledgeChapterTreeModule` | 展示章/节/知识点树与掌握度 | `chapter_tree_data` | 跳转 `knowledge-detail.html` | `KnowledgePointItemTemplate` |
| `BottomTabRegion` | `MainTabBarModule` | 主导航切换 | `active_tab` | 主Tab跳转 | - |

## 4.4 `global-model.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `GlobalTopSwitchRegion` | `GlobalSubTabModule` | 全局子Tab切换 | `active_global_tab` | 跳转 `global-knowledge.html` / `global-exam.html` | - |
| `SubjectFilterRegion` | `SubjectSwitchModule` | 物理/数学切换 | `subject_options[]`、`active_subject` | 本页筛选切换 | - |
| `ModelTreeRegion` | `ModelChapterTreeModule` | 展示章/模型/子问题树与掌握度 | `model_tree_data` | 跳转 `model-detail.html` | `ModelNodeItemTemplate` |
| `BottomTabRegion` | `MainTabBarModule` | 主导航切换 | `active_tab` | 主Tab跳转 | - |

## 4.5 `global-exam.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `GlobalTopSwitchRegion` | `GlobalSubTabModule` | 全局子Tab切换 | `active_global_tab` | 跳转 `global-knowledge.html` / `global-model.html` | - |
| `ExamHeatmapRegion` | `ExamHeatmapLegendModule` | 展示热力图颜色含义 | `legend_items[]` | 无 | - |
| `ExamHeatmapRegion` | `ExamHeatmapGridModule` | 展示题号热力图并可点击题号 | `exam_heatmap_cells[]` | 跳转 `question-aggregate.html` | `ExamHeatmapCellTemplate` |
| `ExamBrowseRegion` | `QuestionTypeBrowseModule` | 按题型浏览入口（含上传卷子入口） | `question_type_groups[]` | 跳转 `question-aggregate.html` / `upload-menu.html`（占位） | `QuestionTypeItemTemplate` |
| `ExamBrowseRegion` | `RecentExamListModule` | 展示最近卷子列表 | `recent_exams[]` | 跳转 `upload-history.html` | `RecentExamItemTemplate` |
| `BottomTabRegion` | `MainTabBarModule` | 主导航切换 | `active_tab` | 主Tab跳转 | - |

## 4.6 `memory.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `ReviewEntryRegion` | `TodayReviewEntryModule` | 显示今日待复习数量并进入复习 | `today_review_count` | 跳转 `flashcard-review.html` | - |
| `MemoryStatsRegion` | `MemoryStatsModule` | 记忆统计（记住率/连续天数/累计） | `memory_stats` | 无 | - |
| `CardCategoryRegion` | `CardCategoryModule` | 卡片分类统计与管理入口 | `card_categories[]` | 本页交互 | `CardCategoryItemTemplate` |
| `BottomTabRegion` | `MainTabBarModule` | 主导航切换 | `active_tab` | 主Tab跳转 | - |

## 4.7 `profile.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `ProfileSummaryRegion` | `UserProfileModule` | 展示头像/昵称/基础资料 | `user_profile` | 无 | - |
| `ProfileSummaryRegion` | `TargetScoreModule` | 目标分数展示与修改入口 | `target_score` | 跳转 `register-strategy.html`（占位） | - |
| `ProfileMenuRegion` | `ProfileMenuListModule` | 功能菜单（上传历史、周复盘等） | `menu_entries[]` | 跳转 `upload-history.html` / `weekly-review.html` | `ProfileMenuItemTemplate` |
| `LearningStatsRegion` | `LearningStatsSummaryModule` | 学习统计摘要 | `learning_stats` | 无 | - |
| `BottomTabRegion` | `MainTabBarModule` | 主导航切换 | `active_tab` | 主Tab跳转 | - |

## 4.8 `upload-history.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `TopNavRegion` | `BackTitleNavModule` | 返回与标题 | `title` | 跳转 `index.html` | - |
| `UploadFilterRegion` | `UploadFilterSwitchModule` | 状态/类型筛选 | `filter_options[]`、`active_filter` | 本页筛选刷新 | - |
| `HistoryTimelineRegion` | `UploadHistoryTimelineModule` | 按日期分组展示上传记录 | `upload_history_groups[]` | 跳转 `question-detail.html` | `UploadHistoryItemTemplate` |

## 4.9 `question-aggregate.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `TopNavRegion` | `BackTitleNavModule` | 返回与题号标题 | `question_no_title` | 跳转 `global-exam.html` | - |
| `AggregateStatsRegion` | `QuestionAggregateStatsModule` | 展示做题数、正确率、预测得分 | `aggregate_stats` | 无 | - |
| `TagAttributeRegion` | `QuestionTagAttributeModule` | 显示态度标签与薄弱标签 | `attitude_tag`、`weak_tags[]` | 可选跳转 | - |
| `QuestionListRegion` | `QuestionRecordListModule` | 展示该题号下题目列表 | `question_records[]` | 跳转 `question-detail.html` | `QuestionRecordItemTemplate` |

## 4.10 `question-detail.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `TopNavRegion` | `BackTitleNavModule` | 返回与标题 | `title` | 跳转 `question-aggregate.html` | - |
| `QuestionDisplayRegion` | `QuestionContentModule` | 题图/题干展示 | `question_content` | 无 | - |
| `StatusTagRegion` | `QuestionStatusTagModule` | 对错状态、模型标签、知识点标签 | `status`、`model_tags[]`、`kp_tags[]` | 跳转 `model-detail.html` / `knowledge-detail.html` | - |
| `DiagnosisEntryRegion` | `DiagnosisEntryModule` | 进入诊断入口与提示 | `diagnosis_status` | 跳转 `ai-diagnosis.html` | - |
| `SourceInfoRegion` | `QuestionSourceInfoModule` | 来源卷子、时间等来源信息 | `source_info` | 无 | - |

## 4.11 `ai-diagnosis.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `TopNavRegion` | `BackTitleNavModule` | 返回与标题 | `title` | 跳转 `question-detail.html` | - |
| `QuestionReferenceRegion` | `DiagnosisQuestionRefModule` | 显示当前诊断题目引用信息 | `question_ref` | 无 | - |
| `DiagnosisConversationRegion` | `DiagnosisChatModule` | AI诊断对话过程展示 | `chat_messages[]` | 本页对话交互 | `ChatMessageItemTemplate` |
| `DiagnosisResultActionRegion` | `DiagnosisResultModule` | 展示诊断结论卡片 | `diagnosis_result` | 无 | - |
| `DiagnosisResultActionRegion` | `DiagnosisActionModule` | 训练/返回动作入口 | `action_buttons` | 跳转 `model-training.html` / `question-detail.html` | - |
| `InputRegion` | `DiagnosisInputModule` | 继续对话输入与发送 | `input_placeholder` | 本页提交事件 | - |

## 4.12 `model-detail.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `TopNavRegion` | `BackTitleNavModule` | 返回与标题 | `title` | 跳转 `global-model.html` | - |
| `MasteryTrainingRegion` | `ModelMasteryFunnelModule` | 显示模型掌握漏斗与当前层级 | `model_mastery_funnel` | 无 | - |
| `MasteryTrainingRegion` | `ModelTrainingEntryModule` | 开始训练入口 | `current_level` | 跳转 `model-training.html` | - |
| `PrerequisiteKnowledgeRegion` | `PrerequisiteKnowledgeModule` | 展示前置知识点列表 | `prerequisite_kp_list[]` | 跳转 `knowledge-detail.html` | `PrerequisiteKnowledgeItemTemplate` |
| `RelatedQuestionRegion` | `RelatedQuestionListModule` | 展示相关题目列表 | `related_questions[]` | 跳转 `question-detail.html` | `RelatedQuestionItemTemplate` |
| `TrainingHistoryRegion` | `TrainingHistoryModule` | 展示模型训练历史记录 | `training_history[]` | 无 | `TrainingHistoryItemTemplate` |

## 4.13 `model-training.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `TopNavRegion` | `BackTitleNavModule` | 返回与标题 | `title` | 跳转 `model-detail.html` | - |
| `ProgressStepRegion` | `ModelStepProgressModule` | 显示6步进度与当前步骤 | `step_progress`、`current_step` | 无 | - |
| `ProgressStepRegion` | `CurrentStepCardModule` | 当前步骤任务说明 | `step_prompt`、`step_hint` | 无 | - |
| `TrainingConversationRegion` | `ModelTrainingChatModule` | 训练对话与快捷回复 | `chat_messages[]`、`quick_replies[]` | 本页训练交互 | `QuickReplyItemTemplate` |
| `StepHistoryRegion` | `StepResultSummaryModule` | 展示已完成步骤结果摘要 | `completed_step_results[]` | 无 | `StepResultItemTemplate` |
| `InputRegion` | `ModelTrainingInputModule` | 输入框与发送动作 | `input_placeholder` | 本页提交事件 | - |

## 4.14 `knowledge-detail.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `TopNavRegion` | `BackTitleNavModule` | 返回与标题 | `title` | 跳转 `global-knowledge.html` | - |
| `MasteryLearningRegion` | `KnowledgeMasteryModule` | 显示知识点掌握状态 | `knowledge_mastery` | 无 | - |
| `MasteryLearningRegion` | `KnowledgeLearningEntryModule` | 进入知识点学习流 | `current_level` | 跳转 `knowledge-learning.html` | - |
| `ConceptRecordRegion` | `ConceptRecordListModule` | 展示概念检测记录 | `concept_test_records[]` | 无 | `ConceptRecordItemTemplate` |
| `RelatedModelRegion` | `RelatedModelListModule` | 展示关联模型列表 | `related_models[]` | 跳转 `model-detail.html` | `RelatedModelItemTemplate` |

## 4.15 `knowledge-learning.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `TopNavRegion` | `BackTitleNavModule` | 返回与标题 | `title` | 跳转 `knowledge-detail.html` | - |
| `ProgressStepRegion` | `KnowledgeStepProgressModule` | 显示5步进度与当前步骤 | `step_progress`、`current_step` | 无 | - |
| `ProgressStepRegion` | `CurrentStepCardModule` | 当前步骤讲解任务信息 | `step_prompt`、`step_focus` | 无 | - |
| `LearningConversationRegion` | `KnowledgeLearningChatModule` | 学习对话与快捷回复 | `chat_messages[]`、`quick_replies[]` | 本页学习交互 | `QuickReplyItemTemplate` |
| `CognitiveAidRegion` | `KnowledgeAidTableModule` | 对比表/辅助讲解内容 | `comparison_rows[]` | 无 | `ComparisonRowTemplate` |
| `InputRegion` | `KnowledgeLearningInputModule` | 输入框与发送动作 | `input_placeholder` | 本页提交事件 | - |

## 4.16 `flashcard-review.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `TopNavRegion` | `BackTitleNavModule` | 返回与标题 | `title` | 跳转 `memory.html` | - |
| `ReviewProgressRegion` | `FlashcardProgressModule` | 显示复习进度 | `current_index`、`total_count` | 无 | - |
| `FlashcardBodyRegion` | `FlashcardFlipModule` | 闪卡正反面展示与翻转 | `flashcard_front`、`flashcard_back` | 本页翻转事件 | - |
| `MemoryFeedbackRegion` | `FlashcardFeedbackModule` | 记忆反馈动作（忘了/记得/简单） | `feedback_options[]` | 本页评分事件 | - |

## 4.17 `prediction-center.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `TopNavRegion` | `BackTitleNavModule` | 返回与标题 | `title` | 跳转 `index.html` | - |
| `ScoreOverviewRegion` | `PredictedScoreOverviewModule` | 展示预测总分与目标差距 | `predicted_score`、`target_score` | 无 | - |
| `TrendAnalysisRegion` | `PredictionTrendModule` | 展示分数趋势图 | `trend_points[]` | 无 | - |
| `PathPriorityRegion` | `ScorePathModule` | 展示提分路径 | `score_path_items[]` | 跳转 `question-aggregate.html` | `ScorePathItemTemplate` |
| `PathPriorityRegion` | `PriorityModelModule` | 展示优先训练模型 | `priority_models[]` | 跳转 `model-detail.html` | `PriorityModelItemTemplate` |

## 4.18 `weekly-review.html`
| L1 分区 | L2 组件 | 业务职责 | 输入数据 | 输出动作/路由 | L3 |
|---|---|---|---|---|---|
| `TopNavRegion` | `BackTitleNavModule` | 返回与标题 | `title` | 跳转 `profile.html` | - |
| `WeeklyOverviewRegion` | `WeeklySummaryModule` | 展示本周总览数据 | `weekly_summary` | 无 | - |
| `ScoreChangeRegion` | `WeeklyScoreChangeModule` | 展示分数变化前后对比 | `score_before`、`score_after` | 无 | - |
| `WeeklyProgressRegion` | `WeeklyProgressListModule` | 展示本周进展条目 | `weekly_progress_items[]` | 无 | `WeeklyProgressItemTemplate` |
| `NextWeekFocusRegion` | `NextWeekFocusModule` | 展示下周重点与建议方向 | `next_week_focus_items[]` | 无 | `NextWeekFocusItemTemplate` |

## 5. Flutter 落地目录建议（按功能分区）
```text
lib/
  app/
    routing/
      app_routes.dart
      route_mapper.dart
  regions/
    top_frame/
    bottom_tab/
    filter_switch/
    list_timeline/
    chat_training/
    progress_status/
    action_overlay/
  pages/
    home/
      home_page.dart
      regions/
        top_dashboard_region.dart
        recommendation_region.dart
        recent_upload_region.dart
        action_overlay_region.dart
    community/
      community_page.dart
      regions/
        community_top_region.dart
        community_content_region.dart
    global_knowledge/
    global_model/
    global_exam/
    memory/
    profile/
    upload_history/
    question_aggregate/
    question_detail/
    ai_diagnosis/
    model_detail/
    model_training/
    knowledge_detail/
    knowledge_learning/
    flashcard_review/
    prediction_center/
    weekly_review/
  templates/
    recommendation_item_template.dart
    demand_card_item_template.dart
    upload_history_item_template.dart
    question_record_item_template.dart
```

## 6. 验收标准（本规划版）
1. 每个页面先定义 L1，再定义 L2；无按钮级组件清单。  
2. `community.html` 必须有层级：三选栏区 -> 三板块 -> 需求卡片项（L3）。  
3. `index.html` 必须包含五个功能区：信息仪表、推荐学习、最近上传、悬浮加号、底部导航。  
4. 固定复用组件保持 7 个，且都是布局级。  
5. 两份文档页面覆盖一致，均为 18 页。  

## 7. 默认项与限制
- 仅规划前端结构，不包含后端接口联调细则。  
- 被引用但缺失的页面保持占位：`upload-menu.html`、`register-strategy.html`。  
- 命名是规划规范，可在落地时按团队代码风格做等价映射。  
