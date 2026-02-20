# 高中错题闭环系统前端项目说明（Component 纯净拆解版）

## 1. 文档目的与范围
本文件用于完整说明当前目录 `html前端——component纯净组件拆解版` 的前端实现逻辑，包含：
- 项目目标与业务闭环
- 页面与组件的树形结构
- 18 个页面的设计目的
- 每个页面的组件职责
- 页面跳转关系（基于 `navigateTo`）

说明：
- 本文描述的是“按功能分区拆解”的 HTML 原型前端。
- 组件目录用于功能分区与结构契约，页面运行以 `page.js` 组装内容为准。

---

## 2. 项目目标（前端视角）
目标是把学生错题学习过程做成可追踪闭环：
1. 上传错题
2. AI 诊断
3. 路由训练（模型/知识点）
4. 掌握度更新
5. 预测分变化
6. 推荐下一步

前端核心价值：
- 把每一环落到具体页面与操作入口
- 把复杂流程拆成清晰功能分区
- 保持页面跳转链路闭合、可回溯

---

## 3. 目录与实现逻辑

### 3.1 目录结构（核心）
```text
html前端——component纯净组件拆解版/
├─ pages/
│  ├─ <page>/
│  │  ├─ index.html
│  │  ├─ page.css
│  │  ├─ page.js
│  │  └─ components/
│  │     └─ <component>/component.html
├─ shared/
│  ├─ styles.css
│  └─ app.js
└─ page-annotations/
   ├─ README.md
   ├─ PAGE_MODULE_DESCRIPTIONS.md
   ├─ raw/
   ├─ annotated/
   └─ crops/
```

### 3.2 页面运行机制
1. `index.html` 作为页面壳。
2. `page.css` 引入共享样式并做页面级补充。
3. `page.js` 负责组装页面功能分区并绑定交互。
4. `shared/app.js` 提供导航、图表、通用交互函数。

### 3.3 组件文件的定位
`components/<name>/component.html` 在本项目中用于：
- 明确页面功能分区边界
- 提供组件契约与命名锚点
- 支持标注工具与文档映射

---

## 4. 业务闭环与页面落点
- 上传：`index`（悬浮上传）、`upload-history`
- 诊断：`question-detail` -> `ai-diagnosis`
- 模型训练：`model-detail` -> `model-training`
- 知识学习：`knowledge-detail` -> `knowledge-learning`
- 记忆复习：`memory` -> `flashcard-review`
- 分数预测：`prediction-center`
- 周复盘：`weekly-review`

---

## 5. 页面 + 组件树（18页）

```text
index
├─ top-frame
├─ top-dashboard
├─ recommendation-list
├─ recent-upload
└─ action-overlay

community
├─ top-frame-and-tabs
├─ board-my-requests
├─ board-feature-boost
└─ board-feedback

global-knowledge
├─ top-frame
└─ knowledge-tree

global-model
├─ top-frame
└─ model-tree

global-exam
├─ top-frame
├─ exam-heatmap
├─ question-type-browser
└─ recent-exams

memory
├─ top-frame
├─ review-dashboard
└─ card-category-list

flashcard-review
├─ top-frame
└─ flashcard

question-aggregate
├─ top-frame
├─ single-question-dashboard
├─ exam-analysis
└─ question-history-list

question-detail
├─ top-frame
├─ question-content
├─ answer-result
├─ question-relations
└─ question-source

ai-diagnosis
├─ top-frame
├─ main-content
└─ action-overlay

model-detail
├─ top-frame
├─ mastery-dashboard
├─ prerequisite-knowledge-list
├─ related-question-list
└─ training-record-list

model-training
├─ top-frame
├─ step-stage-nav
├─ step-1-identification-training
├─ step-2-decision-training
├─ step-3-equation-training
├─ step-4-trap-analysis
├─ step-5-complete-solve
├─ step-6-variation-training
├─ training-dialogue
└─ action-overlay

knowledge-detail
├─ top-frame
├─ mastery-dashboard
├─ concept-test-records
└─ related-models

knowledge-learning
├─ top-frame
├─ step-stage-nav
├─ step-1-concept-present
├─ step-2-understanding-check
├─ step-3-discrimination-training
├─ step-4-practical-application
├─ step-5-concept-test
└─ action-overlay

prediction-center
├─ top-frame
├─ score-card
├─ trend-card
├─ score-path-table
└─ priority-model-list

upload-history
├─ top-frame
├─ history-panel
├─ history-filter
├─ history-date-scroll
└─ history-record-list

weekly-review
├─ top-frame
├─ weekly-dashboard
├─ score-change
├─ weekly-progress
└─ next-week-focus

profile
├─ top-frame
├─ user-info-card
├─ target-score-card
├─ three-row-navigation
├─ two-row-navigation
└─ learning-stats
```

