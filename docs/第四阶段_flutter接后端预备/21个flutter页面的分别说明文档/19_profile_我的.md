# profile（我的）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/profile`

## 组件树
```
ProfilePage (PageShell, tabIndex: 4)
└── Stack
    ├── ClayBackgroundBlobs           ← 背景装饰
    └── ListView
        ├── TopFrameWidget            ← 页面标题"我的"
        ├── UserInfoCardWidget        ← 用户信息卡片（头像/姓名/标签）
        ├── TargetScoreCardWidget     ← 目标分数卡片
        ├── ThreeRowNavigationWidget  ← 三行导航（上传历史/周复盘/卷面策略）
        ├── TwoRowNavigationWidget    ← 两行导航（通知设置/关于）
        └── LearningStatsWidget       ← 学习统计卡片
```

## 页面截图
![profile-390x844](../flutter截图验证/profile/full/profile__390x844__full.png)

---

## 组件详情

### TopFrameWidget
![top_frame_widget](../flutter截图验证/profile/components/top_frame_widget__390x844.png)
- 功能说明: 页面标题"我的"，无返回按钮（底部 Tab 页面）
- 对应 dart 文件: `lib/features/profile/widgets/top_frame_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题文字: `'我的'`
- 对应数据模型: 无独立模型
- 需要的 API 字段: 无（纯静态标题）

---

### UserInfoCardWidget
![user_info_card_widget](../flutter截图验证/profile/components/user_info_card_widget__390x844.png)
- 功能说明: 用户信息卡片，渐变背景，左侧渐变圆形头像（显示首字母），右侧显示姓名、副标题和标签
- 对应 dart 文件: `lib/features/profile/widgets/user_info_card_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，但有默认 mock 值）
- 硬编码值:
  - 姓名: `'同学 S'`
  - 首字母: `'S'`
  - 副标题: `'天津 -- 高三 -- 物理+数学'`
  - 标签: `['完整订阅', '2026.3.15到期']`
- 对应数据模型: `UserProfile`（来自 `lib/shared/models/profile_models.dart`）
- 需要的 API 字段:
  - `name` (String) — 用户姓名
  - `initial` (String) — 头像首字母
  - `subtitle` (String) — 副标题描述
  - `tags` (List&lt;String&gt;) — 用户标签列表

---

### TargetScoreCardWidget
![target_score_card_widget](../flutter截图验证/profile/components/target_score_card_widget__390x844.png)
- 功能说明: 目标分数卡片，显示目标分数（大字体）、科目和卷面策略描述，右上角有"修改"按钮
- 对应 dart 文件: `lib/features/profile/widgets/target_score_card_widget.dart`
- 当前数据状态: 已参数化（构造函数接收参数，但有默认 mock 值）
- 硬编码值:
  - 目标分数: `70`
  - 科目: `'物理'`
  - 策略描述: `'卷面策略: 选择题最多错2个, 大题前两道拿满'`
- 对应数据模型: `UserProfile`（来自 `lib/shared/models/profile_models.dart`）
- 需要的 API 字段:
  - `targetScore` (int) — 目标分数
  - `currentScore` (int) — 当前分数

---

### ThreeRowNavigationWidget
![three_row_navigation_widget](../flutter截图验证/profile/components/three_row_navigation_widget__390x844.png)
- 功能说明: 三行导航卡片，每行包含渐变图标、标签文字和右箭头。第一行"上传历史"额外显示记录数
- 对应 dart 文件: `lib/features/profile/widgets/three_row_navigation_widget.dart`
- 当前数据状态: 已参数化（uploadCount 参数，但有默认 mock 值）
- 硬编码值:
  - 上传历史记录数: `'32条'`
  - 导航项: 上传历史(UL) / 周复盘(WK) / 卷面策略(EP)
- 对应数据模型: 无独立模型（纯导航组件，uploadCount 来自 API）
- 需要的 API 字段:
  - `uploadCount` (int) — 上传历史总条数

---

### TwoRowNavigationWidget
![two_row_navigation_widget](../flutter截图验证/profile/components/two_row_navigation_widget__390x844.png)
- 功能说明: 两行导航卡片，每行包含渐变图标、标签文字和右箭头。通知设置和关于页面入口
- 对应 dart 文件: `lib/features/profile/widgets/two_row_navigation_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 导航项: 通知设置(notifications_none) / 关于(info_outline)
- 对应数据模型: 无独立模型（纯导航组件）
- 需要的 API 字段: 无（纯静态导航）

---

### LearningStatsWidget
![learning_stats_widget](../flutter截图验证/profile/components/learning_stats_widget__390x844.png)
- 功能说明: 学习统计卡片，四个统计指标横排展示（累计天数/总闭环数/总学习时长/预测提升）
- 对应 dart 文件: `lib/features/profile/widgets/learning_stats_widget.dart`
- 当前数据状态: 已参数化（构造函数接收 stats 参数，但有默认 mock 值）
- 硬编码值:
  - 累计天数: `'28'`
  - 总闭环数: `'142'`
  - 总学习时长: `'48h'`
  - 预测提升: `'+8'`
- 对应数据模型: `LearningStats`（来自 `lib/shared/models/profile_models.dart`）
- 需要的 API 字段:
  - `cumulativeDays` (int) — 累计天数
  - `totalClosures` (int) — 总闭环数
  - `totalStudyTime` (String) — 总学习时长
  - `predictedImprovement` (int) — 预测提升分数

---

## 数据模型

```dart
// lib/shared/models/profile_models.dart

class UserProfile {
  final String name;
  final String initial;
  final String subtitle;
  final List<String> tags;
  final int targetScore;
  final int currentScore;
}

class LearningStats {
  final int cumulativeDays;
  final int totalClosures;
  final String totalStudyTime;
  final int predictedImprovement;
}
```

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/user/profile` | GET | 获取用户基本信息 | `UserProfile` |
| `/api/user/learning-stats` | GET | 获取学习统计数据 | `LearningStats` |
| `/api/user/target-score` | PUT | 修改目标分数 | `UserProfile` |

## 接入示例

```dart
// 1. 获取用户信息
final profile = await api.getUserProfile();
UserInfoCardWidget(
  name: profile.name,
  initial: profile.initial,
  subtitle: profile.subtitle,
  tags: profile.tags,
);

// 2. 获取学习统计
final stats = await api.getLearningStats();
LearningStatsWidget(stats: [
  ('${stats.cumulativeDays}', '累计天数'),
  ('${stats.totalClosures}', '总闭环数'),
  (stats.totalStudyTime, '总学习时长'),
  ('+${stats.predictedImprovement}', '预测提升'),
]);
```

## 页面跳转
- 上传历史 → `/upload-history`
- 周复盘 → `/weekly-review`
- 卷面策略 → `/register-strategy`
- 通知设置 → 暂未实现
- 关于 → 暂未实现
