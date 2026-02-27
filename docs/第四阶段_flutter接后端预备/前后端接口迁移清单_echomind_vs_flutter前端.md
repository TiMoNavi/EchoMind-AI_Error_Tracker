# 前后端接口迁移清单（echomind_app vs flutter前端/echomind_app）

## 1. 结论摘要

- 你队友的后端接入主要在 `echomind_app`，不是 `flutter前端/echomind_app`。
- `flutter前端/echomind_app` 是 UI 版本（视觉更完整），但缺少网络层与状态管理层。
- 迁移应采用“保留新 UI、迁移旧接口层”的方式，禁止直接覆盖新页面。

## 2. 本地结构差异（lib）

- `echomind_app/lib`：152 个文件
- `flutter前端/echomind_app/lib`：142 个文件
- 同名文件：114（其中内容不同 100）

仅 `echomind_app` 存在（后端接入核心）：
- `core/api_client.dart`
- `providers/*.dart`（21 个 provider）
- `models/*.dart`（后端 DTO/实体）
- `features/auth/*`（登录注册）

仅 `flutter前端/echomind_app` 存在（新 UI 能力）：
- `shared/models/*`（UI 侧模型）
- `shared/widgets/chat/*`
- `shared/widgets/clay_*`
- `features/community/community_detail_page.dart`

## 3. 后端接口接入差异

### 3.1 旧版已接入（echomind_app）

关键基础：
- `core/api_client.dart`（Dio + Token 拦截 + 统一错误处理）
- `main.dart`（`ProviderScope`）
- `app/app_router.dart`（含登录态守卫、参数化路由）

已调用接口（44 条调用，含重复模块）：
- 认证：`/auth/login` `/auth/register` `/auth/me` `/auth/profile`
- 首页/推荐：`/dashboard` `/recommendations`
- 知识/模型：`/knowledge/tree` `/knowledge/{id}` `/models/tree` `/models/{id}`
- 学习/训练：`/knowledge/learning/*` `/models/training/*`
- 题目：`/questions/history` `/questions/aggregate` `/questions/{id}`
- AI 诊断：`/diagnosis/start` `/diagnosis/chat` `/diagnosis/session` `/diagnosis/complete`
- 社区：`/community/requests` `/community/feedback` 及 vote 接口
- 其他：`/weekly-review` `/prediction/score` `/flashcards` `/upload/image` `/strategy/*`

### 3.2 新版前端（flutter前端/echomind_app）现状

- 无 `core/api_client.dart`
- 无 `providers/`
- `main.dart` 无 `ProviderScope`
- 页面多数为静态数据或本地状态（例如 `ai_diagnosis_page.dart` 中明确 TODO mock）
- 路由未参数化（如 `knowledge-detail`、`model-detail`、`question-detail` 无 `:id`）

### 3.3 与当前后端契约比对结果

比对结果：
- 前端调用集合：44
- 后端路由集合：47
- 不匹配（前端调用但后端不存在）：
  - `GET /exams/question-types`
- 后端有但旧前端未使用：
  - `GET /diagnosis/session/{id}`
  - `GET /knowledge/learning/session`
  - `POST /flashcards/{mastery_id}/review`
  - `POST /questions/upload`

说明：迁移时应先处理 `exam question-types` 契约问题，否则全局考试模块会报错。

## 4. 迁移原则（必须遵守）

1. 不做“整目录覆盖”式迁移；只迁移接口层和状态层。
2. UI 与接口解耦：页面不直接写 HTTP，统一经 `provider/repository`。
3. 先打通基础设施，再分模块接入，保证每一步可回归。
4. DTO 与 UI Model 分离：保留 `shared/models` 的展示模型，新增 mapper。
5. 统一错误与空态：接入 `AsyncDataWrapper`，不把异常直接透传到 UI 文案。
6. 环境配置外置：`baseUrl` 不硬编码到业务文件。

## 5. 具体迁移清单（按顺序执行）

### Phase 0：分支与基线

- 新建分支：`feat/migrate-backend-to-flutter-frontend`
- 固定迁移目标目录：`flutter前端/echomind_app`
- 禁止再向 `echomind_app` 增量开发（只读参考）

### Phase 1：基础设施迁移（P0）

1. 依赖对齐（`flutter前端/echomind_app/pubspec.yaml`）
- 增加：`dio` `flutter_riverpod` `shared_preferences` `image_picker` `json_annotation`
- dev：`build_runner` `json_serializable`

