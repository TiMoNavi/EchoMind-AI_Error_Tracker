# home（首页）

## 当前状态

第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识

`/`

## 组件树

```
HomePage (PageShell, tabIndex: 0)
├── ClayBackgroundBlobs — Claymorphism 浮动背景
├── TopFrameWidget — 页面标题「主页」+ 通知铃铛 + 用户头像
├── TopDashboardWidget — Hero 预测卡（圆形进度环）+ 统计行（三列）
├── UploadErrorCardWidget — 溢出图标双卡片（拍照/文本上传）
├── RecommendationListWidget — 推荐学习列表（优先级分层）
├── RecentUploadWidget — 最近上传记录摘要
└── _ClayFab — 右下角上传浮动按钮
```

## 页面截图

![home-390x844](../flutter截图验证/home/full/home__390x844__full.png)

---

## 组件详情

### top-frame

![top-frame](../flutter截图验证/home/components/top-frame__390x844.png)

- 功能说明: 页面标题「主页」+ 通知铃铛圆球 + 用户头像渐变圆球
- 对应 dart 文件: `lib/features/home/widgets/top_frame_widget.dart`
- 当前数据状态: 标题已参数化（`title = '主页'`），头像/通知为静态图标
- 硬编码值: `title: '主页'`
- 对应数据模型: 无（纯展示组件，后续可接入用户头像 URL）
- 需要的 API 字段:
  - `unread_notification_count` (int) — 未读通知数（可选，用于铃铛角标）

---

### top-dashboard

![top-dashboard](../flutter截图验证/home/components/top-dashboard__390x844.png)

- 功能说明: Hero 预测卡（圆形进度环 + 趋势折线图）+ 统计行（三列 StatOrb）
- 对应 dart 文件: `lib/features/home/widgets/top_dashboard_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 预测分数: `63`，总分: `100`，目标: `70`
  - 趋势数据: `[55, 57, 59, 61, 60, 63]`
  - 趋势标签: `'+3 分 (近7天)'`
  - 统计行: `('3', '今日闭环')`, `('2h25m', '学习时长')`, `('12', '本周闭环')`
- 对应数据模型: `HomeDashboard`（来自 `lib/shared/models/home_models.dart`）
- 需要的 API 字段:
  - `predicted_score` (int) — 预测分数
  - `total_score` (int) — 总分（默认100）
  - `target_score` (int) — 目标分数
  - `trend_data` (List\<int\>) — 近期趋势数据点
  - `score_change` (int) — 分数变化值（如 +3）
  - `today_closures` (int) — 今日闭环数
  - `study_time` (String) — 学习时长（如 "2h25m"）
  - `weekly_closures` (int) — 本周闭环数

---

### action-overlay

![action-overlay](../flutter截图验证/home/components/action-overlay__390x844.png)

- 功能说明: 溢出图标双卡片（拍照上传 / 文本上传），大图标悬浮于 ClayCard 上方
- 对应 dart 文件: `lib/features/home/widgets/action_overlay_widget.dart`
- 当前数据状态: 纯静态展示组件，无需数据
- 硬编码值:
  - 左卡: icon=`camera_alt_rounded`, label=`'拍照上传'`, rotation=`-12`
  - 右卡: icon=`description_rounded`, label=`'文本上传'`, rotation=`10`
- 对应数据模型: 无（纯导航组件）
- 需要的 API 字段: 无
- 点击行为: 两张卡片均跳转 → `/upload-menu`

---

### recommendation-list

![recommendation-list](../flutter截图验证/home/components/recommendation-list__390x844.png)

- 功能说明: 推荐学习列表，按优先级分层（紧急项带粉色左边框，普通项为 ClayCard）
- 对应 dart 文件: `lib/features/home/widgets/recommendation_list_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - `('待诊断: 2025天津模拟 第5题', ['待诊断', '上传于今日'], isUrgent: true)` → `/ai-diagnosis`
  - `('板块运动 — 建模层训练', ['本周错2次', '约5分钟'])` → `/model-detail`
  - `('库仑定律适用条件 — 知识补强', ['理解不深', '约3分钟'])` → `/knowledge-detail`
  - `('牛顿第二定律应用 — 不稳定', ['掌握不稳定', '14天未练习'])` → `/model-detail`
- 对应数据模型: `Recommendation`（来自 `lib/shared/models/home_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 推荐项唯一标识
  - `type` (String) — 类型：diagnosis / model_training / knowledge / review
  - `title` (String) — 推荐标题
  - `tags` (List\<String\>) — 标签列表
  - `route` (String) — 跳转路由
  - `is_urgent` (bool) — 是否紧急（决定粉色边框样式）

---

### recent-upload

![recent-upload](../flutter截图验证/home/components/recent-upload__390x844.png)

- 功能说明: 最近上传记录摘要卡片，单行展示未诊断错题数
- 对应 dart 文件: `lib/features/home/widgets/recent_upload_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题: `'最近上传'`
  - 摘要: `'3道错题未诊断'`
- 对应数据模型: `RecentUpload`（来自 `lib/shared/models/home_models.dart`）
- 需要的 API 字段:
  - `pending_count` (int) — 待诊断错题数
  - `summary` (String) — 摘要文本
- 点击行为: 整卡跳转 → `/upload-history`

---

## 数据模型

来自 `lib/shared/models/home_models.dart`：

```dart
class HomeDashboard {
  final int predictedScore;
  final int totalScore;
  final int targetScore;
  final List<int> trendData;
  final int scoreChange;
  final int todayClosures;
  final String studyTime;
  final int weeklyClosures;
  final int undiagnosedCount;
}

class Recommendation {
  final String id;
  final String type;
  final String title;
  final List<String> tags;
  final String route;
  final bool isUrgent;
}

class RecentUpload {
  final int pendingCount;
  final String summary;
}
```

## API 接口清单

| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/home/dashboard` | GET | 获取首页仪表盘数据（预测分、趋势、统计） | `HomeDashboard` |
| `/api/home/recommendations` | GET | 获取推荐学习列表 | `List<Recommendation>` |
| `/api/home/recent-upload` | GET | 获取最近上传摘要 | `RecentUpload` |

## 接入示例

```dart
// 在 HomePage 中注入 API 数据到 TopDashboardWidget
final dashboard = await api.get('/api/home/dashboard');
final model = HomeDashboard.fromJson(dashboard.data);

TopDashboardWidget(
  predictedScore: model.predictedScore,
  totalScore: model.totalScore,
  targetScore: model.targetScore,
  trendData: model.trendData,
  scoreChange: model.scoreChange,
  todayClosures: model.todayClosures,
  studyTime: model.studyTime,
  weeklyClosures: model.weeklyClosures,
);

// 推荐列表
final recResp = await api.get('/api/home/recommendations');
final recs = (recResp.data as List)
    .map((e) => Recommendation.fromJson(e))
    .toList();

RecommendationListWidget(items: recs);

// 最近上传
final uploadResp = await api.get('/api/home/recent-upload');
final upload = RecentUpload.fromJson(uploadResp.data);

RecentUploadWidget(
  pendingCount: upload.pendingCount,
  summary: upload.summary,
);
```

## 页面跳转

- Hero 预测卡点击 → `/prediction-center`
- 拍照上传卡片 → `/upload-menu`
- 文本上传卡片 → `/upload-menu`
- 推荐项（待诊断） → `/ai-diagnosis`
- 推荐项（建模层训练） → `/model-detail`
- 推荐项（知识补强） → `/knowledge-detail`
- 最近上传卡片 → `/upload-history`
- 右下角 FAB → `/upload-menu`
