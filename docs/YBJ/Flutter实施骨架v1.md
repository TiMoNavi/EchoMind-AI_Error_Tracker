# Flutter实施骨架 v1（供审核）

> 目标：先确认技术骨架，不急着写复杂业务逻辑。  
> 范围：依赖组合 + 目录结构 + 路由/页面骨架 + 每页核心模块。

---

## 1. 依赖组合（建议版）

## 1.1 必选依赖（第一天就装）
| 包名 | 用途 | 为什么适合当前项目 |
|---|---|---|
| `go_router` | 路由管理 | 页面多、跳转链路复杂（诊断后分流） |
| `flutter_riverpod` | 状态管理 | 适合多页面共享状态和Mock仓库 |
| `responsive_framework` | 多端适配 | 手机/平板/Web/桌面统一断点 |
| `flex_color_scheme` | 主题系统 | 快速做出统一且美观的设计系统 |
| `google_fonts` | 字体 | 提升视觉质感 |
| `fl_chart` | 图表 | 预测中心、周复盘趋势图 |
| `flutter_animate` | 页面动效 | 报告揭晓、卡片入场动效 |
| `dio` | 网络层占位 | 后续接后端可平滑迁移 |
| `shared_preferences` | 本地轻量存储 | 首登状态、筛选条件、缓存偏好 |
| `intl` | 时间/数字格式 | 周复盘、时间轴、分数展示 |

## 1.2 开发期依赖（建议同步上）
| 包名 | 用途 |
|---|---|
| `flutter_lints` | 代码规范 |
| `build_runner` | 代码生成 |
| `freezed` | 数据模型生成 |
| `freezed_annotation` | `freezed`注解 |
| `json_serializable` | JSON转换 |
| `json_annotation` | JSON注解 |

## 1.3 可选依赖（按页面需要再加）
| 包名 | 用途 |
|---|---|
| `flutter_chat_ui` | AI诊断/学习对话界面（可选，若不用就自定义气泡） |
| `flutter_svg` | 图标与插画 |
| `uuid` | 本地Mock数据ID生成 |

## 1.4 安装命令（草案）
```bash
flutter pub add go_router flutter_riverpod responsive_framework flex_color_scheme google_fonts fl_chart flutter_animate dio shared_preferences intl
flutter pub add --dev flutter_lints build_runner freezed json_serializable
flutter pub add freezed_annotation json_annotation
```

---

## 2. 推荐目录结构（Feature First + 可扩展）

```text
lib/
  main.dart
  bootstrap.dart

  app/
    app.dart
    router/
      app_router.dart
      route_names.dart
    shell/
      app_shell.dart
    theme/
      app_theme.dart
      app_tokens.dart
    adaptive/
      breakpoints.dart
      adaptive_scaffold.dart

  core/
    constants/
      app_constants.dart
    utils/
      date_time_x.dart
      score_utils.dart
    network/
      dio_client.dart

  domain/
    models/
      student.dart
      model_mastery.dart
      knowledge_point.dart
      question.dart
      flashcard.dart
      recommendation_item.dart
    enums/
      mastery_level.dart
      diagnosis_status.dart
      error_subtype.dart

  data/
    repositories/
      student_repository.dart
      question_repository.dart
      diagnosis_repository.dart
      training_repository.dart
      prediction_repository.dart
    mock/
      seed/
        mock_student.dart
        mock_questions.dart
        mock_models.dart
      mock_repositories/
        mock_student_repository.dart
        mock_question_repository.dart
        mock_diagnosis_repository.dart
        mock_training_repository.dart
        mock_prediction_repository.dart

  features/
    onboarding/
      presentation/pages/
        register_info_page.dart
        register_strategy_page.dart
        register_diagnosis_page.dart
    home/
      presentation/pages/
        home_page.dart
    global/
      presentation/pages/
        global_knowledge_page.dart
        global_model_page.dart
        global_exam_page.dart
        question_aggregate_page.dart
        question_detail_page.dart
    diagnosis/
      presentation/pages/
        ai_diagnosis_page.dart
    model_training/
      presentation/pages/
        model_detail_page.dart
        model_training_page.dart
        reading_training_page.dart
        quick_check_page.dart
    knowledge_learning/
      presentation/pages/
        knowledge_detail_page.dart
        knowledge_learning_page.dart
    upload/
      presentation/pages/
        upload_history_page.dart
      presentation/sheets/
        upload_menu_sheet.dart
        upload_capture_sheet.dart
    memory/
      presentation/pages/
        memory_page.dart
        flashcard_review_page.dart
    prediction/
      presentation/pages/
        prediction_center_page.dart
    review/
      presentation/pages/
        weekly_review_page.dart
        careless_cleanup_page.dart
    profile/
      presentation/pages/
        profile_page.dart
    report/
      presentation/pages/
        diagnosis_report_page.dart
        share_readonly_page.dart

  shared/
    widgets/
      app_card.dart
      app_chip.dart
      app_tab_bar.dart
      mastery_badge.dart
      step_progress.dart
      chat_bubble.dart
      loading_skeleton.dart
    layout/
      mobile_scaffold.dart
      desktop_scaffold.dart
```

---

## 3. 路由骨架（首版）

## 3.1 一级导航（Shell）
- `/home` → P1 主页
- `/global/knowledge` → P2 全局-知识点
- `/global/model` → P3 全局-模型
- `/global/exam` → P4 全局-高考卷子
- `/memory` → P5 记忆
- `/profile` → P6b 我的

