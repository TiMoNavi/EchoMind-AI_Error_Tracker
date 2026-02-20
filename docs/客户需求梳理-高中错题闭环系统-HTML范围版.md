# 客户需求梳理-高中错题闭环系统（HTML范围版）

## 0. 文档定位与范围
- 文档目标：将客户要的软件需求，映射为当前原型可见的页面能力与业务闭环。
- 分析范围：仅基于 `示例html前端` 现有 18 个页面。
- 不在本次页面范围内：`upload-menu.html`、`register-strategy.html`（被跳转引用，但未提供页面原型）。
- 参考依据：
  - 页面原型：`示例html前端/*.html`
  - 业务约束（按需定点）：`docs/客户要求/core_framework_v2.0.md`、`docs/客户要求/功能域划分与数据关联.md`

## 1. 产品目标与闭环链路
## 1.1 产品目标
- 把“错题记录”升级为“提分闭环系统”。
- 每道错题可被诊断到模型/知识点层，给出下一步训练动作。
- 学习结果体现在掌握度、预测分变化、下一步推荐中。

## 1.2 闭环链路（产品主路径）
1. 上传错题（作业/练习/考试）  
2. AI诊断（判断错误根因与训练方向）  
3. 路由训练（模型训练或知识点学习）  
4. 掌握度更新（训练与验证后状态变化）  
5. 预测分变化（趋势和路径）  
6. 推荐下一步（主页推荐与周复盘）

## 1.3 闭环链路与页面落点
| 闭环阶段 | 当前页面落点 |
|---|---|
| 上传错题 | `index.html`（上传入口）、`upload-history.html`（历史记录） |
| AI诊断 | `question-detail.html`（入口）、`ai-diagnosis.html`（诊断过程与结论） |
| 路由训练（模型） | `model-detail.html`、`model-training.html` |
| 路由训练（知识点） | `knowledge-detail.html`、`knowledge-learning.html` |
| 掌握度呈现 | `global-knowledge.html`、`global-model.html`、`model-detail.html`、`knowledge-detail.html` |
| 预测分呈现 | `index.html`（入口卡片）、`prediction-center.html` |
| 推荐下一步 | `index.html`（推荐学习区）、`weekly-review.html`（下周重点） |

## 2. 页面清单（18页）与业务职责
| 页面 | 页面定位 | 核心业务职责 | 对应闭环环节 |
|---|---|---|---|
| `index.html` | 首页中枢 | 看今日状态、接收推荐、发起上传、进入预测与训练 | 推荐/上传/路径分发 |
| `global-knowledge.html` | 全局-知识点视图 | 按章节树查看知识点掌握状态并进入详情 | 状态查看/知识学习入口 |
| `global-model.html` | 全局-模型视图 | 按模型树查看掌握层级并进入模型详情 | 状态查看/模型训练入口 |
| `global-exam.html` | 全局-高考卷子视图 | 从题号热力图和题型列表查看卷面表现 | 考试视角诊断与定位 |
| `memory.html` | 记忆复习首页 | 查看待复习数量与记忆统计，进入闪卡复习 | 巩固防忘 |
| `community.html` | 社区反馈页 | 需求提交、功能投票、改版建议 | 反馈与产品共建 |
| `profile.html` | 个人中心 | 查看个人信息、目标分、历史入口与复盘入口 | 账户与学习管理 |
| `upload-history.html` | 上传历史页 | 按时间与筛选查看上传记录，进入题目详情 | 上传后追踪 |
| `question-aggregate.html` | 题号聚合页 | 汇总某题号统计、标签、题目列表 | 题号层分析 |
| `question-detail.html` | 单题详情页 | 查看题目、对错状态、标签，进入AI诊断 | 诊断前置 |
| `ai-diagnosis.html` | 诊断对话页 | AI追问定位、输出诊断结论、引导去训练 | 诊断分流 |
| `model-detail.html` | 模型详情页 | 查看模型掌握漏斗、前置知识、相关题、开始训练 | 训练准备 |
| `model-training.html` | 模型训练流页 | 按步骤进行模型训练并交互反馈 | 模型训练执行 |
| `knowledge-detail.html` | 知识点详情页 | 查看掌握状态与记录，进入知识点学习 | 知识学习准备 |
| `knowledge-learning.html` | 知识学习流页 | 按步骤进行知识点讲解/辨析/检测 | 知识学习执行 |
| `flashcard-review.html` | 闪卡复习页 | 卡片翻转和记忆反馈评分 | 巩固防忘执行 |
| `prediction-center.html` | 预测中心页 | 查看预测总分、趋势、提分路径与优先项 | 结果与路径 |
| `weekly-review.html` | 周复盘页 | 汇总本周变化、进展与下周重点 | 复盘升级 |

