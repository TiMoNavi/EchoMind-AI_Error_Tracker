# register-strategy（学习策略）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/register-strategy`

## 组件树
```
RegisterStrategyPage (Scaffold, StatefulWidget)
├── _buildTopBar()                    ← 返回按钮 + 标题"卷面策略"
└── Expanded
    └── SingleChildScrollView
        ├── _buildExamSelector()      ← 科目切换（物理/数学/化学）
        ├── _buildOverviewCard()      ← 总分/目标/时长 概览卡片
        ├── _buildSectionsTitle()     ← "题型分配"标题
        ├── _buildSectionCard() ×N    ← 各题型分配卡片
        └── _buildTipsCard()          ← 答题建议卡片
```

## 页面截图
![register-strategy-390x844](../flutter截图验证/register-strategy/full/register-strategy__390x844__full.png)

---

## 组件详情

### TopBar（内联方法）
![top_frame_widget](../flutter截图验证/register-strategy/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮和页面标题"卷面策略"
- 对应 dart 文件: `lib/features/register_strategy/register_strategy_page.dart`（`_buildTopBar()` 方法）
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题文字: `'卷面策略'`
- 对应数据模型: 无独立模型
- 需要的 API 字段: 无（纯静态标题）

---

### ExamSelector（内联方法）
- 功能说明: 科目切换按钮组，Wrap 布局的胶囊按钮，选中态为紫色背景 + 阴影
- 对应 dart 文件: `lib/features/register_strategy/register_strategy_page.dart`（`_buildExamSelector()` 方法）
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 科目列表: `['物理', '数学', '化学']`
  - 默认选中: `'物理'`
- 对应数据模型: 无独立模型
- 需要的 API 字段:
  - `examSubjects` (List&lt;String&gt;) — 用户已配置的考试科目列表

---

### OverviewCard（内联方法）
![main_content_widget](../flutter截图验证/register-strategy/components/main_content_widget__390x844.png)
- 功能说明: 考试概览卡片，三列展示总分、目标分和考试时长，中间用圆点分隔
- 对应 dart 文件: `lib/features/register_strategy/register_strategy_page.dart`（`_buildOverviewCard()` 方法）
- 当前数据状态: 硬编码 mock
- 硬编码值（物理）:
  - 总分: `110`
  - 考试时长: `90 min`
  - 目标分: `85`
- 硬编码值（数学）:
  - 总分: `150`, 时长: `120 min`, 目标: `120`
- 硬编码值（化学）:
  - 总分: `100`, 时长: `75 min`, 目标: `78`
- 对应数据模型: 无独立模型（页面内部 `_ExamStrategy` 类）
- 需要的 API 字段:
  - `totalScore` (int) — 总分
  - `totalTime` (int) — 考试时长（分钟）
  - `targetScore` (int) — 目标分数

---

### SectionCard（内联方法）
- 功能说明: 题型分配卡片，每张卡片显示题型名称、题数/分值/时间三个彩色标签、分值占比进度条和答题建议
- 对应 dart 文件: `lib/features/register_strategy/register_strategy_page.dart`（`_buildSectionCard()` 方法）
- 当前数据状态: 硬编码 mock
- 硬编码值（物理）:
  - 选择题: 8题, 48分, 25min, `'每题 3 分钟，不确定先跳过'`
  - 实验题: 2题, 15分, 18min, `'画图题注意标注，公式写全'`
  - 计算题: 4题, 47分, 40min, `'先做熟悉的，大题写步骤拿过程分'`
- 对应数据模型: 无独立模型（页面内部 `_Section` 类）
- 需要的 API 字段:
  - `name` (String) — 题型名称
  - `count` (int) — 题目数量
  - `score` (int) — 分值
  - `minutes` (int) — 建议用时
  - `tip` (String) — 答题建议

---

### TipsCard（内联方法）
- 功能说明: 答题建议卡片，灯泡图标 + 标题，编号列表展示答题技巧
- 对应 dart 文件: `lib/features/register_strategy/register_strategy_page.dart`（`_buildTipsCard()` 方法）
- 当前数据状态: 硬编码 mock
- 硬编码值（物理）:
  - `'选择题控制在 25 分钟内完成'`
  - `'计算题先审题画受力图再动笔'`
  - `'最后 5 分钟检查涂卡和单位'`
- 对应数据模型: 无独立模型（页面内部 `_ExamStrategy.tips`）
- 需要的 API 字段:
  - `tips` (List&lt;String&gt;) — 答题建议列表

---

## 数据模型

无独立共享数据模型。本页使用页面内部私有类管理策略数据：

```dart
// 页面内部类（register_strategy_page.dart）

class _ExamStrategy {
  final int totalScore;
  final int totalTime;
  final int targetScore;
  final List<_Section> sections;
  final List<String> tips;
}

class _Section {
  final String name;
  final int count;
  final int score;
  final int minutes;
  final String tip;
}
```

> **备注**: `widgets/top_frame_widget.dart` 和 `widgets/main_content_widget.dart` 均为 `Placeholder` 占位组件，实际 UI 全部在页面文件的内联方法中实现。接入 API 时建议将 `_ExamStrategy` 和 `_Section` 提取为共享模型。

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/strategy/{subject}` | GET | 获取指定科目的卷面策略 | `ExamStrategy` |
| `/api/strategy/{subject}` | PUT | 更新指定科目的卷面策略 | `ExamStrategy` |
| `/api/user/exam-subjects` | GET | 获取用户已配置的考试科目列表 | `List<String>` |

## 接入示例

```dart
// 1. 获取科目列表
final subjects = await api.getExamSubjects();
setState(() => _exams = subjects);

// 2. 获取指定科目策略
final strategy = await api.getStrategy(_selectedExam);
setState(() => _strategies[_selectedExam] = strategy);

// 3. 渲染概览卡片
_buildOverviewCard(strategy);
// 4. 渲染题型分配
...strategy.sections.map(_buildSectionCard);
// 5. 渲染答题建议
_buildTipsCard(strategy);
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页，通常是 `/profile`）
