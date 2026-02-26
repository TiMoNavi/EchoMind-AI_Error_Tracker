# 周复盘功能实现设计文档

> 创建日期：2026-02-26
> 状态：设计阶段，待用户审批
> 作者：claude-3 (peer)
> 依据：v1.0.md（产品核心框架 §31/§54）、architecture.md、后端已有实现

---

## 一、概述

### 1.1 功能定位

周复盘是 EchoMind 六步学习闭环的最后一环（发现→诊断→训练→验证→巩固→**复盘**）。每周末系统自动生成一份学习报告，帮助学生回顾本周学习成果、识别薄弱环节、明确下周方向。

| 模块 | 内容 | 数据来源 |
|------|------|---------|
| 分数变化 | 上周 vs 本周预测分对比 | `score_change`（正确率×150 差值） |
| 学习仪表盘 | 做题数、正确率、错题数、新掌握数 | `weekly_progress` |
| 四维能力快照 | 公式记忆率/模型识别率/执行正确率/综合正确率 | `dashboard_stats` |
| 本周进展 | 新掌握的知识点/模型列表 | 需后端扩展 |
| 下周重点 | Top 5 薄弱知识点/模型 | `next_week_focus`（ID 列表） |

### 1.2 设计约束

- 后端 API 已完成（`GET /weekly-review`），本文档重点设计前端对接方案
- 前端数据模型与后端响应存在显著不匹配，需要适配层改造
- 产品规格要求：AI 叙事摘要（~100字）、等级变化表、Top 3 推荐 — V1 暂不实现 AI 叙事，后续迭代
- 周报数据为只读展示，无写入操作

---

## 二、后端现状分析

### 2.1 已有 API 端点

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/api/weekly-review` | 获取当前用户周报数据 | JWT |

### 2.2 后端响应结构

```json
{
  "score_change": 3.5,
  "weekly_progress": {
    "total_questions": 42,
    "correct_count": 35,
    "error_count": 7,
    "new_mastered": 3
  },
  "dashboard_stats": {
    "formula_memory_rate": 0.85,
    "model_identify_rate": 0.72,
    "execution_correct_rate": 0.80,
    "overall_correct_rate": 0.83
  },
  "next_week_focus": ["kp_001", "model_003", "kp_012", "model_007", "kp_005"]
}
```

### 2.3 后端服务逻辑（`weekly_review_service.py`）

| 字段 | 计算逻辑 |
|------|---------|
| `score_change` | (本周正确率 - 上周正确率) × 150 |
| `weekly_progress` | 本周 7 天内的 questions 表聚合统计 |
| `dashboard_stats` | 四维能力指标：从 `student_mastery` 表按 target_type 聚合 |
| `next_week_focus` | `student_mastery` 中 level 最低的 Top 5 target_id |

---

## 三、前端现状与差异分析

### 3.1 当前前端数据模型

```dart
// providers/weekly_review_provider.dart
class WeeklyReviewData {
  final int questionCount;        // ← 后端: weekly_progress.total_questions
  final double correctRate;       // ← 后端: 需计算 correct_count / total_questions
  final int trainingCount;        // ← 后端: ❌ 无对应字段
  final double studyHours;        // ← 后端: ❌ 无对应字段
  final double lastWeekScore;     // ← 后端: ❌ 无（只有 score_change 差值）
  final double thisWeekScore;     // ← 后端: ❌ 无（只有 score_change 差值）
  final List<String> progressItems; // ← 后端: ❌ 无对应字段
  final List<String> focusItems;  // ← 后端: next_week_focus（但是 ID 列表，非展示文本）
}
```

### 3.2 差异汇总

| 前端字段 | 后端对应 | 差异类型 | 解决方案 |
|---------|---------|---------|---------|
| `questionCount` | `weekly_progress.total_questions` | 字段路径不同 | fromJson 适配 |
| `correctRate` | 需计算 | 缺少直接字段 | 前端计算 `correct_count/total_questions` |
| `trainingCount` | 无 | 后端缺失 | **方案A**: 后端扩展 / **方案B**: 前端隐藏 |
| `studyHours` | 无 | 后端缺失 | **方案A**: 后端扩展 / **方案B**: 前端隐藏 |
| `lastWeekScore` | 无（只有差值） | 结构不同 | **后端扩展**返回两个分数 |
| `thisWeekScore` | 无（只有差值） | 结构不同 | **后端扩展**返回两个分数 |
| `progressItems` | 无 | 后端缺失 | 从 `new_mastered` + 名称查询生成 |
| `focusItems` | `next_week_focus`（ID） | 类型不同 | 后端返回名称或前端查询 |
| — | `weekly_progress.error_count` | 前端未使用 | 新增展示 |
| — | `weekly_progress.new_mastered` | 前端未使用 | 映射到 progressItems |
| — | `dashboard_stats` | 前端未使用 | 新增四维能力卡片 |

### 3.3 当前 Widget 结构

```
WeeklyReviewPage
├── TopFrameWidget          — 标题栏（硬编码"第3周"）
├── WeeklyDashboardWidget   — 四格统计（questionCount/correctRate/trainingCount/studyHours）
├── ScoreChangeWidget       — 分数变化（lastWeekScore → thisWeekScore）
├── WeeklyProgressWidget    — 本周进展（progressItems 列表）
└── NextWeekFocusWidget     — 下周重点（focusItems 列表）
```

---

## 四、前端改造方案

### 4.1 后端响应扩展（推荐）

为减少前端复杂度，建议后端 `WeeklyReviewResponse` 扩展以下字段：

```python
# backend/app/schemas/weekly_review.py — 扩展
class WeeklyReviewResponse(BaseModel):
    score_change: float
    weekly_progress: WeeklyProgress
    dashboard_stats: dict
    next_week_focus: list[str]
    # ---- 新增字段 ----
    last_week_score: float = Field(description="上周预测分（正确率×150）")
    this_week_score: float = Field(description="本周预测分（正确率×150）")
    progress_items: list[str] = Field(description="本周新掌握的知识点/模型名称列表")
    focus_item_names: list[str] = Field(description="下周重点的知识点/模型名称列表")