## 3. 每页功能分区（L1）说明
说明：此处“组件”指功能分区，不是代码小组件。

| 页面 | L1 功能分区 |
|---|---|
| `index.html` | 顶部学习仪表区、推荐学习区、最近上传区、上传操作区、主导航区 |
| `community.html` | 顶部导航与三选栏区、社区内容区、主导航区 |
| `global-knowledge.html` | 顶部全局切换区、学科筛选区、知识树浏览区、主导航区 |
| `global-model.html` | 顶部全局切换区、学科筛选区、模型树浏览区、主导航区 |
| `global-exam.html` | 顶部全局切换区、卷面热力图区、题型与卷子浏览区、主导航区 |
| `memory.html` | 今日复习入口区、记忆统计区、卡片分类区、主导航区 |
| `profile.html` | 个人信息与目标区、功能菜单区、学习统计区、主导航区 |
| `upload-history.html` | 顶部导航区、筛选区、历史时间线区 |
| `question-aggregate.html` | 顶部导航区、题号统计区、属性标签区、题目列表区 |
| `question-detail.html` | 顶部导航区、题目展示区、状态与标签区、诊断入口区、来源信息区 |
| `ai-diagnosis.html` | 顶部导航区、题目引用区、诊断对话区、诊断结论与行动区、输入区 |
| `model-detail.html` | 顶部导航区、掌握与训练入口区、前置知识区、相关题目区、训练记录区 |
| `model-training.html` | 顶部导航区、进度与当前步骤区、训练对话区、历史步骤结果区、输入区 |
| `knowledge-detail.html` | 顶部导航区、掌握与学习入口区、概念检测记录区、关联模型区 |
| `knowledge-learning.html` | 顶部导航区、进度与当前步骤区、学习对话区、辅助认知区、输入区 |
| `flashcard-review.html` | 顶部导航区、复习进度区、闪卡主体区、记忆反馈区 |
| `prediction-center.html` | 顶部导航区、分数总览区、趋势分析区、路径与优先级区 |
| `weekly-review.html` | 顶部导航区、本周总览区、分数变化区、本周进展区、下周重点区 |

## 4. 主流程串联（按用户操作）
## 4.1 流程A：首页推荐驱动学习
1. 用户进入 `index.html`。  
2. 在“推荐学习区”点击待诊断/模型训练/知识补强。  
3. 分别进入 `ai-diagnosis.html`、`model-detail.html` 或 `knowledge-detail.html`。  
4. 在详情页进入训练流（`model-training.html` / `knowledge-learning.html`）。  
5. 回流到预测与复盘（`prediction-center.html` / `weekly-review.html`）。

## 4.2 流程B：题目驱动诊断
1. 在 `upload-history.html` 或 `question-aggregate.html` 进入 `question-detail.html`。  
2. 点击“进入诊断”跳转 `ai-diagnosis.html`。  
3. 诊断后进入训练页（当前原型为 `model-training.html`）。

## 4.3 流程C：全局树主动学习
1. 在 `global-knowledge.html` 选中知识点进入 `knowledge-detail.html` 并学习。  
2. 在 `global-model.html` 选中模型进入 `model-detail.html` 并训练。  
3. 在 `global-exam.html` 通过题号热力图进入 `question-aggregate.html` 再到 `question-detail.html`。

## 4.4 流程D：记忆巩固
1. 在 `memory.html` 查看“今日待复习”。  
2. 点击“开始复习”进入 `flashcard-review.html`。  
3. 复习后返回 `memory.html` 查看统计变化。

## 4.5 流程E：预测与复盘
1. 从 `index.html` 进入 `prediction-center.html` 查看预测总分与路径。  
2. 从 `profile.html` 进入 `weekly-review.html` 查看本周总结与下周重点。  
3. 根据建议回到模型或知识点训练页面。

