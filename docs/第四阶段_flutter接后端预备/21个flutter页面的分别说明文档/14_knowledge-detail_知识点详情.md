# knowledge-detail（知识点详情）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/knowledge-detail`

## 组件树
```
KnowledgeDetailPage (Scaffold)
├── TopFrameWidget                  ← 返回按钮 + 知识点名称
└── Expanded
    ├── ClayBackgroundBlobs
    └── ListView
        ├── MasteryDashboardWidget      ← 掌握度圆环 + 等级条 + 标签 + 学习按钮
        ├── ConceptTestRecordsWidget     ← 概念检测记录列表
        └── RelatedModelsWidget         ← 关联模型列表
```

## 页面截图
![knowledge-detail-390x844](../flutter截图验证/knowledge-detail/full/knowledge-detail__390x844__full.png)

---

## 组件详情

### TopFrameWidget
![top_frame_widget](../flutter截图验证/knowledge-detail/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮和知识点名称
- 对应 dart 文件: `lib/features/knowledge_detail/widgets/top_frame_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题: `'库仑定律公式'`
- 对应数据模型: `KnowledgeDetail`（来自 `lib/shared/models/knowledge_detail_models.dart`）
- 需要的 API 字段:
  - `name` (String) — 知识点名称

---

### MasteryDashboardWidget
![mastery_dashboard_widget](../flutter截图验证/knowledge-detail/components/mastery_dashboard_widget__390x844.png)
- 功能说明: 掌握度仪表盘，展示圆环等级指示器（L0~L5）、等级状态标签、历史最高等级、知识点标签、"开始学习"按钮
- 对应 dart 文件: `lib/features/knowledge_detail/widgets/mastery_dashboard_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，带默认值）
- 硬编码值:
  - activeLevel: `3`
  - levelStatusLabel: `'使用出错'`
  - previousLevelNote: `'曾到达: L4 (能正确使用)'`
  - tags: `['一级结论', '需理解']`
- 对应数据模型: `KnowledgeDetail`（来自 `lib/shared/models/knowledge_detail_models.dart`）
- 需要的 API 字段:
  - `level` (String) — 当前等级
  - `levelLabel` (String) — 等级标签
  - `levelDescription` (String) — 等级描述
  - `predictedGain` (int) — 预测提分
  - `tags` (List<String>) — 知识点标签

---

### ConceptTestRecordsWidget
![concept_test_records_widget](../flutter截图验证/knowledge-detail/components/concept_test_records_widget__390x844.png)
- 功能说明: 概念检测记录列表，每项显示检测名称、日期、通过/未通过状态及详情
- 对应 dart 文件: `lib/features/knowledge_detail/widgets/concept_test_records_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，带默认值）
- 硬编码值:
  - `ConceptTestRecord(name: '检测 #3', desc: '2月9日 · 未通过 · 条件判断错误', passed: false)`
  - `ConceptTestRecord(name: '检测 #2', desc: '2月5日 · 通过 · 全部正确', passed: true)`
  - `ConceptTestRecord(name: '检测 #1', desc: '1月28日 · 通过 · 2/3正确', passed: true)`
- 对应数据模型: `ConceptTestRecord`（来自 `lib/shared/models/knowledge_detail_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 检测记录ID
  - `date` (String) — 检测日期
  - `score` (String) — 得分
  - `status` (String) — 通过/未通过状态

---

### RelatedModelsWidget
![related_models_widget](../flutter截图验证/knowledge-detail/components/related_models_widget__390x844.png)
- 功能说明: 关联模型列表，展示使用此知识点的模型，每项显示模型名称、等级状态、颜色图标，点击跳转模型详情
- 对应 dart 文件: `lib/features/knowledge_detail/widgets/related_models_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - `('库仑力平衡', 'L2 · 列式卡住', Color(0xFFFF9500))`
  - `('电场中的功能关系', 'L0 · 未接触', Color(0xFFAEAEB2))`
- 对应数据模型: `RelatedModel`（来自 `lib/shared/models/knowledge_detail_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 模型ID
  - `name` (String) — 模型名称
  - `level` (String) — 掌握等级
  - `subtitle` (String) — 等级描述

---

## 数据模型

```dart
// lib/shared/models/knowledge_detail_models.dart

class KnowledgeDetail {
  final String id;
  final String name;
  final String level;
  final String levelLabel;
  final String levelDescription;
  final int predictedGain;
  final List<String> tags;
}

class ConceptTestRecord {
  final String id;
  final String date;
  final String score;
  final String status;
}

class RelatedModel {
  final String id;
  final String name;
  final String level;
  final String subtitle;
}
```

```dart
// lib/shared/models/shared_detail_models.dart (共享模型)

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
  final String status;
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
| `/api/knowledge/{id}/detail` | GET | 获取知识点详情 | `KnowledgeDetail` |
| `/api/knowledge/{id}/test-records` | GET | 获取概念检测记录 | `List<ConceptTestRecord>` |
| `/api/knowledge/{id}/related-models` | GET | 获取关联模型列表 | `List<RelatedModel>` |

## 接入示例

```dart
final response = await api.get('/api/knowledge/$knowledgeId/detail');
final detail = KnowledgeDetail.fromJson(response.data);

MasteryDashboardWidget(
  activeLevel: int.parse(detail.level.replaceAll('L', '')),
  levelStatusLabel: detail.levelLabel,
  tags: detail.tags,
);
```

```dart
// 获取概念检测记录
final testResponse = await api.get('/api/knowledge/$knowledgeId/test-records');
final records = (testResponse.data as List)
    .map((e) => ConceptTestRecord.fromJson(e))
    .toList();

// 获取关联模型
final modelResponse = await api.get('/api/knowledge/$knowledgeId/related-models');
final models = (modelResponse.data as List)
    .map((e) => RelatedModel.fromJson(e))
    .toList();
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页）
- "开始学习"按钮 → `/knowledge-learning`
- 关联模型项点击 → `/model-detail`
