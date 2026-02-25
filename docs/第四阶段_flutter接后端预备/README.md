# 第四阶段：Flutter 接后端预备

## 概述

本阶段为 Claymorphism 美化完成后的 21 个 Flutter 页面生成「接入手册」级别文档。后端开发者拿到这份文档后，能直接理解每个页面需要什么数据、什么格式、什么接口。

## 已完成的前端预备工作

### 数据模型（`lib/shared/models/`）

所有模型均包含：`const` 构造函数、`fromJson` 工厂方法、`toJson` 方法。

| 文件 | 模型类 |
|------|--------|
| `home_models.dart` | HomeDashboard, Recommendation, RecentUpload |
| `profile_models.dart` | UserProfile, LearningStats |
| `prediction_models.dart` | PredictionScore, PriorityModelItem, ScorePathEntry |
| `weekly_review_models.dart` | WeeklyReview, DailyScore, WeeklyProgress, NextWeekFocus |
| `question_aggregate_models.dart` | QuestionAggregate, ExamAnalysis, QuestionHistory |
| `question_detail_models.dart` | QuestionDetail, QuestionRelation |
| `upload_history_models.dart` | UploadRecord, UploadDateGroup |
| `model_detail_models.dart` | ModelDetail, FunnelLayer |
| `knowledge_detail_models.dart` | KnowledgeDetail, ConceptTestRecord, RelatedModel |
| `shared_detail_models.dart` | TrainingRecord, PrerequisiteKnowledge, RelatedQuestion |
| `memory_models.dart` | MemoryDashboard, CardCategory |
| `flashcard_models.dart` | Flashcard, FlashcardSession |
| `community_models.dart` | CommunityRequest |
| `global_models.dart` | TreeNode, ExamRecord, HeatmapQuestion |
| `models.dart` | 统一导出（barrel export） |

### 三态组件（`lib/shared/widgets/`）

| 文件 | 组件 | 用途 |
|------|------|------|
| `clay_loading_state.dart` | ClayLoadingState | 骨架屏加载动画 |
| `clay_error_state.dart` | ClayErrorState | 错误状态 + 重试按钮 |
| `clay_empty_state.dart` | ClayEmptyState | 空数据状态 |
| `async_data_wrapper.dart` | AsyncDataWrapper\<T\> | 泛型包装器，自动切换四态 |

---

## 21 个页面说明文档索引

| 序号 | 文档 | 路由 | 页面名 | 数据模型 |
|------|------|------|--------|----------|
| 01 | [首页](21个flutter页面的分别说明文档/01_home_首页.md) | `/` | home | `home_models.dart` |
| 02 | [社区](21个flutter页面的分别说明文档/02_community_社区.md) | `/community` | community | `community_models.dart` |
| 03 | [社区详情](21个flutter页面的分别说明文档/03_community-detail_社区详情.md) | `/community-detail` | community-detail | `community_models.dart` |
| 04 | [全局知识点](21个flutter页面的分别说明文档/04_global-knowledge_全局知识点.md) | `/global-knowledge` | global-knowledge | `global_models.dart` |
| 05 | [全局模型](21个flutter页面的分别说明文档/05_global-model_全局模型.md) | `/global-model` | global-model | `global_models.dart` |
| 06 | [全局高考卷](21个flutter页面的分别说明文档/06_global-exam_全局高考卷.md) | `/global-exam` | global-exam | `global_models.dart` |
| 07 | [记忆](21个flutter页面的分别说明文档/07_memory_记忆.md) | `/memory` | memory | `memory_models.dart` |
| 08 | [闪卡复习](21个flutter页面的分别说明文档/08_flashcard-review_闪卡复习.md) | `/flashcard-review` | flashcard-review | `flashcard_models.dart` |
| 09 | [单题聚合](21个flutter页面的分别说明文档/09_question-aggregate_单题聚合.md) | `/question-aggregate` | question-aggregate | `question_aggregate_models.dart` |
| 10 | [题目详情](21个flutter页面的分别说明文档/10_question-detail_题目详情.md) | `/question-detail` | question-detail | `question_detail_models.dart` |
| 11 | [AI诊断](21个flutter页面的分别说明文档/11_ai-diagnosis_AI诊断.md) | `/ai-diagnosis` | ai-diagnosis | `chat_message.dart` |
| 12 | [模型详情](21个flutter页面的分别说明文档/12_model-detail_模型详情.md) | `/model-detail` | model-detail | `model_detail_models.dart` |
| 13 | [模型训练](21个flutter页面的分别说明文档/13_model-training_模型训练.md) | `/model-training` | model-training | `chat_message.dart` |
| 14 | [知识点详情](21个flutter页面的分别说明文档/14_knowledge-detail_知识点详情.md) | `/knowledge-detail` | knowledge-detail | `knowledge_detail_models.dart` |
| 15 | [知识点学习](21个flutter页面的分别说明文档/15_knowledge-learning_知识点学习.md) | `/knowledge-learning` | knowledge-learning | `chat_message.dart` |
| 16 | [预测中心](21个flutter页面的分别说明文档/16_prediction-center_预测中心.md) | `/prediction-center` | prediction-center | `prediction_models.dart` |
| 17 | [上传历史](21个flutter页面的分别说明文档/17_upload-history_上传历史.md) | `/upload-history` | upload-history | `upload_history_models.dart` |
| 18 | [周复盘](21个flutter页面的分别说明文档/18_weekly-review_周复盘.md) | `/weekly-review` | weekly-review | `weekly_review_models.dart` |
| 19 | [我的](21个flutter页面的分别说明文档/19_profile_我的.md) | `/profile` | profile | `profile_models.dart` |
| 20 | [上传菜单](21个flutter页面的分别说明文档/20_upload-menu_上传菜单.md) | `/upload-menu` | upload-menu | 无 |
| 21 | [学习策略](21个flutter页面的分别说明文档/21_register-strategy_学习策略.md) | `/register-strategy` | register-strategy | 无 |

---

## 文档结构

每个页面文档包含以下章节：

1. **当前状态** — 第四阶段状态标识
2. **路由标识** — go_router 路由路径
3. **组件树** — 页面 widget 层级结构
4. **页面截图** — 截图占位（待补充）
5. **组件详情** — 每个组件的功能说明、硬编码值、数据模型、API 字段
6. **数据模型** — 完整的 Dart 模型类定义
7. **API 接口清单** — RESTful 接口表格
8. **接入示例** — 可直接参考的 Dart 代码片段
9. **页面跳转** — 路由跳转关系

## 相关文件

- [第四阶段规划文档](第四阶段规划_页面说明文档生成.md)