## 5. 页面间导航关系表（基于现有 `navigateTo`）
| 来源页面 | 目标页面 | 触发说明 |
|---|---|---|
| `index.html` | `ai-diagnosis.html` | 推荐项：待诊断错题 |
| `index.html` | `knowledge-detail.html` | 推荐项：知识补强 |
| `index.html` | `model-detail.html` | 推荐项：模型训练/不稳定模型 |
| `index.html` | `model-training.html` | 快速开始 |
| `index.html` | `prediction-center.html` | 预测分入口卡 |
| `index.html` | `upload-history.html` | 最近上传入口 |
| `index.html` | `upload-menu.html` | 上传弹层选项（占位页面） |
| `global-knowledge.html` | `global-model.html` | 全局子Tab切换 |
| `global-knowledge.html` | `global-exam.html` | 全局子Tab切换 |
| `global-knowledge.html` | `knowledge-detail.html` | 点击知识点节点 |
| `global-model.html` | `global-knowledge.html` | 全局子Tab切换 |
| `global-model.html` | `global-exam.html` | 全局子Tab切换 |
| `global-model.html` | `model-detail.html` | 点击模型节点 |
| `global-exam.html` | `global-knowledge.html` | 全局子Tab切换 |
| `global-exam.html` | `global-model.html` | 全局子Tab切换 |
| `global-exam.html` | `question-aggregate.html` | 点击热力图/题号列表 |
| `global-exam.html` | `upload-history.html` | 最近卷子记录入口 |
| `global-exam.html` | `upload-menu.html` | 上传卷子入口（占位页面） |
| `upload-history.html` | `index.html` | 返回 |
| `upload-history.html` | `question-detail.html` | 点击历史记录项 |
| `question-aggregate.html` | `global-exam.html` | 返回 |
| `question-aggregate.html` | `question-detail.html` | 点击题目项 |
| `question-detail.html` | `question-aggregate.html` | 返回 |
| `question-detail.html` | `ai-diagnosis.html` | 进入诊断 |
| `question-detail.html` | `knowledge-detail.html` | 标签跳转 |
| `question-detail.html` | `model-detail.html` | 标签跳转 |
| `ai-diagnosis.html` | `question-detail.html` | 返回题目 |
| `ai-diagnosis.html` | `model-training.html` | 开始针对性训练 |
| `knowledge-detail.html` | `global-knowledge.html` | 返回 |
| `knowledge-detail.html` | `knowledge-learning.html` | 开始学习 |
| `knowledge-detail.html` | `model-detail.html` | 关联模型跳转 |
| `knowledge-learning.html` | `knowledge-detail.html` | 返回 |
| `model-detail.html` | `global-model.html` | 返回 |
| `model-detail.html` | `model-training.html` | 开始训练 |
| `model-detail.html` | `knowledge-detail.html` | 前置知识点跳转 |
| `model-detail.html` | `question-detail.html` | 相关题目跳转 |
| `model-training.html` | `model-detail.html` | 返回 |
| `prediction-center.html` | `index.html` | 返回 |
| `prediction-center.html` | `model-detail.html` | 优先训练模型入口 |
| `prediction-center.html` | `question-aggregate.html` | 提分路径入口 |
| `memory.html` | `flashcard-review.html` | 开始复习 |
| `flashcard-review.html` | `memory.html` | 返回 |
| `profile.html` | `upload-history.html` | 菜单入口 |
| `profile.html` | `weekly-review.html` | 菜单入口 |
| `profile.html` | `register-strategy.html` | 修改目标分入口（占位页面） |
| `weekly-review.html` | `profile.html` | 返回 |

## 6. 验收口径（本次文档版）
1. 两份文档均覆盖 18 个现有页面。  
2. 每个页面都有“功能分区（L1）”定义。  
3. 导航关系与 HTML 中 `navigateTo` 一致。  
4. 不输出按钮级碎片化组件，统一按功能分区表达。  
5. 社区页面可清晰看到层级：三选栏区 -> 三大板块 -> 需求卡片项。

## 7. 默认项与限制
- 仅做需求与前端规划文档，不改动 HTML 原型代码。  
- 仅基于现有原型可见事实，不推演未提供页面细节。  
- 文档中的组件命名用于 Flutter 规划表达，不等同于最终代码类名。  
