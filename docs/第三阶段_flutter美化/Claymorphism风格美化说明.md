# Claymorphism 风格美化说明

## 设计风格概述

本次美化采用 **Claymorphism（粘土拟态）** 设计风格，核心理念是"高保真数字粘土"——通过多层阴影、超圆角、糖果色系和微动效，让界面元素呈现出柔软、有体积感、可触摸的质感。

### 风格关键词
- 柔软触感（Soft-touch matte silicone）
- 糖果色系（Candy Store Palette）
- 多层阴影（4-Layer Shadow Stack）
- 超圆角（Super-Rounded, 20px~60px）
- 玻璃粘土混合（Glass-Clay Hybrid）
- 浮动光斑背景（Animated Blobs）

---

## 设计令牌体系

### 色彩

| 用途 | 色值 | 说明 |
|------|------|------|
| 画布背景 | `#F4F1FA` | 冷调薰衣草白，不使用纯白 |
| 主文字 | `#332F3A` | 柔和炭灰，WCAG AA 达标 |
| 次要文字 | `#635F69` | 深薰衣草灰，可读性下限 |
| 主色调 | `#7C3AED` | 鲜艳紫罗兰 |
| 辅助色 | `#DB2777` | 热粉色 |
| 浅紫 | `#A78BFA` | 用于渐变起始色 |
| 信息色 | `#0EA5E9` | 天蓝色 |
| 成功色 | `#10B981` | 翡翠绿 |
| 警告色 | `#F59E0B` | 琥珀色 |
| 危险色 | `#EF4444` | 红色 |

### 字体

| 用途 | 字体 | 字重 |
|------|------|------|
| 标题/数字/强调 | Nunito | 700 / 800 / 900 |
| 正文/标签 | DM Sans | 400 / 500 / 600 / 700 |

### 圆角

| 元素 | 圆角值 |
|------|--------|
| 大容器/英雄区 | 48px |
| 标准卡片 | 32px |
| 按钮/输入框 | 20px |
| 图标容器 | 14px |
| 标签药丸 | 10px |

> 规则：永远不使用小于 20px 的圆角（`radiusSm` 8px 仅保留兼容旧页面）

### 阴影栈

每种元素使用 2~4 层阴影模拟物理光照：

**Clay Card（浮动卡片）**
```
阴影1: offset(16,16) blur(32) rgba(160,150,180,0.2)  — 环境遮蔽
阴影2: offset(-10,-10) blur(24) rgba(255,255,255,0.9) — 左上高光
```

**Clay Button（按钮）**
```
阴影1: offset(12,12) blur(24) rgba(139,92,246,0.3)  — 紫色投影
阴影2: offset(-8,-8) blur(16) rgba(255,255,255,0.4) — 左上高光
```

**Clay Pressed（凹陷/输入框）**
```
阴影1: offset(6,6) blur(12) #D9D4E3   — 内凹暗影
阴影2: offset(-6,-6) blur(12) #FFFFFF  — 内凹高光
```

**Clay Stat Orb（统计圆球）**
```
阴影1: offset(8,8) blur(20) rgba(139,92,246,0.15)  — 柔和紫色投影
阴影2: offset(-6,-6) blur(16) rgba(255,255,255,0.8) — 左上高光
```

### 渐变预设

| 名称 | 起始色 → 终止色 | 用途 |
|------|----------------|------|
| gradientPrimary | `#A78BFA` → `#7C3AED` | 主按钮、FAB |
| gradientPink | `#F472B6` → `#DB2777` | 警告/诊断图标 |
| gradientBlue | `#38BDF8` → `#0EA5E9` | 信息/上传图标 |
| gradientGreen | `#34D399` → `#10B981` | 成功/稳定图标 |

---

## 新增共享组件

### ClayCard (`lib/shared/widgets/clay_card.dart`)

可复用的粘土风格卡片容器，封装了多层阴影、超圆角和半透明白色背景。

参数：
- `radius` — 圆角半径，默认 32px
- `padding` — 内边距，默认 20px
- `color` — 背景色，默认 `white/70%` 半透明
- `shadows` — 阴影栈，默认 `shadowClayCard`
- `onTap` — 可选点击回调

### ClayBackgroundBlobs (`lib/shared/widgets/clay_background_blobs.dart`)

动态浮动背景光斑组件，3 个半透明彩色圆形以不同速率缓慢漂浮，营造环境光照效果。

- 紫色光斑（8s 周期）— 左上区域
- 粉色光斑（10s 周期）— 右侧区域
- 蓝色光斑（12s 周期）— 底部区域

光斑尺寸随屏幕宽度自适应（`width * 0.7`），使用 `IgnorePointer` 不阻挡交互。

---

## 首页美化详情

### 美化进度

| 页面 | 状态 |
|------|------|
| 首页 (home) | 已完成 |
| 其余 20 个页面 | 待美化 |

### 首页改动的文件清单

