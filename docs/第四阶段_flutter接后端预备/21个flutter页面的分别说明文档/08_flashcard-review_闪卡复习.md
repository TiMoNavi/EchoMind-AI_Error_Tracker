# flashcard-review（闪卡复习）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/flashcard-review`

## 组件树
```
FlashcardReviewPage (Scaffold)
├── ClayBackgroundBlobs
├── TopFrameWidget          ← 返回按钮 + 标题 + 进度
└── FlashcardWidget         ← 闪卡主体（翻转/滑动/反馈）
    ├── 卡片区域 (GestureDetector + AnimatedContainer)
    │   ├── _frontContent   ← 正面：问题
    │   └── _backContent    ← 背面：答案
    ├── 提示文字
    ├── 反馈按钮行 (忘了 / 记得 / 简单)
    └── _analysisSection    ← 翻转后显示解析 (ClayCard)
```

## 页面截图
![flashcard-review-390x844](../flutter截图验证/flashcard-review/full/flashcard-review__390x844__full.png)

---

## 组件详情

### TopFrameWidget
![top_frame_widget](../flutter截图验证/flashcard-review/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮、页面标题"闪卡复习"、当前进度显示
- 对应 dart 文件: `lib/features/flashcard_review/widgets/top_frame_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题: `'闪卡复习'`
  - 进度: `'3 / 12'`
- 对应数据模型: `FlashcardSession`（来自 `lib/shared/models/flashcard_models.dart`）
- 需要的 API 字段:
  - `currentIndex` (int) — 当前卡片索引
  - `cards.length` (int) — 总卡片数量

---

### FlashcardWidget
![flashcard_widget](../flutter截图验证/flashcard-review/components/flashcard_widget__390x844.png)
- 功能说明: 闪卡主体组件，支持点击翻转（正面问题/背面答案）、左右滑动切换卡片、三个反馈按钮（忘了/记得/简单）、翻转后展示解析区域
- 对应 dart 文件: `lib/features/flashcard_review/widgets/flashcard_widget.dart`
- 当前数据状态: 硬编码 mock（widget 内部定义了本地 `Flashcard` 类）
- 硬编码值:
  - 卡片1: q=`'库仑定律的适用条件是什么？'`, a=`'库仑定律适用于真空中两个静止点电荷...'`, tag=`'概念卡'`
  - 卡片2: q=`'万有引力定律与库仑定律的核心区别？'`, tag=`'辨析卡'`
  - 卡片3: q=`'板块运动中如何判断相对滑动方向？'`, tag=`'决策卡'`
- 对应数据模型: `Flashcard`（来自 `lib/shared/models/flashcard_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 闪卡唯一标识
  - `question` (String) — 问题文本
  - `answer` (String) — 答案文本
  - `detail` (String?) — 详细解析
  - `tag` (String) — 卡片类型标签（概念卡/辨析卡/决策卡）
  - `difficulty` (String) — 难度等级
  - `reviewCount` (int) — 复习次数

---

## 数据模型

```dart
// lib/shared/models/flashcard_models.dart

class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String? detail;
  final String tag;
  final String difficulty;
  final int reviewCount;
}

class FlashcardSession {
  final List<Flashcard> cards;
  final int currentIndex;
  final int remembered;
  final int forgotten;
}
```

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/flashcard/session` | GET | 获取当前闪卡复习会话 | `FlashcardSession` |
| `/api/flashcard/{id}/feedback` | POST | 提交单张卡片反馈（忘了/记得/简单） | `void` |

## 接入示例

```dart
// 获取闪卡会话并注入到页面
final response = await api.get('/api/flashcard/session');
final session = FlashcardSession.fromJson(response.data);

// 将 model 层 Flashcard 映射为 widget 层参数
FlashcardWidget(
  cards: session.cards,
);

// 提交反馈
await api.post('/api/flashcard/${card.id}/feedback', data: {
  'result': 'remembered', // 'forgotten' | 'remembered' | 'easy'
});
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页）
