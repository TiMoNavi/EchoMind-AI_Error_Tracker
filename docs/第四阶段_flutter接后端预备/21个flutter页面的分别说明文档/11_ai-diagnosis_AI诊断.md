# ai-diagnosis（AI诊断）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/ai-diagnosis`

## 组件树
```
AiDiagnosisPage (Scaffold, StatefulWidget)
├── TopFrameWidget              ← 返回按钮 + 标题"AI 诊断"
├── Expanded
│   ├── ClayBackgroundBlobs
│   └── ChatMessageList         ← 共享聊天消息列表
│       ├── questionRef 卡片    ← 系统消息：题目引用
│       ├── AI 文本气泡          ← 诊断分析内容
│       ├── 用户文本气泡
│       └── loading 指示器
└── ChatInputBar                ← 共享聊天输入栏
```

## 页面截图
![ai-diagnosis-390x844](../flutter截图验证/ai-diagnosis/full/ai-diagnosis__390x844__full.png)

---

## 组件详情

### TopFrameWidget
![top_frame_widget](../flutter截图验证/ai-diagnosis/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮和页面标题"AI 诊断"
- 对应 dart 文件: `lib/features/ai_diagnosis/widgets/top_frame_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题: `'AI 诊断'`
- 对应数据模型: 无独立模型（静态标题）
- 需要的 API 字段: 无

---

### ChatMessageList（共享组件）
![chat_message_list](../flutter截图验证/ai-diagnosis/components/chat_message_list__390x844.png)
- 功能说明: 共享聊天消息列表组件，渲染不同类型的消息气泡（文本/题目引用/结论卡/选项chips/loading）
- 对应 dart 文件: `lib/shared/widgets/chat/chat_message_list.dart`
- 当前数据状态: 硬编码 mock（页面 initState 中构造初始消息）
- 硬编码值:
  - 系统消息 metadata: `{'title': '第5题 — 等量异种点电荷电场分析'}`
  - AI 初始回复: `'根据你的作答记录，这道题你选了B，正确答案是ACD...'`
  - 模拟 AI 回复: `'这是一个模拟的 AI 回复。实际接入 API 后...'`
- 对应数据模型: `ChatMessage`（来自 `lib/shared/models/chat_message.dart`）
- 需要的 API 字段:
  - `id` (String) — 消息唯一标识
  - `role` (MessageRole) — 消息角色（user/ai/system）
  - `type` (MessageContentType) — 内容类型
  - `text` (String?) — 文本内容
  - `metadata` (Map?) — 富内容元数据

---

### ChatInputBar（共享组件）
- 功能说明: 共享聊天输入栏，底部文本输入框 + 发送按钮
- 对应 dart 文件: `lib/shared/widgets/chat/chat_input_bar.dart`
- 当前数据状态: 已参数化
- 硬编码值:
  - hintText: `'输入你的问题...'`
- 对应数据模型: 无（纯 UI 输入组件）
- 需要的 API 字段: 无（输出用户输入文本）

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
```

```dart
class ChatMessage {
  final String id;
  final MessageRole role;
  final MessageContentType type;
  final String? text;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
}
```

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/diagnosis/{questionId}/start` | POST | 开始诊断会话，获取初始消息 | `List<ChatMessage>` |
| `/api/diagnosis/{sessionId}/send` | POST | 发送用户消息，获取 AI 回复 | `ChatMessage` |

## 接入示例

```dart
// 开始诊断会话
final startResponse = await api.post(
  '/api/diagnosis/$questionId/start',
);
final initialMessages = (startResponse.data as List)
    .map((e) => ChatMessage.fromJson(e))
    .toList();

// 发送用户消息
final reply = await api.post(
  '/api/diagnosis/$sessionId/send',
  data: {'text': userInput},
);
final aiMessage = ChatMessage.fromJson(reply.data);
setState(() => _messages.add(aiMessage));
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页）
- 结论卡片 action → `/model-training`