## 3.2 业务页面
- `/knowledge/detail/:id` → P7
- `/knowledge/learn/:id` → P12
- `/model/detail/:id` → P8
- `/model/train/:id` → P13
- `/model/reading/:id` → P18
- `/model/quick-check/:id` → P19
- `/exam/question/:questionNo` → P9
- `/question/:id` → P10
- `/diagnosis/:questionId` → P14
- `/upload/history` → P15
- `/prediction` → P16
- `/review/weekly` → P17
- `/review/careless` → M5
- `/memory/review` → P11

## 3.3 首登与报告
- `/onboarding/info` → R1
- `/onboarding/strategy` → R2
- `/onboarding/diagnosis` → R3
- `/report/diagnosis` → P_report
- `/share/:token` → H5_share

## 3.4 弹层（BottomSheet/Dialog）
- `upload_menu_sheet`（M1）
- `upload_capture_sheet`（M2）
- `confusion_compare_dialog`（M3）
- `hesitate_hint_dialog`（M4）

---

## 4. 页面骨架（每页要有什么）

## 4.1 一级页面
| 页面 | 必要区域 | 当前先用的占位数据 |
|---|---|---|
| P1 主页 | 推荐区、快速开始、预测入口、今日数据、最近上传、上传按钮 | 推荐列表、pending数量、今日闭环数 |
| P2 全局-知识点 | 三级树、Level徽标、搜索筛选 | 章节树 + L0-L5 |
| P3 全局-模型 | 三级树、跨章标签、Level徽标 | 模型树 + crossChapter标记 |
| P4 全局-高考卷子 | 题型分组、题号正确率、上传入口 | 题号统计、预测得分X/Y |
| P5 记忆 | 今日待复习数、开始复习按钮、复习统计 | dueCards、连续天数 |
| P6b 我的 | 个人信息、目标分、上传历史入口、设置项 | studentProfile、目标分 |

## 4.2 二级与核心流程页面
| 页面 | 必要区域 | 占位数据 |
|---|---|---|
| P7 知识点详情 | 当前Level、一级/二级标签、关联模型、开始学习按钮 | kp详情、relatedModels |
| P8 模型详情 | 当前Level、前置知识点、不稳定标记、开始训练、快检入口 | model详情、prerequisites |
| P9 题号聚合 | 做题数、正确率、高频考点、薄弱模型、预测X/Y | questionNoStat |
| P10 题目详情 | 题干图、对错、模型标签、知识点标签、诊断状态 | question详情 |
| P11 闪卡复习 | 卡片正反面、进度、三按钮评分 | flashcard队列 |
| P12 知识点学习 | 对话区、5步进度、检测题区域 | chatMessages、currentStep |
| P13 模型训练 | 对话区、6步进度、分步填空、提示区 | trainingSession |
| P14 AI诊断 | 对话区（最多5轮）、结果卡（三段式+四层定位） | diagnosisSession |
| P15 上传历史 | 时间线列表、类型筛选、对错筛选、诊断状态筛选 | uploadRecords |
| P16 预测中心 | 预测总分、4周趋势图、Top3路径推荐 | predictedScore、trend |
| P17 周复盘 | 本周数据、Top3优先级、AI总结、下周方向 | weeklySummary |
| P18 审题训练 | 4步结构化表单、判定结果、返回训练按钮 | readingTask |
| P19 快检 | 1题模型识别、选项列表、结果路由提示 | quickCheckTask |

## 4.3 首登/报告页面
| 页面 | 必要区域 | 占位数据 |
|---|---|---|
| R1 基础信息 | 地区选择、目标分输入、继续按钮 | regionList、targetScore |
| R2 卷面策略 | 策略表（题号/态度/目标得分）、说明话术 | strategyRows |
| R3 自适应诊断 | 对话区、进度、三维画像结果 | onboardingDiagnosis |
| P_report 诊断报告 | 动态揭晓、热力图、核心发现、提分路径、CTA | reportPayload |
| H5_share 分享页 | 只读报告、无编辑入口 | shareReportPayload |

---

## 5. 状态与占位后端骨架（最小可跑）

## 5.1 先定义的Provider（Riverpod）
- `studentProvider`
- `questionListProvider`
- `modelMasteryProvider`
- `knowledgeMasteryProvider`
- `recommendationProvider`
- `predictionProvider`
- `diagnosisSessionProvider`
- `trainingSessionProvider`

## 5.2 最小Mock仓库接口
- `StudentRepository.getStudentProfile()`
- `QuestionRepository.getUploadHistory()`
- `DiagnosisRepository.startDiagnosis(questionId)`
- `TrainingRepository.startModelTraining(modelId, fromStep)`
- `PredictionRepository.getPredictionSummary()`

---

## 6. 首轮开发切片（建议）

1. 切片A（导航跑通）：P1/P2/P3/P4/P5/P6b + go_router + AppShell  
2. 切片B（主链路跑通）：P10 → P14 → P13/P12 → P15  
3. 切片C（价值展示）：P16 + P17 + P_report  
4. 切片D（强化模块）：P18 + P19 + M3/M4/M5

---

## 7. 待你审核确认（拍板项）

1. 社区Tab是否放到首版底部导航（当前默认不放，作为V2开关）  
2. 首版是否只开物理学科（当前建议是）  
3. 诊断报告页面是否首版必须上线（建议必须）  
4. `flutter_chat_ui`是否采用（若你希望完全自定义UI可不引入）