---

## 6. 页面设计目的与组件功能

### 6.1 index（首页）
设计目的：展示学习总览并提供闭环起点入口。
- `top-frame`：状态栏与主页标题。
- `top-dashboard`：今日闭环、学习时长、预测分入口、快速开始。
- `recommendation-list`：推荐诊断/训练/补强任务。
- `recent-upload`：最近上传错题摘要。
- `action-overlay`：悬浮上传与新建菜单。

### 6.2 community（社区）
设计目的：收集需求与改进建议。
- `top-frame-and-tabs`：社区标题与三选栏。
- `board-my-requests`：我的需求列表。
- `board-feature-boost`：新功能加速板块。
- `board-feedback`：改版建议板块。

### 6.3 global-knowledge（全局-知识点）
设计目的：全局浏览知识点掌握结构。
- `top-frame`：全局标题与子 tab。
- `knowledge-tree`：可折叠知识树（章节/节/知识点）。

### 6.4 global-model（全局-模型）
设计目的：全局浏览模型/方法结构。
- `top-frame`：全局标题与子 tab。
- `model-tree`：可折叠模型树与子问题层级。

### 6.5 global-exam（全局-高考卷）
设计目的：以卷面视角进行提分诊断。
- `top-frame`：全局标题与子 tab。
- `exam-heatmap`：题号热力图（参数变化驱动图变化）。
- `question-type-browser`：按题型分组浏览。
- `recent-exams`：最近卷子入口。

### 6.6 memory（记忆）
设计目的：进入复习与管理卡片体系。
- `top-frame`：记忆页标题。
- `review-dashboard`：待复习数量与复习统计。
- `card-category-list`：按卡片类别管理复习任务。

### 6.7 flashcard-review（闪卡复习）
设计目的：单卡复习与反馈打标。
- `top-frame`：返回、进度与计数。
- `flashcard`：卡片翻转与“忘了/记得/简单”反馈。

### 6.8 question-aggregate（单题聚合）
设计目的：按题号查看历史表现与薄弱点。
- `top-frame`：返回与题号标题。
- `single-question-dashboard`：做题次数、正确率、预测得分。
- `exam-analysis`：态度与关联薄弱信息。
- `question-history-list`：该题号历史题目列表。

### 6.9 question-detail（题目详情）
设计目的：单题详情与诊断入口。
- `top-frame`：返回与标题。
- `question-content`：题干/题图内容。
- `answer-result`：对错状态与进入诊断入口。
- `question-relations`：归属模型与关联知识点。
- `question-source`：来源卷子、题号、分值、态度。

### 6.10 ai-diagnosis（AI诊断）
设计目的：对单题错误进行对话式定位。
- `top-frame`：返回与标题。
- `main-content`：题目引用、诊断对话、结论与行动按钮。
- `action-overlay`：底部输入框。

### 6.11 model-detail（模型详情）
设计目的：围绕模型进行训练决策。
- `top-frame`：返回与模型名。
- `mastery-dashboard`：掌握漏斗与训练入口。
- `prerequisite-knowledge-list`：前置知识点与补强建议。
- `related-question-list`：关联题目列表。
- `training-record-list`：训练历史记录。

### 6.12 model-training（模型训练）
设计目的：分阶段完成模型训练闭环。
- `top-frame`：返回与训练标题。
- `step-stage-nav`：阶段导航，支持点击切换。
- `step-1-identification-training`：识别训练顶部步骤卡。
- `step-2-decision-training`：决策训练顶部步骤卡（默认）。
- `step-3-equation-training`：列式训练顶部步骤卡。
- `step-4-trap-analysis`：陷阱辨析顶部步骤卡。
- `step-5-complete-solve`：完整求解顶部步骤卡。
- `step-6-variation-training`：变式训练顶部步骤卡。
- `training-dialogue`：固定对话训练区（步骤切换不替换该区域）。
- `action-overlay`：底部输入框。

