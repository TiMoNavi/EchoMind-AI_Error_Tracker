# 第三阶段规划：Flutter 页面说明文档生成

## 目标

为第二阶段完成的所有 Flutter 页面，生成与第二阶段 HTML 说明文档同等格式的 Markdown 文档，附带安卓模拟器下的页面截图和组件截图。

**核心意图**：这份文档不仅是视觉验收记录，更是后续开发的「前后端对接手册」。每个组件除了截图和源码位置外，必须写清楚它的**预期用途**——即这个组件将来要接入什么数据、展示什么信息、完成什么业务流程。这样后端开发者或下一阶段的 AI 拿到文档后，能直接理解每个组件的数据需求和交互意图，而不只是看到一张静态截图。

---

## 当前前端状态盘点

共 21 个页面（20 个路由 + 1 个 community-detail 子页面），104 个 dart 文件。

### 页面清单与组件树

| 序号 | 路由 | 页面名 | 组件数 |
|------|------|--------|--------|
| 01 | `/` | home 首页 | 5 (top-frame, top-dashboard, recommendation-list, recent-upload, action-overlay) |
| 02 | `/community` | community 社区 | 4 (top-frame-and-tabs, board-feature-boost, board-feedback, board-my-requests) |
| 03 | `/community-detail` | community-detail 社区详情 | (独立页面，无子组件拆分) |
| 04 | `/global-knowledge` | global-knowledge 全局知识点 | 2 (top-frame, knowledge-tree) |
| 05 | `/global-model` | global-model 全局模型 | 2 (top-frame, model-tree) |
| 06 | `/global-exam` | global-exam 全局高考卷 | 4 (top-frame, exam-heatmap, question-type-browser, recent-exams) |
| 07 | `/memory` | memory 记忆 | 3 (top-frame, review-dashboard, card-category-list) |
| 08 | `/flashcard-review` | flashcard-review 闪卡复习 | 2 (top-frame, flashcard) |
| 09 | `/question-aggregate` | question-aggregate 单题聚合 | 4 (top-frame, single-question-dashboard, exam-analysis, question-history-list) |
| 10 | `/question-detail` | question-detail 题目详情 | 5 (top-frame, question-content, answer-result, question-relations, question-source) |
| 11 | `/ai-diagnosis` | ai-diagnosis AI诊断 | 3 (top-frame, main-content, action-overlay) |
| 12 | `/model-detail` | model-detail 模型详情 | 5 (top-frame, mastery-dashboard, prerequisite-knowledge-list, related-question-list, training-record-list) |
| 13 | `/model-training` | model-training 模型训练 | 10 (top-frame, step-stage-nav, step1~step6, training-dialogue, action-overlay) |
| 14 | `/knowledge-detail` | knowledge-detail 知识点详情 | 4 (top-frame, mastery-dashboard, concept-test-records, related-models) |
| 15 | `/knowledge-learning` | knowledge-learning 知识点学习 | 9 (top-frame, step-stage-nav, step1~step5, learning-dialogue, action-overlay) |
| 16 | `/prediction-center` | prediction-center 预测中心 | 5 (top-frame, score-card, trend-card, score-path-table, priority-model-list) |
| 17 | `/upload-history` | upload-history 上传历史 | 3 (top-frame, history-filter, history-record-list) |
| 18 | `/weekly-review` | weekly-review 周复盘 | 5 (top-frame, weekly-dashboard, score-change, weekly-progress, next-week-focus) |
| 19 | `/profile` | profile 我的 | 6 (top-frame, user-info-card, target-score-card, three-row-navigation, two-row-navigation, learning-stats) |
| 20 | `/upload-menu` | upload-menu 上传菜单 | 2 (top-frame, main-content) |
| 21 | `/register-strategy` | register-strategy 学习策略 | 2 (top-frame, main-content) |

---

## 执行步骤

### Step 1：截图采集

**工具**：Flutter integration_test + 安卓模拟器

**方案**：编写一个新的 integration test 脚本，在安卓模拟器上运行，自动截取：

1. **整页截图**：每个页面一张完整截图（390x844 视口）
2. **组件截图**：每个页面的每个子组件单独截图

截图脚本需要做两件事：
- 导航到每个路由，截取整页
- 对每个页面，用 `find.byType(WidgetName)` 定位组件，用 `tester.renderObject` 获取组件边界，裁剪出组件区域截图

