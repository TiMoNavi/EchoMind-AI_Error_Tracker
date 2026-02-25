# community-detail（社区详情）

## 当前状态

第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识

`/community-detail`

## 组件树

```
CommunityDetailPage (Scaffold)
├── ClayBackgroundBlobs — Claymorphism 浮动背景
└── ClayCard — 需求详情卡片
    ├── Text — 标题
    ├── Text — 描述正文
    └── Row — 投票数 + 类型标签 + 时间
```

## 页面截图

![community-detail-390x844](../flutter截图验证/community-detail/full/community-detail__390x844__full.png)

---

## 组件详情

### detail-card

![detail-card](../flutter截图验证/community-detail/components/detail-card__390x844.png)

- 功能说明: 单张 ClayCard 展示需求完整信息：标题、描述正文、投票数、类型标签、发布时间
- 对应 dart 文件: `lib/features/community/community_detail_page.dart`（页面内联，无独立 widget）
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题: `'希望增加错题导出PDF功能'`
  - 描述: `'可以把错题按模型分组导出打印，方便线下复习使用。'`
  - 投票: `'23票'`
  - 标签: `'功能请求 · 3天前'`
- 对应数据模型: `CommunityRequest`（来自 `lib/shared/models/community_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 需求唯一标识
  - `title` (String) — 需求标题
  - `subtitle` (String) — 需求描述
  - `votes` (int) — 投票数
  - `tags` (List\<String\>) — 标签列表
  - `status` (String) — 状态

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
  final String status;
}
```

## API 接口清单

| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/community/requests/:id` | GET | 获取单条需求详情 | `CommunityRequest` |
| `/api/community/requests/:id/vote` | POST | 为该需求投票 | `{ votes: int }` |

## 接入示例

```dart
// 获取需求详情（通过路由参数传入 id）
final resp = await api.get('/api/community/requests/$requestId');
final request = CommunityRequest.fromJson(resp.data);

// 在页面中使用
Text(request.title, style: AppTheme.heading(size: 18));
Text(request.subtitle, style: AppTheme.body(size: 14));
Text('${request.votes}票', style: ...);
```

## 页面跳转

- AppBar 返回按钮 → 返回上一页（`/community`）