### 6.13 knowledge-detail（知识点详情）
设计目的：知识点掌握诊断与学习入口。
- `top-frame`：返回与知识点标题。
- `mastery-dashboard`：掌握度仪表与开始学习。
- `concept-test-records`：概念检测记录。
- `related-models`：关联模型列表。

### 6.14 knowledge-learning（知识点学习）
设计目的：知识点分阶段学习与讲解。
- `top-frame`：返回与标题。
- `step-stage-nav`：5阶段导航，支持点击切换。
- `step-1-concept-present`：概念呈现步骤卡。
- `step-2-understanding-check`：理解检查步骤卡。
- `step-3-discrimination-training`：辨析训练步骤卡（默认）。
- `step-4-practical-application`：实际应用步骤卡。
- `step-5-concept-test`：概念检测步骤卡。
- `action-overlay`：底部输入框。

说明：当前实现为“只切换顶部 step 卡片，下面对话区保持不变”。

### 6.15 prediction-center（预测中心）
设计目的：集中展示分数预测与提分路径。
- `top-frame`：返回与标题。
- `score-card`：预测分与目标差距。
- `trend-card`：预测分趋势（折线图）。
- `score-path-table`：题号维度提分路径表。
- `priority-model-list`：优先训练模型列表。

### 6.16 upload-history（上传历史）
设计目的：查看并筛选历史上传记录。
- `top-frame`：返回与标题。
- `history-panel`：历史主容器（L1）。
- `history-filter`：状态/类型筛选。
- `history-date-scroll`：按日期分组滚动。
- `history-record-list`：历史记录列表（支持下拉刷新语义）。

### 6.17 weekly-review（周复盘）
设计目的：周维度复盘与下周规划。
- `top-frame`：返回与周次信息。
- `weekly-dashboard`：本周总览数据。
- `score-change`：分数前后对比。
- `weekly-progress`：本周进展条目。
- `next-week-focus`：下周重点建议。

### 6.18 profile（我的）
设计目的：个人中心与常用入口聚合。
- `top-frame`：页面标题。
- `user-info-card`：用户基础信息。
- `target-score-card`：目标分与策略摘要。
- `three-row-navigation`：核心业务入口（上传历史/周复盘/卷面策略）。
- `two-row-navigation`：设置类入口。
- `learning-stats`：累计学习统计。

---

## 7. 页面跳转关系（navigateTo 摘要）

- 首页 `index`：跳转 `prediction-center` / `ai-diagnosis` / `model-detail` / `knowledge-detail` / `model-training` / `upload-history`。
- 全局三页：
  - `global-knowledge` <-> `global-model` <-> `global-exam`。
- 题目链路：
  - `global-exam` -> `question-aggregate` -> `question-detail` -> `ai-diagnosis`。
- 模型链路：
  - `global-model` -> `model-detail` -> `model-training`。
- 知识链路：
  - `global-knowledge` -> `knowledge-detail` -> `knowledge-learning`。
- 记忆链路：
  - `memory` -> `flashcard-review`。
- 复盘链路：
  - `profile` -> `weekly-review`。
- 历史链路：
  - `index/profile` -> `upload-history` -> `question-detail`。

---

## 8. 当前前端约束与约定
1. 页面功能分区优先，不做原子级细拆。
2. 单页组件数量控制在可理解范围，避免过细。
3. 阶段训练页（`knowledge-learning`、`model-training`）支持阶段切换。
4. 当前阶段页为“顶部 step 卡片切换 + 下方对话区保持稳定”的交互模型。
5. 标注系统与组件命名保持一致，输出在 `page-annotations/`。

---

## 9. 维护建议
1. 新增页面时先定义“页面目的 + 3~6 个功能组件”，再写代码。
2. 组件命名尽量使用业务语义（如 `score-path-table`），避免 `main-content` 这类泛化名。
3. 每次组件重命名后同步更新：
   - `tools/generate_page_annotations.py`
   - `page-annotations/PAGE_MODULE_DESCRIPTIONS.md`
4. 保持 `page.js` 的拼装顺序与组件树顺序一致，便于标注和排障。