**输出目录结构**：
```
docs/第三阶段_flutter美化/
├── flutter截图验证/
│   ├── home/
│   │   ├── full/
│   │   │   └── home__390x844__full.png
│   │   └── components/
│   │       ├── top-frame__390x844.png
│   │       ├── top-dashboard__390x844.png
│   │       ├── recommendation-list__390x844.png
│   │       ├── recent-upload__390x844.png
│   │       └── action-overlay__390x844.png
│   ├── community/
│   │   ├── full/
│   │   └── components/
│   ... (每个页面同理)
```

### Step 2：编写截图脚本

基于已有的 `screenshot_all_pages_test.dart`，扩展为：

```dart
// integration_test/screenshot_stage3_test.dart
// 1. 整页截图（已有逻辑，改输出路径）
// 2. 组件截图（新增：按 widget type 查找并裁剪）
```

关键技术点：
- 整页截图：沿用现有 `layer.toImage()` 方案
- 组件截图：`tester.widget(find.byType(XxxWidget))` → `tester.renderObject(find.byType(XxxWidget))` → 获取 `paintBounds` → 用 `layer.toImage()` 裁剪对应区域
- 对于需要滚动才能看到的组件，先 `tester.scrollUntilVisible()` 再截图

### Step 3：在安卓模拟器上运行截图脚本

```bash
cd flutter前端/echomind_app
flutter test integration_test/screenshot_stage3_test.dart -d emulator-5554
```

确认所有截图正确输出到 `docs/第三阶段_flutter美化/flutter截图验证/` 目录。

### Step 4：生成 21 个页面说明文档

每个页面一个 `.md` 文件，格式沿用第二阶段模板：

```markdown
# {page-name}（{中文名}）

## 当前状态

第二阶段完成，所有组件已实现，视觉效果已对齐 HTML 原型。

## 路由标识

`{routeName}`

## 组件树

（text tree）

## 页面截图

![{name}-390x844](...截图路径...)

---

## 组件详情

### {component-name}

![{component-screenshot}](...截图路径...)

- 功能说明: ...
- 预期用途: ...（见下方写作规范）
- 对应 dart 文件: `lib/features/{feature}/widgets/{file}.dart`
- 视觉状态: 已对齐 HTML 原型 / 存在偏差（描述）
```

**与第二阶段文档的区别**：
- 截图来源从「浏览器 HTML 截图」变为「安卓模拟器 Flutter 截图」
- 新增「对应 dart 文件」字段，标注每个组件的源码位置
- 新增「视觉状态」字段，标注是否已对齐 HTML 原型
- 去掉「输入/输出」「响应式规范」等 HTML 阶段特有的描述
- 新增「页面跳转」字段，标注实际的 go_router 跳转关系
- **新增「预期用途」字段**，描述组件的业务意图和数据对接需求（详见下方写作规范）

### 「预期用途」字段写作规范

这是第三阶段文档区别于第二阶段的核心新增内容。目的是让后续开发者（人或 AI）拿到文档后，能直接理解：

1. **这个组件要接什么数据** — 数据来源、字段含义、更新频率
2. **在前端展示什么信息** — 用户看到的是什么、数值的业务含义
3. **完成什么业务流程/交互** — 点击后触发什么、串联哪些上下游页面

#### 写作模板

```
预期用途: 接入{数据源/API}的{具体字段}数据，在前端以{展示形式}展示{业务含义}。
用户可通过{交互方式}完成{业务动作}，跳转至{目标页面}进入{下游流程}。
```

#### 具体示例（按页面列举）

**首页 top-dashboard**:
> 预期用途: 接入用户学习统计 API，展示「预测分数」「本周闭环数」「待诊断题数」三个核心指标。
> 预测分数点击后跳转预测中心，待诊断数点击后跳转上传历史，作为用户每日打开 App 的第一信息入口。

**全局高考卷 exam-heatmap**:
> 预期用途: 接入用户历次考试的逐题得分数据，以热力图矩阵展示每道题的对错分布。
> 横轴为题号，纵轴为考试场次，颜色深浅表示得分率，帮助用户一眼识别薄弱题型集中区域。

