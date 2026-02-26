# 预测中心功能实现设计文档

> 创建日期：2026-02-26
> 状态：设计阶段，待用户审批
> 作者：claude-3 (peer)
> 依据：v1.0.md（产品核心框架 §27/§28）、architecture.md、后端已有实现

---

## 一、概述

### 1.1 功能定位

预测中心是 EchoMind 的"学习 GPS 导航仪"。基于学生的知识点/模型掌握度数据，预测考试得分、展示趋势变化、推荐优先训练方向，帮助学生将有限精力投入到提分效率最高的环节。

| 模块 | 内容 | 数据来源 |
|------|------|---------|
| 预测得分卡 | 当前预测分 vs 目标分 | `predicted_score` + `students.target_score` |
| 趋势图 | 近 30 天预测分走势 | `trend_data`（日正确率×150） |
| 优先训练模型 | Top 5 最薄弱模型 | `priority_models` |
| 提分路径表 | 四维能力当前 vs 目标 | `score_path` |

### 1.2 设计约束

- 后端 API 已完成（`GET /prediction/score`），本文档重点设计前端对接方案
- V1 为粗粒度预测：基于 `level_to_prob` 映射 + 木桶原理，非 ML 模型
- 前端数据模型与后端响应存在结构性不匹配，需要适配层改造
- 预测数据为只读展示，无写入操作
- 产品规格要求考试 Tab 叠加层展示预测分 — V1 暂不实现叠加层，仅做独立页面

---

## 二、后端现状分析

### 2.1 已有 API 端点

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/api/prediction/score` | 获取当前用户预测数据 | JWT |

### 2.2 后端响应结构

```json
{
  "predicted_score": 108.5,
  "trend_data": [
    {"date": "2026-02-20", "score": 102.0},
    {"date": "2026-02-21", "score": 105.0},
    {"date": "2026-02-22", "score": 108.5}
  ],
  "priority_models": [
    {"model_id": "model_003", "model_name": "受力分析", "current_level": 2, "error_count": 5},
    {"model_id": "model_007", "model_name": "运动学", "current_level": 1, "error_count": 8}
  ],
  "score_path": [
    {"label": "公式记忆", "current": 85.0, "target": 95.0},
    {"label": "模型识别", "current": 72.0, "target": 90.0},
    {"label": "执行正确", "current": 80.0, "target": 92.0},
    {"label": "综合正确", "current": 83.0, "target": 90.0}
  ]
}
```

### 2.3 后端服务逻辑（`prediction_service.py`）

| 字段 | 计算逻辑 |
|------|---------|
| `predicted_score` | 直接读取 `students.predicted_score`（由其他流程更新） |
| `trend_data` | 近 30 天每日正确率 × 150，按日期排列 |
| `priority_models` | `student_mastery` 中 target_type='model' 且 level 最低的 Top 5 |
| `score_path` | 四维能力指标（公式记忆/模型识别/执行正确/综合正确）的当前值 vs 目标值 |

---

## 三、前端现状与差异分析

### 3.1 当前前端数据模型

```dart
// providers/prediction_provider.dart
class PredictionScore {
  final double predictedScore;          // ← 后端: predicted_score ✅
  final double targetScore;             // ← 后端: ❌ 无对应字段（默认 85）
  final List<ScorePathItem> scorePath;  // ← 后端: score_path（结构完全不同）
  final List<TrendPoint> trend;         // ← 后端: trend_data（字段名不同）
  final List<PriorityModel> priorityModels; // ← 后端: priority_models（字段名不同）
}

class ScorePathItem {
  final String questionLabel;  // ← 后端: label（语义不同）
  final String score;          // ← 后端: 无（后端是 current/target 数值）
  final String modelName;      // ← 后端: 无
  final String modelId;        // ← 后端: 无
  final String priority;       // ← 后端: 无
}

class TrendPoint {
  final String label;   // ← 后端: date（格式不同：W1 vs 2026-02-20）
  final double value;   // ← 后端: score ✅（值语义相同）
}

