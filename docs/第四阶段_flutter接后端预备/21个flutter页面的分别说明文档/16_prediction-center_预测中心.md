# prediction-center（预测中心）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/prediction-center`

## 组件树
```
PredictionCenterPage (Scaffold)
├── TopFrameWidget                    ← 返回按钮 + 标题
└── Expanded
    └── Stack
        ├── ClayBackgroundBlobs       ← 背景装饰
        └── ListView
            ├── ScoreCardWidget       ← 预测分数环形图 + 目标
            ├── TrendCardWidget       ← 预测分数趋势折线图
            ├── ScorePathTableWidget  ← 提分路径表格
            └── PriorityModelListWidget ← 优先训练模型列表
```

## 页面截图
![prediction-center-390x844](../flutter截图验证/prediction-center/full/prediction-center__390x844__full.png)

---

## 组件详情

### TopFrameWidget
![top_frame_widget](../flutter截图验证/prediction-center/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮和页面标题"预测中心"
- 对应 dart 文件: `lib/features/prediction_center/widgets/top_frame_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题文字: `'预测中心'`
- 对应数据模型: 无独立模型
- 需要的 API 字段: 无（纯静态标题）

---

### ScoreCardWidget
![score_card_widget](../flutter截图验证/prediction-center/components/score_card_widget__390x844.png)
- 功能说明: 预测分数卡片，包含环形进度条、当前分数、目标分数和差距描述
- 对应 dart 文件: `lib/features/prediction_center/widgets/score_card_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，但有默认 mock 值）
- 硬编码值:
  - 当前分数: `63`
  - 总分: `100`
  - 目标分数: `70`
  - 差距描述: `'差距: 7分 -- 预计 2-3 周可达成'`
- 对应数据模型: `PredictionScore`（来自 `lib/shared/models/prediction_models.dart`）
- 需要的 API 字段:
  - `score` (int) — 当前预测分数
  - `totalScore` (int) — 总分
  - `targetScore` (int) — 目标分数
  - `gapDescription` (String) — 差距描述文字

---

### TrendCardWidget
![trend_card_widget](../flutter截图验证/prediction-center/components/trend_card_widget__390x844.png)
- 功能说明: 预测分数趋势折线图，使用 CustomPaint 绘制折线 + 圆点，底部显示日期标签
- 对应 dart 文件: `lib/features/prediction_center/widgets/trend_card_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，但有默认 mock 值）
- 硬编码值:
  - 数据点: `[55.0, 57.0, 59.0, 61.0, 60.0, 63.0]`
  - 日期标签: `['1月20日', '1月27日', '2月3日', '2月10日']`
- 对应数据模型: `PredictionScore`（来自 `lib/shared/models/prediction_models.dart`）
- 需要的 API 字段:
  - `trendData` (List&lt;double&gt;) — 趋势数据点列表
  - `trendChange` (String) — 趋势变化描述

---

### ScorePathTableWidget
![score_path_table_widget](../flutter截图验证/prediction-center/components/score_path_table_widget__390x844.png)
- 功能说明: 提分路径表格，按题号列出现状（MUST/TRY/SKIP 标签）、动作和预计提分。点击非 SKIP 行跳转到题目聚合页
- 对应 dart 文件: `lib/features/prediction_center/widgets/score_path_table_widget.dart`
- 当前数据状态: 已参数化（构造函数接收 rows 参数，但有默认 mock 值）
- 硬编码值:
  - 行数据: `[ScorePathRow('第5题','MUST','板块运动训练','+3'), ScorePathRow('第7题','MUST','电场综合训练','+3'), ScorePathRow('大题1','MUST','力学大题训练','+4'), ScorePathRow('大题2','TRY','前两问拿分','+2'), ScorePathRow('大题3','SKIP','暂不投入','--')]`
- 对应数据模型: `ScorePathEntry`（来自 `lib/shared/models/prediction_models.dart`）
- 需要的 API 字段:
  - `modelName` (String) — 题号/模型名称
  - `currentLevel` (String) — 当前等级
  - `targetLevel` (String) — 目标等级
  - `gainPoints` (int) — 预计提分

> **注意**: 组件内部定义了局部类 `ScorePathRow`（含 id/attitude/action/score 字段），与 `prediction_models.dart` 中的 `ScorePathEntry`（含 modelName/currentLevel/targetLevel/gainPoints 字段）结构不同，接入 API 时需要迁移对齐。

---

### PriorityModelListWidget
![priority_model_list_widget](../flutter截图验证/prediction-center/components/priority_model_list_widget__390x844.png)
- 功能说明: 优先训练模型列表，每项显示渐变排名圆标、模型名称和描述，点击跳转到模型详情页
- 对应 dart 文件: `lib/features/prediction_center/widgets/priority_model_list_widget.dart`
- 当前数据状态: 已参数化（构造函数接收 models 参数，但有默认 mock 值）
- 硬编码值:
  - 模型1: `PriorityModel(name: '板块运动', desc: '当前L1 -- 解决后预计 +5 分')`
  - 模型2: `PriorityModel(name: '库仑力平衡', desc: '当前L2 -- 解决后预计 +3 分')`
  - 模型3: `PriorityModel(name: '牛顿第二定律应用', desc: '当前L3 -- 不稳定 -- 稳定后预计 +2 分')`
- 对应数据模型: `PriorityModelItem`（来自 `lib/shared/models/prediction_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 模型唯一标识
  - `name` (String) — 模型名称
  - `description` (String) — 模型描述
  - `level` (String) — 当前等级
  - `predictedGain` (int) — 预计提分

> **注意**: 组件内部定义了旧的局部类 `PriorityModel`（含 name/desc/rankColor），需要迁移到 `prediction_models.dart` 中的 `PriorityModelItem`（含 id/name/description/level/predictedGain）。

---

## 数据模型

```dart
// lib/shared/models/prediction_models.dart

class PredictionScore {
  final int score;
  final int totalScore;
  final int targetScore;
  final String gapDescription;
  final List<double> trendData;
  final String trendChange;
}

class PriorityModelItem {
  final String id;
  final String name;
  final String description;
  final String level;
  final int predictedGain;
}

class ScorePathEntry {
  final String modelName;
  final String currentLevel;
  final String targetLevel;
  final int gainPoints;
}
```

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/prediction/score` | GET | 获取预测分数及趋势数据 | `PredictionScore` |
| `/api/prediction/score-path` | GET | 获取提分路径列表 | `List<ScorePathEntry>` |
| `/api/prediction/priority-models` | GET | 获取优先训练模型排序列表 | `List<PriorityModelItem>` |

## 接入示例

```dart
// 1. 获取预测分数
final predictionScore = await api.getPredictionScore();
// 注入到 ScoreCardWidget
ScoreCardWidget(
  score: predictionScore.score,
  totalScore: predictionScore.totalScore,
  targetScore: predictionScore.targetScore,
  gapDescription: predictionScore.gapDescription,
);

// 2. 注入趋势数据
TrendCardWidget(
  points: predictionScore.trendData,
  dateLabels: predictionScore.dateLabels,
);

// 3. 获取优先训练模型
final models = await api.getPriorityModels();
PriorityModelListWidget(models: models);
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页）
- ScorePathTableWidget 行点击（非 SKIP） → `/question-aggregate`
- PriorityModelListWidget 项点击 → `/model-detail`
