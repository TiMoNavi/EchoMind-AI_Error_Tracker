# question-aggregate（单题聚合）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/question-aggregate`

## 组件树
```
QuestionAggregatePage (Scaffold)
├── TopFrameWidget                    ← 返回按钮 + 题目标题
└── Expanded
    ├── ClayBackgroundBlobs
    └── ListView
        ├── SingleQuestionDashboardWidget  ← 累计做题/正确率/预测得分
        ├── ExamAnalysisWidget             ← 考试态度/高频考点/薄弱模型
        └── QuestionHistoryListWidget      ← 做过的题目列表
```

## 页面截图
![question-aggregate-390x844](../flutter截图验证/question-aggregate/full/question-aggregate__390x844__full.png)

---

## 组件详情

### TopFrameWidget
![top_frame_widget](../flutter截图验证/question-aggregate/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮和题目标题
- 对应 dart 文件: `lib/features/question_aggregate/widgets/top_frame_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题: `'选择题 第5题'`
- 对应数据模型: `QuestionAggregate`（来自 `lib/shared/models/question_aggregate_models.dart`）
- 需要的 API 字段:
  - `questionTitle` (String) — 题目标题

---

### SingleQuestionDashboardWidget
![single_question_dashboard_widget](../flutter截图验证/question-aggregate/components/single_question_dashboard_widget__390x844.png)
- 功能说明: 三列统计仪表盘，展示累计做题次数、正确率、预测得分
- 对应 dart 文件: `lib/features/question_aggregate/widgets/single_question_dashboard_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，带默认值）
- 硬编码值:
  - 累计做题: `'6'`
  - 正确率: `'33%'`
  - 预测得分: `'2/3'`
- 对应数据模型: `QuestionAggregate`（来自 `lib/shared/models/question_aggregate_models.dart`）
- 需要的 API 字段:
  - `totalAttempts` (int) — 累计做题次数
  - `accuracy` (String) — 正确率
  - `predictedScore` (String) — 预测得分

---

### ExamAnalysisWidget
![exam_analysis_widget](../flutter截图验证/question-aggregate/components/exam_analysis_widget__390x844.png)
- 功能说明: 考试分析卡片，展示考试态度标签、分值标签、高频考点列表、薄弱模型列表
- 对应 dart 文件: `lib/features/question_aggregate/widgets/exam_analysis_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，带默认值）
- 硬编码值:
  - 态度: `'MUST · 必须拿满'`
  - 分值: `'满分 3分'`
  - 高频考点: `['牛顿第二定律', '板块运动', '摩擦力']`
  - 薄弱模型: `['板块运动 L1']`
  - 薄弱模型(outline): `['牛顿第二定律应用 L3']`
- 对应数据模型: `ExamAnalysis`（来自 `lib/shared/models/question_aggregate_models.dart`）
- 需要的 API 字段:
  - `examName` (String) — 考试名称
  - `tag` (String) — 态度/分值标签
  - `result` (String) — 分析结果

---

### QuestionHistoryListWidget
![question_history_list_widget](../flutter截图验证/question-aggregate/components/question_history_list_widget__390x844.png)
- 功能说明: 做过的题目列表，每项显示对错状态图标、考试来源、日期及诊断状态，点击跳转题目详情
- 对应 dart 文件: `lib/features/question_aggregate/widgets/question_history_list_widget.dart`
- 当前数据状态: 硬编码 mock（静态 `_items` 列表）
- 硬编码值:
  - `(correct: false, exam: '2025天津模拟(一) 第5题', desc: '2月8日 · 待诊断')`
  - `(correct: false, exam: '2024天津模拟(三) 第5题', desc: '2月4日 · 已诊断: 建模层出错')`
  - `(correct: true, exam: '2024天津真题 第5题', desc: '2月3日')`
  - `(correct: false, exam: '2024天津模拟(一) 第5题', desc: '1月28日 · 已诊断: 执行层出错')`
  - `(correct: false, exam: '2023天津真题 第5题', desc: '1月25日 · 已诊断: 建模层出错')`
  - `(correct: true, exam: '2023天津模拟(二) 第5题', desc: '1月20日')`
- 对应数据模型: `QuestionHistory`（来自 `lib/shared/models/question_aggregate_models.dart`）
- 需要的 API 字段:
  - `date` (String) — 做题日期
  - `result` (String) — 对错结果
  - `timeSpent` (String) — 耗时
  - `errorType` (String) — 错误类型

---

## 数据模型

```dart
// lib/shared/models/question_aggregate_models.dart

class QuestionAggregate {
  final String questionTitle;
  final int totalAttempts;
  final String accuracy;
  final String predictedScore;
  final List<ExamAnalysis> examAnalysis;
  final List<QuestionHistory> history;
}
```

```dart
class ExamAnalysis {
  final String examName;
  final String tag;
  final String result;
}

class QuestionHistory {
  final String date;
  final String result;
  final String timeSpent;
  final String errorType;
}
```

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/question/{id}/aggregate` | GET | 获取单题聚合数据（统计+分析+历史） | `QuestionAggregate` |

## 接入示例

```dart
final response = await api.get('/api/question/$questionId/aggregate');
final data = QuestionAggregate.fromJson(response.data);

// 注入到各组件
SingleQuestionDashboardWidget(
  totalAttempts: '${data.totalAttempts}',
  accuracy: data.accuracy,
  predictedScore: data.predictedScore,
);
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页）
- 题目历史项点击 → `/question-detail`