class PriorityModel {
  final String modelId;     // ← 后端: model_id ✅
  final String modelName;   // ← 后端: model_name ✅
  final int level;          // ← 后端: current_level（字段名不同）
  final String description; // ← 后端: error_count（类型和语义不同）
}
```

### 3.2 差异汇总

| 前端字段 | 后端对应 | 差异类型 | 解决方案 |
|---------|---------|---------|---------|
| `PredictionScore.targetScore` | 无 | 后端缺失 | **后端扩展**：从 `students.target_score` 返回 |
| `TrendPoint.label` | `trend_data[].date` | 字段名+格式不同 | fromJson 适配：date→label，截取月日 |
| `TrendPoint.value` | `trend_data[].score` | 字段名不同 | fromJson 适配：score→value |
| `PriorityModel.level` | `current_level` | 字段名不同 | fromJson 适配 |
| `PriorityModel.description` | `error_count` | 类型+语义不同 | fromJson 转换：`"错题 ${error_count} 道"` |
| `ScorePathItem` 整体 | `score_path[]` | **结构完全不同** | 重新设计数据模型（见 §4.2） |

### 3.3 ScorePathItem 结构性差异详解

前端 `ScorePathItem` 设计为"题号→分数→关联模型→优先级"的表格行，但后端 `score_path` 返回的是"四维能力维度→当前值→目标值"。两者语义完全不同：

| 维度 | 前端（当前） | 后端（实际） |
|------|------------|------------|
| 行含义 | 一道具体题目 | 一个能力维度 |
| 列结构 | 题号/分值/模型名/优先级 | 维度名/当前分/目标分 |
| 数据量 | N 道题 | 固定 4 行 |

**结论**：前端 `ScorePathItem` 需要完全重写以匹配后端的四维能力结构。

### 3.4 当前 Widget 结构

```
PredictionCenterPage
├── TopFrameWidget           — 标题栏（纯 UI）
├── ScoreCardWidget          — 预测得分卡（predictedScore / targetScore）
├── TrendCardWidget          — 趋势折线图（trend: List<TrendPoint>）
├── ScorePathTableWidget     — 提分路径表（scorePath: List<ScorePathItem>）
└── PriorityModelListWidget  — 优先训练模型（priorityModels: List<PriorityModel>）
```

---

## 四、前端改造方案

### 4.1 后端响应扩展（小改动）

为支持 ScoreCardWidget 的目标分展示，后端需新增 `target_score` 字段：

```python
# backend/app/schemas/prediction.py — 扩展
class PredictionResponse(BaseModel):
    predicted_score: float | None
    target_score: float = Field(description="学生目标分数，来自 students.target_score")  # 新增
    trend_data: list[TrendPoint]
    priority_models: list[PriorityModel]
    score_path: list[ScorePathRow]
```

对应 `prediction_service.py` 扩展：
```python
# 在 get_prediction() 返回中新增
target_score=user.target_score or 90.0,
```

### 4.2 前端数据模型改造

```dart
// providers/prediction_provider.dart — 改造后

class PredictionScore {
  final double predictedScore;
  final double targetScore;
  final List<ScorePathRow> scorePath;    // 重命名：ScorePathItem → ScorePathRow
  final List<TrendPoint> trend;
  final List<PriorityModel> priorityModels;

  const PredictionScore({
    required this.predictedScore,
    required this.targetScore,
    required this.scorePath,
    required this.trend,
    required this.priorityModels,
  });

  factory PredictionScore.fromJson(Map<String, dynamic> json) => PredictionScore(
    predictedScore: (json['predicted_score'] as num?)?.toDouble() ?? 0,
    targetScore: (json['target_score'] as num?)?.toDouble() ?? 90,
    scorePath: (json['score_path'] as List?)
        ?.map((e) => ScorePathRow.fromJson(e)).toList() ?? [],
    trend: (json['trend_data'] as List?)          // 注意：后端字段名是 trend_data
        ?.map((e) => TrendPoint.fromJson(e)).toList() ?? [],
    priorityModels: (json['priority_models'] as List?)
        ?.map((e) => PriorityModel.fromJson(e)).toList() ?? [],
  );
}

