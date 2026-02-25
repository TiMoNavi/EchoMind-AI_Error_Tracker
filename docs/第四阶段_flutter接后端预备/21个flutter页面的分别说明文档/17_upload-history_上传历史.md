# upload-history（上传历史）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/upload-history`

## 组件树
```
UploadHistoryPage (Scaffold)
├── TopFrameWidget                    ← 返回按钮 + 标题
├── HistoryFilterWidget               ← 筛选标签栏（全部/待诊断/已完成/作业/考试）
└── Expanded
    └── Stack
        ├── ClayBackgroundBlobs       ← 背景装饰
        └── HistoryRecordListWidget   ← 按日期分组的上传记录列表
```

## 页面截图
![upload-history-390x844](../flutter截图验证/upload-history/full/upload-history__390x844__full.png)

---

## 组件详情

### TopFrameWidget
![top_frame_widget](../flutter截图验证/upload-history/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮和页面标题"上传历史"
- 对应 dart 文件: `lib/features/upload_history/widgets/top_frame_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题文字: `'上传历史'`
- 对应数据模型: 无独立模型
- 需要的 API 字段: 无（纯静态标题）

---

### HistoryFilterWidget
![history_filter_widget](../flutter截图验证/upload-history/components/history_filter_widget__390x844.png)
- 功能说明: 横向滚动的筛选标签栏，Claymorphism 内凹容器 + 选中态凸起白色胶囊，支持点击切换筛选条件
- 对应 dart 文件: `lib/features/upload_history/widgets/history_filter_widget.dart`
- 当前数据状态: 已参数化（构造函数接收 filters 参数，但有默认 mock 值）
- 硬编码值:
  - 筛选标签: `['全部', '待诊断', '已完成', '作业', '考试']`
- 对应数据模型: 无独立模型（纯 UI 筛选组件）
- 需要的 API 字段:
  - `filterType` (String) — 筛选类型，作为查询参数传给记录列表 API

---

### HistoryRecordListWidget
![history_record_list_widget](../flutter截图验证/upload-history/components/history_record_list_widget__390x844.png)
- 功能说明: 按日期分组的上传记录列表，每条记录显示类型图标（HW/EX/QK）、标题、描述、时间和状态标签，点击跳转到题目详情页
- 对应 dart 文件: `lib/features/upload_history/widgets/history_record_list_widget.dart`
- 当前数据状态: 已参数化（构造函数接收 groupedRecords 参数，但有默认 mock 值）
- 硬编码值:
  - 今天: `HistoryRecord('HW', '作业 -- 力学练习', '3道错题 -- 1道已诊断, 2道待诊断', '14:30', '2待诊断')`
  - 2月8日: `HistoryRecord('EX', '2025天津模拟卷(一)', '6道错题 -- 3道待诊断', '10:15', '3待诊断')`
  - 2月5日: `HistoryRecord('HW', '作业 -- 电场练习', '2道错题 -- 全部已诊断', '16:42', '已完成')`
  - 2月3日: `HistoryRecord('EX', '2024天津高考真题', '8道错题 -- 全部已诊断', '09:30', '已完成')`, `HistoryRecord('QK', '极简上传 -- 5道题', '1道错题 -- 已诊断', '20:10', '已完成')`
- 对应数据模型: `UploadRecord`, `UploadDateGroup`（来自 `lib/shared/models/upload_history_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 记录唯一标识
  - `title` (String) — 记录标题
  - `description` (String) — 记录描述
  - `time` (String) — 上传时间
  - `status` (String) — 状态（diagnosed/pending/failed）
  - `type` (String) — 类型（photo/text/file）

> **注意**: 组件内部定义了局部类 `HistoryRecord`（含 iconLabel/iconBg/title/desc/time/status/isPending），与 `upload_history_models.dart` 中的 `UploadRecord`（含 id/title/description/time/status/type）结构不同，接入 API 时需要迁移对齐。

---

## 数据模型

```dart
// lib/shared/models/upload_history_models.dart

class UploadRecord {
  final String id;
  final String title;
  final String description;
  final String time;
  final String status;   // 'diagnosed', 'pending', 'failed'
  final String type;     // 'photo', 'text', 'file'
}

class UploadDateGroup {
  final String date;
  final List<UploadRecord> records;
}
```

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/upload/history` | GET | 获取上传历史记录列表（支持 filter 查询参数） | `List<UploadDateGroup>` |
| `/api/upload/history?filter={type}` | GET | 按类型筛选上传记录 | `List<UploadDateGroup>` |

## 接入示例

```dart
// 1. 获取上传历史（按日期分组）
final groups = await api.getUploadHistory(filter: selectedFilter);

// 2. 转换为组件所需的 Map 格式
final grouped = <String, List<HistoryRecord>>{};
for (final g in groups) {
  grouped[g.date] = g.records.map((r) => HistoryRecord(
    _typeIcon(r.type),
    _typeBg(r.type),
    r.title,
    r.description,
    r.time,
    _statusLabel(r.status),
    r.status == 'pending',
  )).toList();
}

// 3. 注入到组件
HistoryRecordListWidget(groupedRecords: grouped);
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页）
- 记录项点击 → `/question-detail`
