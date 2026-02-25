# question-detail（题目详情）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/question-detail`

## 组件树
```
QuestionDetailPage (Scaffold)
├── TopFrameWidget                ← 返回按钮 + 标题
└── Expanded
    ├── ClayBackgroundBlobs
    └── ListView
        ├── QuestionContentWidget     ← 题目内容卡片
        ├── AnswerResultWidget        ← 作答结果 + 诊断入口
        ├── QuestionRelationsWidget   ← 归属模型 + 关联知识点
        └── QuestionSourceWidget      ← 来源卷子/题号/满分/态度
```

## 页面截图
![question-detail-390x844](../flutter截图验证/question-detail/full/question-detail__390x844__full.png)

---

## 组件详情

### TopFrameWidget
![top_frame_widget](../flutter截图验证/question-detail/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮和页面标题"题目详情"
- 对应 dart 文件: `lib/features/question_detail/widgets/top_frame_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题: `'题目详情'`
- 对应数据模型: `QuestionDetail`（来自 `lib/shared/models/question_detail_models.dart`）
- 需要的 API 字段:
  - `title` (String) — 题目标题

---

### QuestionContentWidget
![question_content_widget](../flutter截图验证/question-detail/components/question_content_widget__390x844.png)
- 功能说明: 题目内容卡片，展示来源考试名称和完整题目文本
- 对应 dart 文件: `lib/features/question_detail/widgets/question_content_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 来源: `'2025天津模拟(一) 第5题'`
  - 题目: `'如图所示, 质量为M的长木板置于光滑水平面上...'`
  - 小问: `'(1) 物块和木板最终速度;\n(2) 物块在木板上滑行的距离。'`
- 对应数据模型: `QuestionDetail`（来自 `lib/shared/models/question_detail_models.dart`）
- 需要的 API 字段:
  - `content` (String) — 题目正文
  - `sourceExam` (String) — 来源考试
  - `images` (List<String>) — 题目图片URL列表

---

### AnswerResultWidget
![answer_result_widget](../flutter截图验证/question-detail/components/answer_result_widget__390x844.png)
- 功能说明: 作答结果卡片，展示对错状态、上传日期、诊断状态标签，以及"进入诊断"按钮
- 对应 dart 文件: `lib/features/question_detail/widgets/answer_result_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，带默认值）
- 硬编码值:
  - 状态: `'错误'`
  - 上传日期: `'2月8日上传'`
  - 状态标签: `'待诊断'`
  - isPending: `true`
  - 诊断提示: `'AI将通过对话定位你的错误在哪一层'`
- 对应数据模型: `QuestionDetail`（来自 `lib/shared/models/question_detail_models.dart`）
- 需要的 API 字段:
  - `isCorrect` (bool) — 是否正确
  - `diagnosisStatus` (String?) — 诊断状态（correct/wrong/pending）
  - `userAnswer` (String) — 用户作答
  - `correctAnswer` (String) — 正确答案

---

### QuestionRelationsWidget
![question_relations_widget](../flutter截图验证/question-detail/components/question_relations_widget__390x844.png)
- 功能说明: 展示题目归属模型（蓝色标签）和关联知识点（灰色标签），点击可跳转对应详情页
- 对应 dart 文件: `lib/features/question_detail/widgets/question_relations_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 归属模型: `['板块运动']`
  - 关联知识点: `['牛顿第二定律', '摩擦力', '动量守恒']`
- 对应数据模型: `QuestionRelation`（来自 `lib/shared/models/question_detail_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 关联项ID
  - `name` (String) — 关联项名称
  - `type` (String) — 类型（'model' 或 'knowledge'）
  - `level` (String) — 掌握等级

---

### QuestionSourceWidget
![question_source_widget](../flutter截图验证/question-detail/components/question_source_widget__390x844.png)
- 功能说明: 题目来源信息卡片，展示来源卷子、题号、满分、态度标签
- 对应 dart 文件: `lib/features/question_detail/widgets/question_source_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，带默认值）
- 硬编码值:
  - 来源卷子: `'2025天津模拟(一)'`
  - 题号: `'选择题 第5题'`
  - 满分: `'3 分'`
  - 态度: `'MUST'`
- 对应数据模型: `QuestionDetail`（来自 `lib/shared/models/question_detail_models.dart`）
- 需要的 API 字段:
  - `sourceExam` (String) — 来源卷子
  - `difficulty` (String) — 难度/态度标签

---

## 数据模型

```dart
// lib/shared/models/question_detail_models.dart

class QuestionDetail {
  final String id;
  final String title;
  final String content;
  final List<String> images;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? diagnosisStatus;
  final String sourceExam;
  final String difficulty;
}
```

```dart
class QuestionRelation {
  final String id;
  final String name;
  final String type; // 'model' or 'knowledge'
  final String level;
}
```

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/question/{id}/detail` | GET | 获取题目详情 | `QuestionDetail` |
| `/api/question/{id}/relations` | GET | 获取题目关联的模型和知识点 | `List<QuestionRelation>` |

## 接入示例

```dart
final response = await api.get('/api/question/$questionId/detail');
final detail = QuestionDetail.fromJson(response.data);

final relResponse = await api.get('/api/question/$questionId/relations');
final relations = (relResponse.data as List)
    .map((e) => QuestionRelation.fromJson(e))
    .toList();

// 注入到组件
AnswerResultWidget(
  status: detail.isCorrect ? '正确' : '错误',
  statusTag: detail.diagnosisStatus ?? '待诊断',
);

QuestionSourceWidget(
  source: detail.sourceExam,
  fullScore: '3 分',
  attitude: 'MUST',
);
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页）
- "进入诊断"按钮 → `/ai-diagnosis`
- 归属模型标签点击 → `/model-detail`
- 关联知识点标签点击 → `/knowledge-detail`