```

对应 `weekly_review_service.py` 扩展：
```python
# 在 get_weekly_review() 中新增计算
this_week_rate = correct_count / total_questions if total_questions > 0 else 0
this_week_score = this_week_rate * 150
last_week_score = this_week_score - score_change

# progress_items: 查询本周新达到 L3+ 的 mastery 记录的名称
# focus_item_names: 将 next_week_focus 的 ID 解析为名称
```

### 4.2 前端数据模型改造

```dart
// providers/weekly_review_provider.dart — 改造后

class WeeklyReviewData {
  // 基础统计
  final int totalQuestions;
  final int correctCount;
  final int errorCount;
  final int newMastered;

  // 分数变化
  final double scoreChange;
  final double lastWeekScore;
  final double thisWeekScore;

  // 四维能力
  final double formulaMemoryRate;
  final double modelIdentifyRate;
  final double executionCorrectRate;
  final double overallCorrectRate;

  // 列表数据
  final List<String> progressItems;
  final List<String> focusItems;

  // 计算属性
  double get correctRate =>
      totalQuestions > 0 ? correctCount / totalQuestions : 0;

  const WeeklyReviewData({
    this.totalQuestions = 0,
    this.correctCount = 0,
    this.errorCount = 0,
    this.newMastered = 0,
    this.scoreChange = 0,
    this.lastWeekScore = 0,
    this.thisWeekScore = 0,
    this.formulaMemoryRate = 0,
    this.modelIdentifyRate = 0,
    this.executionCorrectRate = 0,
    this.overallCorrectRate = 0,
    this.progressItems = const [],
    this.focusItems = const [],
  });

