# register-strategy（学习策略）

## 当前状态

占位页面，尚未实现完整组件。当前为简单 Scaffold + 居中文本。

## 路由标识

`/register-strategy`

## 组件树

```
RegisterStrategyPage (Scaffold)
└── Center(Text('注册策略'))
```

## 页面截图

![register-strategy-390x844](../flutter截图验证/register-strategy/full/register-strategy__390x844__full.png)

---

## 组件详情

本页面当前为占位实现，widget 文件存在但未被页面引用：

### top-frame（未使用）

- 功能说明: 返回按钮 + 标题「卷面策略」
- 预期用途: 导航返回 + 页面标题展示
- 对应 dart 文件: `lib/features/register_strategy/widgets/top_frame_widget.dart`
- 视觉状态: 占位 Placeholder，待实现

### main-content（未使用）

- 功能说明: 卷面策略配置主体内容
- 预期用途: 接入卷面策略 API，展示考试各题的策略配置（MUST/TRY/SKIP），帮助用户制定考试答题策略。当前为 Placeholder，待实现
- 对应 dart 文件: `lib/features/register_strategy/widgets/main_content_widget.dart`
- 视觉状态: 占位 Placeholder，待实现

## 页面跳转

- 返回按钮 → 返回上一页（/profile）
