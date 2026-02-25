# model-detail（模型详情）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/model-detail`

## 组件树
```
ModelDetailPage (Scaffold)
├── TopFrameWidget                        ← 返回按钮 + 模型名称
└── Expanded
    ├── ClayBackgroundBlobs
    └── ListView
        ├── MasteryDashboardWidget        ← 掌握度漏斗 + 预测 + 训练按钮
        ├── PrerequisiteKnowledgeListWidget ← 前置知识点列表
        ├── RelatedQuestionListWidget      ← 相关题目列表
        └── TrainingRecordListWidget       ← 训练记录列表
```

## 页面截图
![model-detail-390x844](../flutter截图验证/model-detail/full/model-detail__390x844__full.png)

---

## 组件详情

### TopFrameWidget
![top_frame_widget](../flutter截图验证/model-detail/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮和模型名称
- 对应 dart 文件: `lib/features/model_detail/widgets/top_frame_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题: `'受力分析'`
- 对应数据模型: `ModelDetail`（来自 `lib/shared/models/model_detail_models.dart`）
- 需要的 API 字段:
  - `name` (String) — 模型名称

---

### MasteryDashboardWidget
![mastery_dashboard_widget](../flutter截图验证/model-detail/components/mastery_dashboard_widget__390x844.png)
- 功能说明: 掌握度仪表盘，展示当前等级、等级描述、四层漏斗图（建模层/列式层/执行层/稳定层）、预测提分、"开始训练"按钮
- 对应 dart 文件: `lib/features/model_detail/widgets/mastery_dashboard_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，带默认值）
- 硬编码值:
  - level: `'L1'`
  - levelLabel: `'建模卡住'`
  - levelDesc: `'看到题不确定该用什么方法'`
  - predictedGain: `'+5 分'`
  - relatedQuestion: `'关联大题第1题 (12分)'`
  - buttonLabel: `'开始训练 · 从 Step 1 开始'`
  - funnelLayers:
    - `('建模层 · 卡住', 'L1', 1.0, stuck: true)`
    - `('列式层 · 未到达', 'L2', 0.85, stuck: false)`
    - `('执行层 · 未到达', 'L3', 0.7, stuck: false)`
    - `('稳定层 · 未到达', 'L4-5', 0.55, stuck: false)`
- 对应数据模型: `ModelDetail` + `FunnelLayer`（来自 `lib/shared/models/model_detail_models.dart`）
- 需要的 API 字段:
  - `level` (String) — 当前等级
  - `levelLabel` (String) — 等级标签
  - `levelDescription` (String) — 等级描述
  - `predictedGain` (int) — 预测提分
  - `funnelLayers` (List<FunnelLayer>) — 漏斗层数据

---

### PrerequisiteKnowledgeListWidget
![prerequisite_knowledge_list_widget](../flutter截图验证/model-detail/components/prerequisite_knowledge_list_widget__390x844.png)
- 功能说明: 前置知识点列表，每项显示知识点名称、等级状态、颜色图标，底部有学习建议提示卡片，点击跳转知识点详情
- 对应 dart 文件: `lib/features/model_detail/widgets/prerequisite_knowledge_list_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - `('牛顿第二定律', 'L3 · 使用出错', Color(0xFFFF9500))`
  - `('摩擦力分析', 'L2 · 理解不深', AppTheme.danger)`
  - 建议提示: `'建议先学习 "摩擦力分析" (当前L2), 掌握后训练效果更好'`
- 对应数据模型: `PrerequisiteKnowledge`（来自 `lib/shared/models/shared_detail_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 知识点ID
  - `name` (String) — 知识点名称
  - `level` (String) — 掌握等级
  - `status` (String) — 状态（mastered/learning/weak）

---

### RelatedQuestionListWidget
![related_question_list_widget](../flutter截图验证/model-detail/components/related_question_list_widget__390x844.png)
- 功能说明: 相关题目列表，每项显示对错图标、考试来源、日期及诊断状态，点击跳转题目详情
- 对应 dart 文件: `lib/features/model_detail/widgets/related_question_list_widget.dart`
- 当前数据状态: 硬编码 mock（静态 `_items` 列表）
- 硬编码值:
  - `(correct: false, exam: '2025天津模拟 第5题', desc: '2月8日 · 错误 · 待诊断')`
  - `(correct: false, exam: '2024天津真题 大题1', desc: '2月3日 · 错误 · 已诊断: 识别错')`
  - `(correct: true, exam: '2024天津真题 第4题', desc: '2月3日 · 正确')`
- 对应数据模型: `RelatedQuestion`（来自 `lib/shared/models/shared_detail_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 题目ID
  - `title` (String) — 题目标题
  - `source` (String) — 来源考试
  - `isCorrect` (bool) — 是否正确

---

### TrainingRecordListWidget
![training_record_list_widget](../flutter截图验证/model-detail/components/training_record_list_widget__390x844.png)
- 功能说明: 训练记录列表，每项显示训练步骤名称、日期、通过/未通过状态
- 对应 dart 文件: `lib/features/model_detail/widgets/training_record_list_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，带默认值）
- 硬编码值:
  - `TrainingRecord(title: 'Step 1 训练', detail: '2月5日 · 未通过 · 识别失败', passed: false)`
- 对应数据模型: `TrainingRecord`（来自 `lib/shared/models/shared_detail_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 记录ID
  - `date` (String) — 训练日期
  - `result` (String) — 训练结果
  - `duration` (String) — 训练时长

---

## 数据模型

```dart
// lib/shared/models/model_detail_models.dart

class ModelDetail {
  final String id;
  final String name;
  final String level;
  final String levelLabel;
  final String levelDescription;
  final int predictedGain;
  final List<FunnelLayer> funnelLayers;
}

class FunnelLayer {
  final String label;
  final String level;
  final double widthFraction;
  final bool stuck;
}
```

```dart
// lib/shared/models/shared_detail_models.dart

class TrainingRecord {
  final String id;
  final String date;
  final String result;
  final String duration;
}

class PrerequisiteKnowledge {
  final String id;
  final String name;
  final String level;
  final String status; // 'mastered', 'learning', 'weak'
}

class RelatedQuestion {
  final String id;
  final String title;
  final String source;
  final bool isCorrect;
}
```

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/model/{id}/detail` | GET | 获取模型详情（掌握度+漏斗） | `ModelDetail` |
| `/api/model/{id}/prerequisites` | GET | 获取前置知识点列表 | `List<PrerequisiteKnowledge>` |
| `/api/model/{id}/questions` | GET | 获取相关题目列表 | `List<RelatedQuestion>` |
| `/api/model/{id}/training-records` | GET | 获取训练记录列表 | `List<TrainingRecord>` |

## 接入示例

```dart
final response = await api.get('/api/model/$modelId/detail');
final detail = ModelDetail.fromJson(response.data);

MasteryDashboardWidget(
  level: detail.level,
  levelLabel: detail.levelLabel,
  levelDesc: detail.levelDescription,
  predictedGain: '+${detail.predictedGain} 分',
  funnelLayers: detail.funnelLayers.map((l) =>
    FunnelLayer(
      label: l.label,
      level: l.level,
      widthFrac: l.widthFraction,
      stuck: l.stuck,
    ),
  ).toList(),
);
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页）
- "开始训练"按钮 → `/model-training`
- 前置知识点项点击 → `/knowledge-detail`
- 相关题目项点击 → `/question-detail`