  factory WeeklyReviewData.fromJson(Map<String, dynamic> json) {
    final progress = json['weekly_progress'] as Map<String, dynamic>? ?? {};
    final stats = json['dashboard_stats'] as Map<String, dynamic>? ?? {};
    return WeeklyReviewData(
      totalQuestions: progress['total_questions'] ?? 0,
      correctCount: progress['correct_count'] ?? 0,
      errorCount: progress['error_count'] ?? 0,
      newMastered: progress['new_mastered'] ?? 0,
      scoreChange: (json['score_change'] as num?)?.toDouble() ?? 0,
      lastWeekScore: (json['last_week_score'] as num?)?.toDouble() ?? 0,
      thisWeekScore: (json['this_week_score'] as num?)?.toDouble() ?? 0,
      formulaMemoryRate: (stats['formula_memory_rate'] as num?)?.toDouble() ?? 0,
      modelIdentifyRate: (stats['model_identify_rate'] as num?)?.toDouble() ?? 0,
      executionCorrectRate: (stats['execution_correct_rate'] as num?)?.toDouble() ?? 0,
      overallCorrectRate: (stats['overall_correct_rate'] as num?)?.toDouble() ?? 0,
      progressItems: (json['progress_items'] as List?)?.cast<String>() ?? [],
      focusItems: (json['focus_item_names'] as List?)?.cast<String>() ?? [],
    );
  }
}
```

### 4.3 Widget 改造清单

#### 4.3.1 TopFrameWidget — 动态周数

```dart
// 当前：硬编码 "第3周"
// 改造：根据当前日期计算学期周数
class TopFrameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weekNum = _calculateWeekNumber(); // 基于学期开始日期
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
      child: Row(children: [
        IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 20)),
        const Text('周复盘', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('第${weekNum}周', style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
      ]),
    );
  }
}
```

#### 4.3.2 WeeklyDashboardWidget — 四格改为匹配后端

```dart
// 当前：做题数 / 正确率 / 训练次数 / 学习时长
// 改造：做题数 / 正确数 / 错题数 / 新掌握
// 原因：trainingCount 和 studyHours 后端无数据，用已有字段替代
Widget build(BuildContext context, WidgetRef ref) {
  final data = ref.watch(weeklyReviewProvider);
  return data.when(
    data: (d) => Row(children: [
      _Stat('做题数', '${d.totalQuestions}'),
      _Stat('正确', '${d.correctCount}'),
      _Stat('错题', '${d.errorCount}'),
      _Stat('新掌握', '${d.newMastered}'),
    ]),
    // ...
  );
}
```

#### 4.3.3 ScoreChangeWidget — 适配新字段

```dart
// 当前：使用 lastWeekScore / thisWeekScore
// 改造：字段名不变，fromJson 已适配后端扩展字段
// 额外：增加 scoreChange 的箭头指示（↑/↓）
```

#### 4.3.4 WeeklyProgressWidget — 无变化

```dart
// 当前：渲染 progressItems 列表
// 改造：无需改动 Widget 本身，数据由后端新增 progress_items 字段提供
```

#### 4.3.5 NextWeekFocusWidget — 无变化

```dart
// 当前：渲染 focusItems 列表
// 改造：无需改动 Widget 本身，数据由后端新增 focus_item_names 字段提供
```

#### 4.3.6 新增：DashboardStatsWidget — 四维能力雷达

```dart
// 新增 Widget：展示四维能力快照
// 位置：WeeklyDashboardWidget 下方
class DashboardStatsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(weeklyReviewProvider);
    return data.when(
      data: (d) => Container(
        child: Column(children: [
          const Text('能力快照'),
          _AbilityBar('公式记忆', d.formulaMemoryRate),
          _AbilityBar('模型识别', d.modelIdentifyRate),
          _AbilityBar('执行正确', d.executionCorrectRate),
          _AbilityBar('综合正确', d.overallCorrectRate),
        ]),
      ),
    );
  }
}
```

---

## 五、改造后页面结构

```
WeeklyReviewPage（改造后）
├── TopFrameWidget              — 标题栏 + 动态周数
├── ScoreChangeWidget           — 分数变化（上周分 → 本周分 + 差值标签）
├── WeeklyDashboardWidget       — 四格统计（做题/正确/错题/新掌握）
├── DashboardStatsWidget [新增] — 四维能力进度条
├── WeeklyProgressWidget        — 本周进展（新掌握的知识点/模型名称）
└── NextWeekFocusWidget         — 下周重点（薄弱项名称列表）
```

---

## 六、实施阶段规划

### Phase 1：后端扩展（小改动）

| 步骤 | 内容 | 产出文件 |
|------|------|---------|
| 1.1 | `WeeklyReviewResponse` 新增 4 个字段 | `app/schemas/weekly_review.py` |
| 1.2 | `weekly_review_service.py` 计算新增字段 | `app/services/weekly_review_service.py` |

验收标准：`curl GET /api/weekly-review` 返回完整数据（含 last_week_score、progress_items 等）

### Phase 2：前端数据层改造

| 步骤 | 内容 | 产出文件 |
|------|------|---------|
| 2.1 | 重写 `WeeklyReviewData` 数据模型 + fromJson | `providers/weekly_review_provider.dart` |

验收标准：Provider 正确解析后端响应，所有字段有值

### Phase 3：前端 Widget 改造

| 步骤 | 内容 | 产出文件 |
|------|------|---------|
| 3.1 | TopFrameWidget 动态周数 | `widgets/top_frame_widget.dart` |
| 3.2 | WeeklyDashboardWidget 四格改为后端字段 | `widgets/weekly_dashboard_widget.dart` |
| 3.3 | 新增 DashboardStatsWidget 四维能力条 | `widgets/dashboard_stats_widget.dart`（新建） |
| 3.4 | WeeklyReviewPage 插入新 Widget | `weekly_review_page.dart` |

验收标准：Flutter App 中周复盘页面正确展示所有后端数据，无 mock 数据残留

---

## 七、数据流总览

```
┌─────────────┐     GET /weekly-review     ┌──────────────────┐
│  Flutter App │ ────────────────────────→  │  FastAPI Router   │
│              │                            │  /weekly-review   │
│  weeklyReview│     JSON Response          │                   │
│  Provider    │ ←────────────────────────  │                   │
│              │                            └────────┬──────────┘
│  fromJson()  │                                     │
│  适配层       │                            ┌────────▼──────────┐
│              │                            │ weekly_review_     │
│  5 Widgets   │                            │ service.py         │
│  渲染数据     │                            │                   │
└─────────────┘                            │ 聚合 questions     │
                                           │ 聚合 student_mastery│
                                           │ 计算四维能力        │
                                           └────────┬──────────┘
                                                    │
                                           ┌────────▼──────────┐
                                           │   PostgreSQL       │
                                           │   questions        │
                                           │   student_mastery  │
                                           │   students         │
                                           └───────────────────┘
```
