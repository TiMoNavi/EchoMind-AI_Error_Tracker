# global-exam（全局高考卷）

## 当前状态

第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识

`/global-exam`

## 组件树

```
GlobalExamPage (PageShell, tabIndex: 1)
├── ClayBackgroundBlobs — Claymorphism 浮动背景
├── TopFrameWidget — 页面标题「全局知识」+ Clay Tab 栏（activeIndex=2 高考卷子）
├── ExamHeatmapWidget — 题号热力图（Squarified Treemap）
├── QuestionTypeBrowserWidget — 按题型浏览（选择题/实验题/计算题）
└── RecentExamsWidget — 最近卷子列表
```

## 页面截图

![global-exam-390x844](../flutter截图验证/global-exam/full/global-exam__390x844__full.png)

---

## 组件详情

### top-frame

![top-frame](../flutter截图验证/global-exam/components/top-frame__390x844.png)

- 功能说明: 页面标题「全局知识」+ Clay 凹陷 Tab 栏，当前激活「高考卷子」
- 对应 dart 文件: `lib/features/global_exam/widgets/top_frame_widget.dart`
- 当前数据状态: 静态，activeIndex 硬编码为 2
- 硬编码值:
  - 标题: `'全局知识'`
  - Tab 列表: `['知识点', '模型/方法', '高考卷子']`
  - 路由映射: `['/global-knowledge', '/global-model', null]`
- 对应数据模型: 无（纯导航组件）
- 需要的 API 字段: 无

---

### exam-heatmap

![exam-heatmap](../flutter截图验证/global-exam/components/exam-heatmap__390x844.png)

- 功能说明: 题号热力图，使用 Squarified Treemap 算法按错误频率分配面积，颜色表示掌握等级
- 对应 dart 文件: `lib/features/global_exam/widgets/exam_heatmap_widget.dart`
- 当前数据状态: 硬编码 mock（已参数化为构造函数参数）
- 硬编码值:
  - 20 道题的 `(num, freq, level)` 数据，如: `(5, 18, 1)`, `(10, 16, 0)`, `(15, 15, 0)` 等
  - 图例: 未掌握(0)/薄弱(1)/不稳定(2)/一般(3)/良好(4)/掌握(5)
- 注意: widget 内部定义了本地 `HeatmapQuestion` 类（`num/freq/level` 均为 int），需迁移到 shared model
- 对应数据模型: `HeatmapQuestion`（来自 `lib/shared/models/global_models.dart`）
- 需要的 API 字段:
  - `question_num` (int) — 题号
  - `frequency` (int) — 错误频率
  - `mastery_level` (String) — 掌握等级

---

### question-type-browser

![question-type-browser](../flutter截图验证/global-exam/components/question-type-browser__390x844.png)

- 功能说明: 按题型浏览卡片列表（选择题/实验题/计算题），每项显示题号范围和掌握计数
- 对应 dart 文件: `lib/features/global_exam/widgets/question_type_browser_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - `('选择题', '第1-8题', '6/8 掌握', level:4, icon: check_circle_outline)`
  - `('实验题', '第9-11题', '1/3 掌握', level:2, icon: science_outlined)`
  - `('计算题', '第12-14题', '0/3 掌握', level:0, icon: calculate_outlined)`
- 对应数据模型: 无独立模型（可复用 `HeatmapQuestion` 按题型分组聚合）
- 需要的 API 字段:
  - `title` (String) — 题型名称
  - `subtitle` (String) — 题号范围
  - `count` (String) — 掌握计数
  - `level` (int) — 掌握等级

---

### recent-exams

![recent-exams](../flutter截图验证/global-exam/components/recent-exams__390x844.png)

- 功能说明: 最近卷子列表，每项显示卷名、日期、录入进度
- 对应 dart 文件: `lib/features/global_exam/widgets/recent_exams_widget.dart`
- 当前数据状态: 硬编码 mock（已参数化为构造函数参数）
- 硬编码值:
  - `('2025天津模拟卷', '2025-01-15', '14/20 已录入')`
  - `('2024全国甲卷', '2024-12-20', '20/20 已录入')`
  - `('2024天津期末卷', '2024-11-30', '8/20 已录入')`
- 注意: widget 内部定义了本地 `RecentExam` 类（`title/date/count`），需迁移到 shared model
- 对应数据模型: `ExamRecord`（来自 `lib/shared/models/global_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 卷子唯一标识
  - `exam_name` (String) — 卷名
  - `date` (String) — 日期
  - `score` (int) — 分数
  - `error_count` (int) — 错题数

---

## 数据模型

来自 `lib/shared/models/global_models.dart`：

```dart
class HeatmapQuestion {
  final int questionNum;
  final int frequency;
  final String masteryLevel;
}

class ExamRecord {
  final String id;
  final String examName;
  final String date;
  final int score;
  final int errorCount;
}
```

## API 接口清单

| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/global/exam/heatmap` | GET | 获取题号热力图数据 | `List<HeatmapQuestion>` |
| `/api/global/exam/question-types` | GET | 获取按题型分组的掌握统计 | `List<QuestionType>` |
| `/api/global/exam/recent` | GET | 获取最近卷子列表 | `List<ExamRecord>` |

## 接入示例

```dart
// 获取热力图数据
final heatResp = await api.get('/api/global/exam/heatmap');
final questions = (heatResp.data as List)
    .map((e) => HeatmapQuestion.fromJson(e))
    .toList();

ExamHeatmapWidget(questions: questions);

// 获取最近卷子
final examResp = await api.get('/api/global/exam/recent');
final exams = (examResp.data as List)
    .map((e) => ExamRecord.fromJson(e))
    .toList();

RecentExamsWidget(exams: exams);
```

## 页面跳转

- Tab「知识点」→ `/global-knowledge`
- Tab「模型/方法」→ `/global-model`
- 热力图题块点击 → `/question-aggregate`
- 题型卡片点击 → `/question-aggregate`
- 卷子卡片点击 → `/upload-history`
