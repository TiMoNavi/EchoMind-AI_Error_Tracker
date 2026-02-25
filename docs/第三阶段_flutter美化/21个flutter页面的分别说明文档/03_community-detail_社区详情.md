# community-detail（社区详情）

## 当前状态

第二阶段完成，页面已实现，视觉效果已对齐 HTML 原型。

## 路由标识

`/community-detail`

## 组件树

```
CommunityDetailPage (独立 Scaffold)
└── 单页面，无子组件拆分
```

## 页面截图

![community-detail-390x844](../flutter截图验证/community-detail/full/community-detail__390x844__full.png)

---

## 组件详情

本页面为独立页面，无子组件拆分。

- 功能说明: 展示单条社区需求/反馈的详情内容
- 预期用途: 接入社区详情 API，展示需求标题、描述、提交者、投票数、评论列表等完整信息。用户可在此页面投票、评论。当前为 mock 数据
- 对应 dart 文件: `lib/features/community/community_detail_page.dart`
- 视觉状态: 已对齐 HTML 原型

## 页面跳转

- 返回按钮 → 返回上一页（/community）
