# knowledge-learning（知识点学习）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/knowledge-learning`

## 组件树
```
KnowledgeLearningPage (Scaffold, StatefulWidget)
├── TopFrameWidget                    ← 返回按钮 + 标题
├── StepStageNavWidget                ← 5步导航条（圆形步骤指示器）
├── Step1ConceptPresentWidget         ← 当前步骤的概念卡片
├── Expanded
│   └── Stack
│       ├── ClayBackgroundBlobs       ← 背景装饰
│       └── ChatMessageList           ← 聊天消息列表
└── ChatInputBar                      ← 底部输入框
```

## 页面截图
![knowledge-learning-390x844](../flutter截图验证/knowledge-learning/full/knowledge-learning__390x844__full.png)

---

## 组件详情

### TopFrameWidget
![top_frame_widget](../flutter截图验证/knowledge-learning/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮和页面标题
- 对应 dart 文件: `lib/features/knowledge_learning/widgets/top_frame_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题文字: `'库仑定律 · 学习'`
- 对应数据模型: 无独立模型（标题由路由参数传入）
- 需要的 API 字段:
  - `knowledgeName` (String) — 知识点名称，用于拼接标题

---

### StepStageNavWidget
![step_stage_nav_widget](../flutter截图验证/knowledge-learning/components/step_stage_nav_widget__390x844.png)
- 功能说明: 5 步学习阶段导航条，圆形步骤指示器 + 连接线 + 底部标签，支持点击切换步骤
- 对应 dart 文件: `lib/features/knowledge_learning/widgets/step_stage_nav_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 步骤标签: `['概念\n呈现', '理解\n检查', '辨析\n训练', '实际\n应用', '概念\n检测']`
- 对应数据模型: 无独立模型（步骤由页面 State 管理）
- 需要的 API 字段:
  - `currentStep` (int) — 当前学习进度步骤索引
  - `totalSteps` (int) — 总步骤数
  - `stepLabels` (List&lt;String&gt;) — 各步骤名称

---

### Step1ConceptPresentWidget
![step1_concept_present_widget](../flutter截图验证/knowledge-learning/components/step1_concept_present_widget__390x844.png)
- 功能说明: 当前步骤的概念卡片，显示步骤编号、标题和描述文字。根据 stepIndex 切换 5 个步骤的内容
- 对应 dart 文件: `lib/features/knowledge_learning/widgets/step1_concept_present_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 步骤标题: `['概念呈现', '理解检查', '辨析训练', '实际应用', '概念检测']`
  - 步骤大标题: `['库仑定律的核心内容', '你真的理解库仑定律了吗?', '库仑定律 vs 万有引力定律', '用库仑定律解决实际问题', '概念综合检测']`
  - 步骤描述: `['真空中两个静止点电荷之间的相互作用力...', '通过几个关键问题...', '两个公式形式相似...', '将库仑定律应用到具体的物理情境中...', '综合检测你对库仑定律概念...']`
- 对应数据模型: `ChatMessage`（来自 `lib/shared/models/chat_message.dart`）
- 需要的 API 字段:
  - `stepTitle` (String) — 步骤标题
  - `headline` (String) — 步骤大标题
  - `description` (String) — 步骤描述内容

> **备注**: Step2~Step5 组件（`step2_understanding_check_widget.dart`、`step3_discrimination_training_widget.dart`、`step4_practical_application_widget.dart`、`step5_concept_test_widget.dart`）当前均为 `Placeholder` 占位组件，尚未实现具体 UI。后续接入 API 后将根据各步骤类型渲染不同的交互内容。

---

## 数据模型

```dart
// lib/shared/models/chat_message.dart

enum MessageRole { user, ai, system }

enum MessageContentType {
  text,
  questionRef,
  conclusion,
  optionChips,
  table,
  stepSummary,
  loading,
}

class ChatMessage {
  final String id;
  final MessageRole role;
  final MessageContentType type;
  final String? text;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  // 工厂方法: ChatMessage.text(), ChatMessage.loading(), ChatMessage.rich()
}
```

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/knowledge/{id}/learning-session` | GET | 获取知识点学习会话初始数据（步骤信息、初始消息） | `{ steps: [...], messages: ChatMessage[] }` |
| `/api/knowledge/{id}/chat` | POST | 发送用户消息，获取 AI 回复 | `ChatMessage` |
| `/api/knowledge/{id}/step/{stepIndex}` | GET | 获取指定步骤的内容（标题、描述、交互类型） | `{ title, headline, description }` |

## 接入示例

```dart
// 1. 初始化学习会话
final session = await api.getLearningSession(knowledgeId);
setState(() {
  _messages.addAll(session.messages);
});

// 2. 发送消息并获取 AI 回复
void _onSend(String text) async {
  setState(() {
    _messages.add(ChatMessage.text(role: MessageRole.user, text: text));
    _messages.add(ChatMessage.loading());
  });

  final reply = await api.sendChat(knowledgeId, text, stepIndex: _currentStep);

  setState(() {
    _messages.removeWhere((m) => m.type == MessageContentType.loading);
    _messages.add(reply);
  });
}
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页，通常是 `/knowledge-detail`）