2. 网络层落地
- 新建：`flutter前端/echomind_app/lib/core/api_client.dart`
- 从旧版迁移：Token 注入、超时、统一错误映射
- 额外改造：`baseUrl` 改为 `--dart-define` 或环境配置

3. 应用入口改造
- 修改：`flutter前端/echomind_app/lib/main.dart`
- `runApp` 外层增加 `ProviderScope`

4. 路由契约对齐
- 修改：`flutter前端/echomind_app/lib/app/app_routes.dart`
- 恢复参数路由：
  - `/knowledge-detail/:id`
  - `/model-detail/:id`
  - `/question-detail/:id`
- 增加 path helper（`xxxPath(id)`）

5. 路由守卫对齐
- 修改：`flutter前端/echomind_app/lib/app/app_router.dart`
- 引入登录态检查（token）和 auth route 重定向

### Phase 2：数据层迁移（P0/P1）

1. 创建新目录
- `flutter前端/echomind_app/lib/providers/`
- `flutter前端/echomind_app/lib/data/models/`（可选，承载 DTO）
- `flutter前端/echomind_app/lib/data/mappers/`

2. 迁移 provider（按旧版 21 个逐个迁移）
- 首批 P0（核心链路）：
  - `auth_provider`
  - `dashboard_provider`
  - `recommendations_provider`
  - `question_detail_provider`
  - `upload_history_provider`
  - `profile_provider`
- 第二批 P1（学习主链路）：
  - `knowledge_tree_provider`
  - `knowledge_detail_provider`
  - `knowledge_learning_provider`
  - `model_tree_provider`
  - `model_detail_provider`
  - `model_training_provider`
  - `prediction_provider`
  - `weekly_review_provider`
- 第三批 P2（增强模块）：
  - `community_provider`
  - `strategy_provider`
  - `ai_diagnosis_provider`
  - `exam_provider`
  - `flashcard_provider`
  - `question_aggregate_provider`

3. DTO/Model 规范
- 不直接复用旧版 `models/*.dart` 到 UI 层
- 旧 DTO -> mapper -> `shared/models/*`（或新 domain model）

### Phase 3：页面接线迁移（按功能域）

1. 首页与概览
- `features/home/widgets/top_dashboard_widget.dart`
- `features/home/widgets/recommendation_list_widget.dart`
- `features/home/widgets/recent_upload_widget.dart`

2. 详情链路（路由参数）
- `features/global_knowledge/widgets/knowledge_tree_widget.dart`
- `features/knowledge_detail/*`
- `features/global_model/widgets/model_tree_widget.dart`
- `features/model_detail/*`
- `features/question_aggregate/*`
- `features/question_detail/*`

3. 对话链路（高风险）
- `features/ai_diagnosis/*`
- `features/knowledge_learning/*`
- `features/model_training/*`

4. 用户与策略
- `features/profile/*`
- `features/register_strategy/*`
- `features/upload_menu/upload_menu_page.dart`

5. 社区
- `features/community/*`
- 保留 `community_detail_page.dart` 新 UI，同时接入 `community_provider`

### Phase 4：接口契约修复（必须）

1. 考试题型接口不匹配
- 方案 A：后端补 `GET /exams/question-types`
- 方案 B：前端改为现有接口组合并本地聚合
- 该项不解决前，不允许宣称考试模块“已接后端”

2. 可选增强接口接入
- `POST /questions/upload`（如果上传链路要走 questions 域）
- `GET /knowledge/learning/session`
- `GET /diagnosis/session/{id}`
- `POST /flashcards/{mastery_id}/review`

### Phase 5：质量门禁（防止“短期可用、长期失控”）

1. 代码质量
- 每个 provider 至少覆盖：成功/失败/空态 3 类状态
- 页面层禁止直接出现 `dio.get/post`

2. 回归清单（按用户主路径）
- 登录 -> 首页 -> 推荐跳转 -> 详情 -> 训练 -> 周复盘
- 上传 -> 历史 -> 题目详情 -> AI 诊断 -> 模型训练
- 社区提需求/反馈/投票

3. 发布前检查
- baseUrl 环境切换（dev/staging/prod）
- token 失效重登
- 超时/断网/500 错误文案统一

## 6. 建议实施方式

- 建议采用“双轨 PR”模式：
  - PR-1：基础设施 + 路由 + auth（不改页面视觉）
  - PR-2：首页/详情链路
  - PR-3：对话链路（AI 诊断/学习/训练）
  - PR-4：社区与策略 + 契约修复

这样可以确保每个阶段都可验证、可回滚，不会把 UI 与接口改动缠在一起。
