# upload-history（上传历史）

## 当前状态

第二阶段完成，所有组件已实现，视觉效果已对齐 HTML 原型。

## 路由标识

`/upload-history`

## 组件树

```
UploadHistoryPage (Scaffold)
├── TopFrameWidget — 页面标题 + 返回
├── HistoryFilterWidget — 筛选标签栏
└── HistoryRecordListWidget — 上传记录列表
```

## 页面截图

![upload-history-390x844](../flutter截图验证/upload-history/full/upload-history__390x844__full.png)

---

## 组件详情

### top-frame

![top-frame](../flutter截图验证/upload-history/components/top-frame__390x844.png)

- 功能说明: 返回按钮 + 标题「上传历史」
- 预期用途: 导航返回 + 页面标题展示，无数据接入需求
- 对应 dart 文件: `lib/features/upload_history/widgets/top_frame_widget.dart`
- 视觉状态: 已对齐 HTML 原型

### history-filter

![history-filter](../flutter截图验证/upload-history/components/history-filter__390x844.png)

- 功能说明: 5 个筛选标签（全部/待诊断/已完成/作业/考试）
- 预期用途: 提供上传记录的筛选功能，切换时联动下方列表。无独立数据接入需求
- 对应 dart 文件: `lib/features/upload_history/widgets/history_filter_widget.dart`
- 视觉状态: 已对齐 HTML 原型

### history-record-list

![history-record-list](../flutter截图验证/upload-history/components/history-record-list__390x844.png)

- 功能说明: 按日期分组展示上传记录
- 预期用途: 接入用户上传记录 API，按日期分组展示每次上传的类型(作业HW/考试EX/极简QK)、错题数、诊断进度。「待诊断」状态的记录点击后跳转题目详情页，引导用户完成 AI 诊断闭环。当前为 mock 数据
- 对应 dart 文件: `lib/features/upload_history/widgets/history_record_list_widget.dart`
- 视觉状态: 已对齐 HTML 原型

## 页面跳转

- 返回按钮 → 返回上一页
- 待诊断记录点击 → `/question-detail`