/// 四维能力行（完全重写，替代原 ScorePathItem）
class ScorePathRow {
  final String label;      // 维度名称：公式记忆/模型识别/执行正确/综合正确
  final double current;    // 当前值（百分比 × 100）
  final double target;     // 目标值

  const ScorePathRow({
    required this.label,
    required this.current,
    required this.target,
  });

  double get gap => target - current;

  factory ScorePathRow.fromJson(Map<String, dynamic> json) => ScorePathRow(
    label: json['label'] ?? '',
    current: (json['current'] as num?)?.toDouble() ?? 0,
    target: (json['target'] as num?)?.toDouble() ?? 0,
  );
}

/// 趋势点（字段名适配）
class TrendPoint {
  final String label;
  final double value;

  const TrendPoint({required this.label, required this.value});

  factory TrendPoint.fromJson(Map<String, dynamic> json) => TrendPoint(
    label: _formatDate(json['date'] ?? ''),   // date → label，截取月日
    value: (json['score'] as num?)?.toDouble() ?? 0,  // score → value
  );

  static String _formatDate(String date) {
    // "2026-02-20" → "2/20"
    if (date.length < 10) return date;
    final month = int.tryParse(date.substring(5, 7)) ?? 0;
    final day = int.tryParse(date.substring(8, 10)) ?? 0;
    return '$month/$day';
  }
}

/// 优先训练模型（字段名适配）
class PriorityModel {
  final String modelId;
  final String modelName;
  final int level;
  final String description;

  const PriorityModel({
    required this.modelId,
    required this.modelName,
    required this.level,
    required this.description,
  });

