# model-training（模型训练）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/model-training`

## 组件树
```
ModelTrainingPage (Scaffold, StatefulWidget)
├── TopFrameWidget                        ← 返回按钮 + 模型名称 + "训练"
├── StepStageNavWidget                    ← 6步导航条（圆点+连线+标签）
├── Step1IdentificationTrainingWidget     ← 当前步骤卡片（标题+描述）
├── Expanded
│   ├── ClayBackgroundBlobs
│   └── ChatMessageList                   ← 共享聊天消息列表
└── ChatInputBar                          ← 共享聊天输入栏
```

备注：6步训练流程为 识别训练 → 决策训练 → 列式训练 → 陷阱辨析 → 完整求解 → 变式训练。
Step2~Step6 目前为 Placeholder widget，共用 Step1IdentificationTrainingWidget 的内容切换。

## 页面截图
![model-training-390x844](../flutter截图验证/model-training/full/model-training__390x844__full.png)

---

## 组件详情

### TopFrameWidget
![top_frame_widget](../flutter截图验证/model-training/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮和模型训练标题
- 对应 dart 文件: `lib/features/model_training/widgets/top_frame_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题: `'板块运动 · 训练'`
- 对应数据模型: `ChatMessage`（来自 `lib/shared/models/chat_message.dart`）
- 需要的 API 字段:
  - 模型名称（从上游页面传入）

---

### StepStageNavWidget
![step_stage_nav_widget](../flutter截图验证/model-training/components/step_stage_nav_widget__390x844.png)
- 功能说明: 6步训练导航条，显示圆点编号+连线+文字标签，支持点击切换步骤，当前步骤高亮
- 对应 dart 文件: `lib/features/model_training/widgets/step_stage_nav_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标签: `['识别\n训练', '决策\n训练', '列式\n训练', '陷阱\n辨析', '完整\n求解', '变式\n训练']`
- 对应数据模型: 无独立模型（纯导航 UI）
- 需要的 API 字段:
  - 当前步骤索引（由页面状态管理）
  - 各步骤完成状态（可选，用于标记已完成步骤）

---

### Step1IdentificationTrainingWidget
![step1_identification_training_widget](../flutter截图验证/model-training/components/step1_identification_training_widget__390x844.png)
- 功能说明: 当前步骤信息卡片，根据 stepIndex 显示对应步骤的编号、标题和描述文字
- 对应 dart 文件: `lib/features/model_training/widgets/step1_identification_training_widget.dart`
- 当前数据状态: 硬编码 mock（静态列表）
- 硬编码值:
  - 标题列表: `['识别训练', '决策训练', '列式训练', '陷阱辨析', '完整求解', '变式训练']`
  - 大标题列表:
    - `'这道题属于什么模型?'`
    - `'识别了板块运动, 接下来怎么分析?'`
    - `'如何列出正确的方程组?'`
    - `'这类题常见的陷阱有哪些?'`
    - `'从头到尾完整求解一遍'`
    - `'换个条件, 你还会做吗?'`
  - 描述列表:
    - `'观察题目中的关键信息, 判断这道题属于哪种物理模型。'`
    - `'你已经知道这是一道板块运动题。现在需要决定...'`
    - `'根据受力分析和运动状态, 列出完整的方程组...'`
    - `'板块运动题中有几个经典陷阱...'`
    - `'综合前面所有步骤, 独立完成一道完整的板块运动题。'`
    - `'改变题目中的某些条件, 看看你能否灵活应对变化。'`
- 对应数据模型: `ChatMessage`（来自 `lib/shared/models/chat_message.dart`）
- 需要的 API 字段:
  - 步骤标题和描述（可由后端动态下发，也可前端静态）

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
}
```

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/training/{modelId}/start` | POST | 开始训练会话 | `List<ChatMessage>` |
| `/api/training/{sessionId}/send` | POST | 发送用户回答，获取 AI 回复 | `ChatMessage` |
| `/api/training/{sessionId}/step` | POST | 切换训练步骤 | `List<ChatMessage>` |

## 接入示例

```dart
// 开始训练会话
final response = await api.post(
  '/api/training/$modelId/start',
);
final initialMessages = (response.data as List)
    .map((e) => ChatMessage.fromJson(e))
    .toList();
setState(() => _messages.addAll(initialMessages));
```

```dart
// 发送用户回答
final reply = await api.post(
  '/api/training/$sessionId/send',
  data: {'text': userInput, 'step': _currentStep},
);
final aiMessage = ChatMessage.fromJson(reply.data);
setState(() {
  _messages.removeWhere((m) => m.type == MessageContentType.loading);
  _messages.add(aiMessage);
});
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页）
