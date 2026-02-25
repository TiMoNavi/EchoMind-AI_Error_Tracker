# weekly-review（周复盘）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/weekly-review`

## 组件树
```
WeeklyReviewPage (Scaffold)
├── TopFrameWidget                    ← 返回按钮 + 标题 + 周数标签
└── Expanded
    └── Stack
        ├── ClayBackgroundBlobs       ← 背景装饰
        └── ListView
            ├── WeeklyDashboardWidget ← 本周概览（闭环数/学习时长/分数变化）
            ├── ScoreChangeWidget     ← 分数变化对比卡片
            ├── WeeklyProgressWidget  ← 本周进展列表
            └── NextWeekFocusWidget   ← 下周重点建议
```

## 页面截图
![weekly-review-390x844](../flutter截图验证/weekly-review/full/weekly-review__390x844__full.png)

---

## 组件详情

### TopFrameWidget
![top_frame_widget](../flutter截图验证/weekly-review/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮、标题"周复盘"和右侧周数标签"第6周"
- 对应 dart 文件: `lib/features/weekly_review/widgets/top_frame_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题文字: `'周复盘'`
  - 周数标签: `'第6周'`
- 对应数据模型: `WeeklyReview`（来自 `lib/shared/models/weekly_review_models.dart`）
- 需要的 API 字段:
  - `period` (String) — 周期标识，用于显示周数

---

### WeeklyDashboardWidget
![weekly_dashboard_widget](../flutter截图验证/weekly-review/components/weekly_dashboard_widget__390x844.png)
- 功能说明: 本周概览卡片，显示周期文字和三个统计指标（闭环数、学习时长、预测分变化），每个指标带底部彩色装饰条
- 对应 dart 文件: `lib/features/weekly_review/widgets/weekly_dashboard_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，但有默认 mock 值）
- 硬编码值:
  - 周期: `'本周 (2月3日 - 2月9日)'`
  - 闭环数: `'12'`
  - 学习时长: `'2h25m'`
  - 分数变化: `'+3'`
- 对应数据模型: `WeeklyReview`（来自 `lib/shared/models/weekly_review_models.dart`）
- 需要的 API 字段:
  - `period` (String) — 周期描述
  - `closures` (int) — 闭环数
  - `studyTime` (String) — 学习时长
  - `scoreChange` (int) — 预测分变化

---

### ScoreChangeWidget
![score_change_widget](../flutter截图验证/weekly-review/components/score_change_widget__390x844.png)
- 功能说明: 分数变化对比卡片，左右两个分数块（上周/本周）中间用渐变箭头连接
- 对应 dart 文件: `lib/features/weekly_review/widgets/score_change_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，但有默认 mock 值）
- 硬编码值:
  - 上周分数: `'60'`
  - 本周分数: `'63'`
  - 上周标签: `'上周'`
  - 本周标签: `'本周'`
- 对应数据模型: `WeeklyReview`（来自 `lib/shared/models/weekly_review_models.dart`）
- 需要的 API 字段:
  - `scoreHistory` (List&lt;DailyScore&gt;) — 分数历史，取首尾计算变化

---

### WeeklyProgressWidget
![weekly_progress_widget](../flutter截图验证/weekly-review/components/weekly_progress_widget__390x844.png)
- 功能说明: 本周进展列表，每项显示彩色圆点（绿/黄/红）、知识点名称、等级变化描述和 UP/-- 状态标签
- 对应 dart 文件: `lib/features/weekly_review/widgets/weekly_progress_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 项1: `'匀变速直线运动'`, `'L3 --> L4 -- 做对过'`, 绿色, `'UP'`
  - 项2: `'牛顿第二定律应用'`, `'L2 --> L3 -- 执行正确一次'`, 黄色, `'UP'`
  - 项3: `'板块运动'`, `'L1 --> L1 -- 仍在建模层卡住'`, 红色, `'--'`
- 对应数据模型: `WeeklyProgress`（来自 `lib/shared/models/weekly_review_models.dart`）
- 需要的 API 字段:
  - `category` (String) — 知识点/类别名称
  - `completed` (int) — 已完成数
  - `total` (int) — 总数

---

### NextWeekFocusWidget
![next_week_focus_widget](../flutter截图验证/weekly-review/components/next_week_focus_widget__390x844.png)
- 功能说明: 下周重点建议卡片，编号列表展示 AI 推荐的下周学习重点
- 对应 dart 文件: `lib/features/weekly_review/widgets/next_week_focus_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 项1: `'板块运动 -- 完成 Step 1-3 训练'`
  - 项2: `'摩擦力知识点 -- 补强到 L3 以上'`
  - 项3: `'完成 3 张待诊断题目'`
- 对应数据模型: `NextWeekFocus`（来自 `lib/shared/models/weekly_review_models.dart`）
- 需要的 API 字段:
  - `title` (String) — 重点标题
  - `reason` (String) — 推荐原因

---

## 数据模型

```dart
// lib/shared/models/weekly_review_models.dart

class WeeklyReview {
  final String period;
  final int closures;
  final String studyTime;
  final int scoreChange;
  final List<DailyScore> scoreHistory;
}

class DailyScore {
  final String date;
  final int score;
}

class WeeklyProgress {
  final String category;
  final int completed;
  final int total;
}

class NextWeekFocus {
  final String title;
  final String reason;
}
```

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/weekly-review/current` | GET | 获取当前周复盘数据 | `WeeklyReview` |
| `/api/weekly-review/progress` | GET | 获取本周知识点进展列表 | `List<WeeklyProgress>` |
| `/api/weekly-review/next-focus` | GET | 获取下周重点建议 | `List<NextWeekFocus>` |

## 接入示例

```dart
// 1. 获取周复盘数据
final review = await api.getWeeklyReview();

// 2. 注入到 Dashboard
WeeklyDashboardWidget(
  period: review.period,
  closures: '${review.closures}',
  studyTime: review.studyTime,
  scoreChange: '+${review.scoreChange}',
);

// 3. 注入分数变化
final scores = review.scoreHistory;
ScoreChangeWidget(
  previousScore: '${scores.first.score}',
  currentScore: '${scores.last.score}',
);
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页，通常是 `/profile`）