  factory PriorityModel.fromJson(Map<String, dynamic> json) => PriorityModel(
    modelId: json['model_id'] ?? '',
    modelName: json['model_name'] ?? '',
    level: json['current_level'] ?? 0,           // current_level → level
    description: '错题 ${json['error_count'] ?? 0} 道',  // error_count → description
  );
}
```

### 4.3 Widget 改造清单

#### 4.3.1 TopFrameWidget — 无需改动

纯 UI 组件，无数据依赖。

#### 4.3.2 ScoreCardWidget — 微调

```dart
// 当前：prediction.when(data: (d) => _buildCard(d.predictedScore.round(), d.targetScore.round()))
// 改造：无需改动 Widget 本身
// 原因：targetScore 由后端新增字段提供，fromJson 已适配
```

#### 4.3.3 TrendCardWidget — 适配日期格式

```dart
// 当前：mock 数据使用 W1/W2/W3 格式
// 改造后：后端返回日期，fromJson 转换为 "2/20" 格式
// Widget 本身无需改动，TrendPoint.fromJson 已处理格式转换
// 注意：移除 _mockPoints 静态常量，改用空列表 fallback
```

#### 4.3.4 ScorePathTableWidget — 完全重写

这是改动最大的 Widget。当前表头为"题号/可提分/关联模型/优先级"，需改为"能力维度/当前/目标/差距"。

```dart
// 改造后的 ScorePathTableWidget
class ScorePathTableWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(predictionProvider);
    final items = prediction.whenOrNull(
      data: (d) => d.scorePath.isNotEmpty ? d.scorePath : null,
    ) ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('提分路径', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(children: [
              _header(),
              for (var i = 0; i < items.length; i++)
                _row(items[i], i < items.length - 1),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    // 改造：题号/可提分/关联模型/优先级 → 能力维度/当前/目标/差距
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      child: const Row(children: [
        Expanded(flex: 3, child: Text('能力维度')),
        Expanded(flex: 2, child: Text('当前')),
        Expanded(flex: 2, child: Text('目标')),
        Expanded(flex: 2, child: Text('差距')),
      ]),
    );
  }

  Widget _row(ScorePathRow item, bool hasBorder) {
    final gap = item.gap;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: hasBorder
          ? const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider, width: 0.5)))
          : null,
      child: Row(children: [
        Expanded(flex: 3, child: Text(item.label)),
        Expanded(flex: 2, child: Text('${item.current.toInt()}%', style: const TextStyle(color: AppTheme.primary))),
        Expanded(flex: 2, child: Text('${item.target.toInt()}%')),
        Expanded(flex: 2, child: Text(
          gap > 0 ? '-${gap.toInt()}' : '✅',
          style: TextStyle(color: gap > 0 ? AppTheme.danger : AppTheme.success),
        )),
      ]),
    );
  }
}
```

#### 4.3.5 PriorityModelListWidget — 微调

```dart
// 当前：使用 PriorityModel(modelId, modelName, level, description)
// 改造：无需改动 Widget 本身
// 原因：fromJson 已将 current_level→level, error_count→description 适配
// 注意：移除 _mockItems 静态常量，改用空列表 fallback
```

---

## 五、改造后页面结构

```
PredictionCenterPage（改造后）
├── TopFrameWidget              — 标题栏（无变化）
├── ScoreCardWidget             — 预测得分卡（predictedScore / targetScore）
├── TrendCardWidget             — 趋势折线图（日期格式：2/20）
├── ScorePathTableWidget [重写] — 提分路径（能力维度/当前/目标/差距）
└── PriorityModelListWidget     — 优先训练模型（level + "错题 N 道"）
```

---

## 六、实施阶段规划

### Phase 1：后端扩展（小改动）

| 步骤 | 内容 | 产出文件 |
|------|------|---------|
| 1.1 | `PredictionResponse` 新增 `target_score` 字段 | `app/schemas/prediction.py` |
| 1.2 | `prediction_service.py` 返回 `target_score` | `app/services/prediction_service.py` |

验收标准：`curl GET /api/prediction/score` 返回含 `target_score` 的完整数据

### Phase 2：前端数据层改造

| 步骤 | 内容 | 产出文件 |
|------|------|---------|
| 2.1 | 重写 `PredictionScore` + 子模型 fromJson | `providers/prediction_provider.dart` |
| 2.2 | 删除 `ScorePathItem`，新增 `ScorePathRow` | `providers/prediction_provider.dart` |
| 2.3 | `TrendPoint.fromJson` 适配 date→label | `providers/prediction_provider.dart` |
| 2.4 | `PriorityModel.fromJson` 适配 current_level→level | `providers/prediction_provider.dart` |

验收标准：Provider 正确解析后端响应，所有字段有值

### Phase 3：前端 Widget 改造

| 步骤 | 内容 | 产出文件 |
|------|------|---------|
| 3.1 | ScorePathTableWidget 完全重写（四维能力表） | `widgets/score_path_table_widget.dart` |
| 3.2 | TrendCardWidget 移除 _mockPoints | `widgets/trend_card_widget.dart` |
| 3.3 | PriorityModelListWidget 移除 _mockItems | `widgets/priority_model_list_widget.dart` |

验收标准：Flutter App 中预测中心页面正确展示所有后端数据，无 mock 数据残留

---

## 七、数据流总览

```
┌─────────────┐   GET /prediction/score   ┌──────────────────┐
│  Flutter App │ ──────────────────────→   │  FastAPI Router   │
│              │                           │  /prediction      │
│  prediction  │   JSON Response           │                   │
│  Provider    │ ←──────────────────────   │                   │
│              │                           └────────┬──────────┘
│  fromJson()  │                                    │
│  适配层：     │                           ┌────────▼──────────┐
│  date→label  │                           │ prediction_       │
│  current_    │                           │ service.py         │
│  level→level │                           │                   │
│  error_count │                           │ 读取 predicted_   │
│  →description│                           │ score             │
│              │                           │ 聚合 30 天趋势    │
│  5 Widgets   │                           │ Top 5 薄弱模型    │
│  渲染数据     │                           │ 四维能力路径      │
└─────────────┘                           └────────┬──────────┘
                                                   │
                                          ┌────────▼──────────┐
                                          │   PostgreSQL       │
                                          │   students         │
                                          │   questions        │
                                          │   student_mastery  │
                                          └───────────────────┘
```