| 文件 | 类型 | 改动说明 |
|------|------|----------|
| `lib/shared/theme/app_theme.dart` | 修改 | 全新 Claymorphism 令牌系统，保留旧别名兼容 |
| `lib/shared/widgets/clay_card.dart` | 新增 | 可复用粘土卡片组件 |
| `lib/shared/widgets/clay_background_blobs.dart` | 新增 | 动态浮动光斑背景 |
| `lib/shared/widgets/page_shell.dart` | 修改 | 画布背景色 `#F4F1FA` |
| `lib/shared/widgets/main_bottom_nav.dart` | 修改 | 半透明底栏 + 紫色选中态 |
| `lib/features/home/home_page.dart` | 修改 | 添加光斑层 + 粘土 FAB |
| `lib/features/home/widgets/top_frame_widget.dart` | 修改 | Nunito 标题 + 通知圆球 |
| `lib/features/home/widgets/top_dashboard_widget.dart` | 修改 | 三色统计球 + 玻璃预测卡 + 渐变按钮 |
| `lib/features/home/widgets/action_overlay_widget.dart` | 修改 | 紫色渐变上传卡片 |
| `lib/features/home/widgets/recommendation_list_widget.dart` | 修改 | 渐变图标球 + 紫色标签药丸 |
| `lib/features/home/widgets/recent_upload_widget.dart` | 修改 | 蓝色渐变图标 + 粘土卡片 |
| `pubspec.yaml` | 修改 | 添加 `google_fonts: ^6.2.1` |

### 首页各组件美化对照

#### 1. TopFrameWidget — 页面标题栏

**美化前：** 纯文本标题，无装饰
**美化后：**
- Nunito 字体，32px，w900 黑体
- 右侧新增粘土通知圆球（白色半透明 + StatOrb 阴影 + 紫色铃铛图标）

#### 2. TopDashboardWidget — 仪表盘区域

**_StatsRow（统计行）**
- 美化前：白色方形卡片，黑色数字
- 美化后：半透明白色圆角容器（20px），StatOrb 阴影，每个数字使用对应主题色（紫/蓝/绿），Nunito w900 字体

**_PredictionCard（预测卡片）**
- 美化前：白色平面卡片，蓝色数字
- 美化后：ClayCard 组件（32px 圆角），紫色大号分数（42px Nunito），趋势线改用紫色渐变

**_QuickStartButton（快速开始按钮）**
- 美化前：蓝色实色按钮，12px 圆角
- 美化后：紫色渐变按钮（gradientPrimary），20px 圆角，Clay Button 阴影，56px 高度，Nunito 标题字体

#### 3. UploadErrorCardWidget — 上传操作卡片

- 美化前：蓝色渐变（`#007AFF` → `#409CFF`），12px 圆角
- 美化后：紫色渐变（gradientPrimary），20px 圆角，Clay Button 阴影，DM Sans w600 白色文字

#### 4. RecommendationListWidget — 推荐学习列表

- 美化前：白色平面卡片，文字图标（`!`/`L1`/`KP`/`~`），灰色小标签（4px 圆角）
- 美化后：
  - 标题使用 Nunito 20px w800
  - 每项使用 ClayCard（20px 圆角）
  - 文字图标替换为 Material Icons + 渐变圆球（粉/紫/蓝/绿四色，14px 圆角，带彩色投影）
  - 标签改为紫色药丸（紫色 8% 背景 + 紫色文字，10px 圆角）

#### 5. RecentUploadWidget — 最近上传卡片

- 美化前：白色平面卡片，无图标，12px 圆角
- 美化后：ClayCard（20px 圆角），新增蓝色渐变图标圆球（cloud_upload 图标），带蓝色投影

#### 6. HomePage — 页面整体

- 美化前：白色背景，蓝色 FloatingActionButton
- 美化后：
  - 底层添加 ClayBackgroundBlobs 动态光斑
  - FAB 替换为粘土风格圆形按钮（紫色渐变 + Clay Button 阴影）

#### 7. PageShell + MainBottomNav — 全局外壳

- 美化前：纯白 Scaffold 背景，纯白底栏，蓝色选中态
- 美化后：
  - Scaffold 背景改为薰衣草画布色 `#F4F1FA`
  - 底栏改为半透明白色（85% 不透明度）+ 柔和顶部阴影
  - 选中态改为紫罗兰色 `#7C3AED`

---

## 备份说明

原始文件备份位置：`docs/第三阶段_flutter美化/备份/home_original/`

```
备份/home_original/
├── app_theme.dart
├── home_page.dart
├── main_bottom_nav.dart
├── page_shell.dart
└── widgets/
    ├── action_overlay_widget.dart
    ├── recent_upload_widget.dart
    ├── recommendation_list_widget.dart
    ├── top_dashboard_widget.dart
    └── top_frame_widget.dart
```

---

## 兼容性说明

`app_theme.dart` 中保留了旧版别名，确保未美化的页面不受影响：

```dart
static const Color primary = accent;       // #7C3AED (原 #007AFF)
static const Color background = canvas;    // #F4F1FA (原 #F2F2F7)
static const Color surface = cardBg;       // #FFFFFF
static const Color textPrimary = foreground;
static const Color textSecondary = muted;
```

注意：颜色值已从 iOS 蓝色系切换为紫罗兰系，其他页面的蓝色元素会自动跟随变化。如需保持某页面原色，需在该页面内硬编码颜色值。

---

## 风格提示词来源

原始设计系统规范文件：`docs/第三阶段_flutter美化/风格提示词/Claymorphism风格提示词.xml`
