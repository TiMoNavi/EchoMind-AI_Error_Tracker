# memory（记忆）

## 当前状态

第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识

`/memory`

## 组件树

```
MemoryPage (PageShell, tabIndex: 2)
├── ClayBackgroundBlobs — Claymorphism 浮动背景
├── TopFrameWidget — 页面标题「记忆」
├── ReviewDashboardWidget — 今日待复习大数字 + 开始复习按钮 + 统计行
└── CardCategoryListWidget — 卡片分类列表（8种卡片类型）
```

## 页面截图

![memory-390x844](../flutter截图验证/memory/full/memory__390x844__full.png)

---

## 组件详情

### top-frame

![top-frame](../flutter截图验证/memory/components/top-frame__390x844.png)

- 功能说明: 页面标题「记忆」，纯文本标题
- 对应 dart 文件: `lib/features/memory/widgets/top_frame_widget.dart`
- 当前数据状态: 已参数化（`title = '记忆'`）
- 硬编码值: `title: '记忆'`
- 对应数据模型: 无（纯展示组件）
- 需要的 API 字段: 无

---

### review-dashboard

![review-dashboard](../flutter截图验证/memory/components/review-dashboard__390x844.png)

- 功能说明: 今日待复习大数字卡片 + 「开始复习」渐变按钮 + 三列统计行（记住率/累计复习/总卡片数）
- 对应 dart 文件: `lib/features/memory/widgets/review_dashboard_widget.dart`
- 当前数据状态: 硬编码 mock（已参数化为构造函数参数）
- 硬编码值:
  - 今日待复习: `'12'`
  - 本周记住率: `'87%'`
  - 累计复习: `'156'`
  - 总卡片数: `'48'`
- 对应数据模型: `MemoryDashboard`（来自 `lib/shared/models/memory_models.dart`）
- 需要的 API 字段:
  - `today_due_count` (int) — 今日待复习数
  - `retention_rate` (String) — 本周记住率
  - `total_reviewed` (int) — 累计复习次数
  - `total_cards` (int) — 总卡片数

---

### card-category-list

![card-category-list](../flutter截图验证/memory/components/card-category-list__390x844.png)

- 功能说明: 卡片分类列表，每行显示彩色标签方块 + 分类名 + 描述 + 待复习数
- 对应 dart 文件: `lib/features/memory/widgets/card_category_list_widget.dart`
- 当前数据状态: 硬编码 mock（已参数化为构造函数参数）
- 硬编码值:
  - `识别卡 (tag:'识别', bg:#1C1C1E) — 8张 · 来自模型训练 Step1, 3张待复习`
  - `决策卡 (tag:'决策', bg:#48484A) — 6张 · 来自模型训练 Step2, 2张待复习`
  - `步骤卡 (tag:'步骤', bg:#8E8E93) — 5张 · 来自模型训练 Step3, 1张待复习`
  - `陷阱卡 (tag:'陷阱', bg:#3A3A3C) — 4张 · 来自模型训练 Step4, 0`
  - `公式卡 (tag:'公式', bg:#007AFF) — 10张 · 通用, 4张待复习`
  - `概念卡 (tag:'概念', bg:#BBDEFB) — 9张 · 来自知识点学习, 2张待复习`
  - `条件卡 (tag:'条件', bg:#E3F2FD) — 4张 · 来自知识点学习, 0`
  - `辨析卡 (tag:'辨析', bg:#F5F9FF) — 2张 · 来自易混对比, 0`
- 注意: widget 内部定义了本地 `CardCategory` 类（含 `tag/tagBg/tagFg/name/desc/review`），需迁移到 shared model
- 对应数据模型: `CardCategory`（来自 `lib/shared/models/memory_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 分类唯一标识
  - `name` (String) — 分类名称
  - `total_count` (int) — 总卡片数
  - `due_count` (int) — 待复习数
  - `color_hex` (String) — 标签颜色

---

## 数据模型

来自 `lib/shared/models/memory_models.dart`：

```dart
class MemoryDashboard {
  final int todayDueCount;
  final String retentionRate;
  final int totalReviewed;
  final int totalCards;
}

class CardCategory {
  final String id;
  final String name;
  final int totalCount;
  final int dueCount;
  final String colorHex;
}
```

## API 接口清单

| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/memory/dashboard` | GET | 获取记忆仪表盘数据 | `MemoryDashboard` |
| `/api/memory/categories` | GET | 获取卡片分类列表 | `List<CardCategory>` |

## 接入示例

```dart
// 获取记忆仪表盘
final dashResp = await api.get('/api/memory/dashboard');
final dashboard = MemoryDashboard.fromJson(dashResp.data);

ReviewDashboardWidget(
  todayCount: '${dashboard.todayDueCount}',
  retentionRate: dashboard.retentionRate,
  totalReviewed: '${dashboard.totalReviewed}',
  totalCards: '${dashboard.totalCards}',
);
```

## 页面跳转

- 「开始复习」按钮 → `/flashcard-review`
- 「管理」文字按钮 → 待实现（卡片分类管理）