**模型详情 mastery-dashboard**:
> 预期用途: 接入单个模型的掌握度评估数据，以四层漏斗（建模层/列式层/执行层/稳定层）展示当前卡在哪一层。
> 底部显示关联大题的预计提分，点击「开始训练」进入模型训练页的对应 Step，形成「诊断→定位→训练」闭环。

**预测中心 score-path-table**:
> 预期用途: 接入 AI 提分路径规划 API，以表格展示每道题的「现状态度(MUST/TRY/SKIP)」「建议动作」「预计提分」。
> 用户据此了解投入产出比最高的提分路径，点击题号可跳转至对应题目的聚合分析页。

**知识点详情 concept-test-records**:
> 预期用途: 接入知识点概念检测的历史记录数据，按时间倒序展示每次检测的通过/未通过状态及错误原因。
> 帮助用户追踪单个知识点的掌握变化趋势，判断是否需要重新进入学习流程。

**上传历史 history-record-list**:
> 预期用途: 接入用户上传记录 API，按日期分组展示每次上传的类型(作业HW/考试EX/极简QK)、错题数、诊断进度。
> 「待诊断」状态的记录点击后跳转题目详情页，引导用户完成 AI 诊断闭环。

**周复盘 weekly-progress**:
> 预期用途: 接入周维度的模型/知识点等级变化数据，以列表展示本周每个训练项的等级变动(L2→L3)和状态(UP/持平)。
> 让用户直观看到一周的训练成果，持平项提示需要调整策略。

#### 写作要点

- **必须具体**：不写「展示数据」，要写「展示预测分数 63/100 和目标分 70 的差距」
- **必须说清数据流向**：从哪个 API / 数据表来，到前端怎么展示
- **必须说清交互闭环**：点击后去哪、完成什么流程、和哪些页面串联
- **当前硬编码的 mock 数据也要说明**：标注「当前为 mock 数据，后续需替换为 API 返回值」
- **对于纯展示组件**（如 top-frame），简写即可：「导航返回 + 页面标题展示，无数据接入需求」

### Step 5：汇总索引文档

在 `docs/第三阶段_flutter美化/` 下生成一个 `README.md` 索引，列出所有 21 个页面文档的链接。

---

## 文件产出清单

```
docs/第三阶段_flutter美化/
├── README.md                          (索引)
├── 21个flutter页面的分别说明文档/
│   ├── 01_home_首页.md
│   ├── 02_community_社区.md
│   ├── 03_community-detail_社区详情.md
│   ├── 04_global-knowledge_全局知识点.md
│   ├── 05_global-model_全局模型.md
│   ├── 06_global-exam_全局高考卷.md
│   ├── 07_memory_记忆.md
│   ├── 08_flashcard-review_闪卡复习.md
│   ├── 09_question-aggregate_单题聚合.md
│   ├── 10_question-detail_题目详情.md
│   ├── 11_ai-diagnosis_AI诊断.md
│   ├── 12_model-detail_模型详情.md
│   ├── 13_model-training_模型训练.md
│   ├── 14_knowledge-detail_知识点详情.md
│   ├── 15_knowledge-learning_知识点学习.md
│   ├── 16_prediction-center_预测中心.md
│   ├── 17_upload-history_上传历史.md
│   ├── 18_weekly-review_周复盘.md
│   ├── 19_profile_我的.md
│   ├── 20_upload-menu_上传菜单.md
│   └── 21_register-strategy_学习策略.md
└── flutter截图验证/
    ├── home/
    │   ├── full/
    │   │   └── home__390x844__full.png
    │   └── components/
    │       └── *.png
    ├── community/
    ... (21个页面目录)
```

---

## 执行顺序

1. **先写截图脚本** → `integration_test/screenshot_stage3_test.dart`
2. **在安卓模拟器上跑截图** → 产出所有 png
3. **逐页生成 md 文档** → 读代码 + 引用截图
4. **写 README 索引**

## 注意事项

- 截图脚本中，model-training 和 knowledge-learning 页面有多个 step 组件，默认只显示 step1，其余 step 需要切换 tab 后再截图
- community-detail 是从 community 页面 push 进入的子页面，需要先导航到 community 再 push
- 部分页面有 action-overlay（底部浮层），截图时需确认浮层可见
- upload-history 页面已移除 history-date-scroll 组件，实际只有 3 个组件
