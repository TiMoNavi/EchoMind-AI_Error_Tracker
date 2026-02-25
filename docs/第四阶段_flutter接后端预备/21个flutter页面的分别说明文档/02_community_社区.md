# community（社区）

## 当前状态

第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识

`/community`

## 组件树

```
CommunityPage (PageShell, tabIndex: 3)
├── ClayBackgroundBlobs — Claymorphism 浮动背景
├── TopFrameAndTabsWidget — 页面标题「社区」+ Clay 凹陷 Tab 栏（我的需求/功能助推/反馈墙）
├── BoardMyRequestsWidget — Tab0: 提交新需求按钮 + 需求卡片列表
├── BoardFeatureBoostWidget — Tab1: 新功能投票占位卡
└── BoardFeedbackWidget — Tab2: 改版建议占位卡
```

## 页面截图

![community-390x844](../flutter截图验证/community/full/community__390x844__full.png)

---

## 组件详情

### top-frame-and-tabs

![top-frame-and-tabs](../flutter截图验证/community/components/top-frame-and-tabs__390x844.png)

- 功能说明: 页面标题「社区」+ Clay 凹陷容器 Tab 栏，三个 Tab（我的需求/功能助推/反馈墙）
- 对应 dart 文件: `lib/features/community/widgets/top_frame_and_tabs_widget.dart`
- 当前数据状态: Tab 标签已参数化（`_tabs = ['我的需求', '功能助推', '反馈墙']`）
- 硬编码值:
  - 标题: `'社区'`
  - Tab 列表: `['我的需求', '功能助推', '反馈墙']`
- 对应数据模型: 无（纯导航组件）
- 需要的 API 字段: 无

---

### board-my-requests

![board-my-requests](../flutter截图验证/community/components/board-my-requests__390x844.png)

- 功能说明: 「提交新需求」渐变按钮 + 需求卡片列表（标题/副标题/票数/标签）
- 对应 dart 文件: `lib/features/community/widgets/board_my_requests_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - `('希望增加错题导出PDF功能', '可以把错题按模型分组导出打印', 23票, ['功能请求', '3天前'], highlight: true)`
  - `('数学也需要过程拆分训练', '解析几何大题特别需要过程拆分', 45票, ['功能请求', '高票', '5天前'], highlight: true)`
  - `('闪卡能不能支持手写公式', '打字输入公式太麻烦了', 8票, ['体验优化', '1周前'], highlight: false)`
- 对应数据模型: `CommunityRequest`（来自 `lib/shared/models/community_models.dart`）
- 注意: widget 内部定义了一个旧的 `CommunityRequest` 类（含 `highlight` 字段），需迁移到 shared model
- 需要的 API 字段:
  - `id` (String) — 需求唯一标识
  - `title` (String) — 需求标题
  - `subtitle` (String) — 需求描述
  - `votes` (int) — 投票数
  - `tags` (List\<String\>) — 标签列表
  - `status` (String) — 状态：open / planned / done

---

### board-feature-boost

![board-feature-boost](../flutter截图验证/community/components/board-feature-boost__390x844.png)

- 功能说明: 新功能投票占位卡片，展示 `--` 图标 + 说明文字
- 对应 dart 文件: `lib/features/community/widgets/board_feature_boost_widget.dart`
- 当前数据状态: 纯静态占位
- 硬编码值:
  - 图标: `'--'`
  - 标题: `'新功能投票'`
  - 描述: `'为你最想要的功能投票, 票数越高优先开发'`
- 对应数据模型: `CommunityRequest`（复用，按投票排序）
- 需要的 API 字段: 同 board-my-requests

---

### board-feedback

![board-feedback](../flutter截图验证/community/components/board-feedback__390x844.png)

- 功能说明: 改版建议占位卡片，展示 `--` 图标 + 说明文字
- 对应 dart 文件: `lib/features/community/widgets/board_feedback_widget.dart`
- 当前数据状态: 纯静态占位
- 硬编码值:
  - 图标: `'--'`
  - 标题: `'改版建议'`
  - 描述: `'提交你对现有功能的改进建议'`
- 对应数据模型: `CommunityRequest`（复用）
- 需要的 API 字段: 同 board-my-requests

---

## 数据模型

来自 `lib/shared/models/community_models.dart`：

```dart
class CommunityRequest {
  final String id;
  final String title;
  final String subtitle;
  final int votes;
  final List<String> tags;
  final String status; // 'open', 'planned', 'done'
}
```

注意：`board_my_requests_widget.dart` 内部还有一个旧的本地 `CommunityRequest` 类（含 `highlight` 字段），接入 API 时需统一迁移到 shared model。

## API 接口清单

| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/community/requests` | GET | 获取我的需求列表 | `List<CommunityRequest>` |
| `/api/community/requests` | POST | 提交新需求 | `CommunityRequest` |
| `/api/community/requests/:id/vote` | POST | 为需求投票 | `{ votes: int }` |
| `/api/community/feature-boost` | GET | 获取功能助推列表（按票数排序） | `List<CommunityRequest>` |
| `/api/community/feedback` | GET | 获取反馈墙列表 | `List<CommunityRequest>` |

## 接入示例

```dart
// 获取我的需求列表
final resp = await api.get('/api/community/requests');
final requests = (resp.data as List)
    .map((e) => CommunityRequest.fromJson(e))
    .toList();

BoardMyRequestsWidget(requests: requests);
```

## 页面跳转

- 需求卡片点击 → `/community-detail`
- 提交新需求按钮 → 弹出提交表单（待实现）
