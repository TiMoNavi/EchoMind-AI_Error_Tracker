# EchoMind UI 美化迁移规划

## 背景

| 项目       | 路径                          | 定位                         |
| ---------- | ----------------------------- | ---------------------------- |
| 主应用 (A) | `echomind_app/`             | 已接后端，iOS 简约风格       |
| 美化版 (B) | `flutter前端/echomind_app/` | 纯 UI，Claymorphism 设计系统 |

**目标**：将 B 的 Claymorphism 视觉效果逐页迁移到 A，严格保留 A 的后端对接与状态管理逻辑不变。

请注意B的后端逻辑和状态管理逻辑是错误的，仅参考B的美观效果

---

## 迁移原则

1. **只迁 UI，不迁逻辑** — B 中的 mock 数据、假路由、缺失的 provider 一律忽略
2. **先基础后页面** — 先迁移主题/共享组件，再逐页替换
3. **每页一个 commit** — 迁移一页，测试一页，提交一页
4. **保留 A 的数据流** — widget 的 `build()` 方法中替换 UI 表现层，数据绑定保持原样

---

## 阶段 0：基础设施（必须最先完成）

### 0.1 主题系统替换

- **文件**：`echomind_app/lib/shared/theme/app_theme.dart`
- **操作**：用 B 的 Claymorphism 主题覆盖 A 的 iOS 主题
- **内容**：
  - Candy Shop 调色板（Violet / Hot Pink / Sky Blue）
  - Claymorphism 阴影栈（shadowClayCard / Button / Pressed / StatOrb）
  - 渐变定义（gradientPrimary / Pink / Blue / Green / Hero）
  - 超圆角系统（radiusXl / radiusCard / radiusHero）
  - Google Fonts 排版（Nunito 标题 / DM Sans 正文）
  - Legacy aliases 保留，确保未迁移页面不崩溃

### 0.2 添加依赖

- **文件**：`echomind_app/pubspec.yaml`
- **操作**：添加 `google_fonts` 依赖（如尚未存在）

### 0.3 共享组件迁移

从 B 复制以下共享 widget 到 A 的 `lib/shared/widgets/`：

| 组件                | 文件                           | 用途                                     |
| ------------------- | ------------------------------ | ---------------------------------------- |
| ClayCard            | `clay_card.dart`             | 通用 Claymorphism 卡片容器               |
| ClayBackgroundBlobs | `clay_background_blobs.dart` | 页面背景装饰                             |
| ClayEmptyState      | `clay_empty_state.dart`      | 空状态占位                               |
| ClayErrorState      | `clay_error_state.dart`      | 错误状态占位                             |
| ClayLoadingState    | `clay_loading_state.dart`    | 加载状态占位                             |
| AsyncDataWrapper    | `async_data_wrapper.dart`    | 异步数据包装器                           |
| Chat 组件组         | `chat/*.dart`                | 聊天气泡/输入栏/消息列表/选项芯片/富卡片 |

### 0.4 底部导航栏更新

- **文件**：`echomind_app/lib/shared/widgets/main_bottom_nav.dart`
- **操作**：对比 B 的样式，更新图标/颜色/动画

---

## 阶段 1：核心页面（用户高频使用）

按优先级排序，每项标注迁移要点：

### 1.1 首页 (Home)

- **A 的文件**：`lib/features/home/`（home_page + 5 个 widget）
- **B 的文件**：`flutter前端/.../features/home/`
- **迁移要点**：
  - 顶部框架 → Clay 风格 Hero 渐变背景
  - 仪表盘卡片 → ClayCard + shadowClayStatOrb
  - 推荐列表 → 渐变标签 + 圆角卡片
  - 操作浮层 → Clay 按钮阴影
- **注意**：保留 A 中 `HomeProvider` 的数据绑定

### 1.2 个人中心 (Profile)

- **A 的文件**：`lib/features/profile/`
- **迁移要点**：
  - 头像区域 → 渐变光环 + Clay 阴影
  - 统计卡片 → ClayCard 网格
  - 设置列表 → 圆角分组样式

### 1.3 社区 (Community)

- **A 的文件**：`lib/features/community/`
- **迁移要点**：
  - 帖子卡片 → ClayCard + 渐变标签
  - 投票/点赞按钮 → Clay 按钮样式
  - 考虑从 B 迁入 `community_detail_page.dart`（A 中缺失）

---

## 阶段 2：学习功能页面

### 2.1 知识图谱 (Global Knowledge)

- **A 的文件**：`lib/features/global_knowledge/`
- **迁移要点**：树形节点 → Clay 圆角节点 + 渐变连线

### 2.2 知识详情 (Knowledge Detail)

- **迁移要点**：详情卡片 → ClayCard，掌握度指示器 → 渐变进度条

### 2.3 知识学习 (Knowledge Learning)

- **迁移要点**：5 步学习流程的步骤指示器 + 内容卡片样式

### 2.4 闪卡复习 (Flashcard Review)

- **迁移要点**：翻转卡片 → Clay 双面卡片 + 阴影动画

### 2.5 记忆曲线 (Memory)

- **迁移要点**：曲线图表样式 + 复习队列卡片

---

## 阶段 3：错题与模型页面

### 3.1 错题聚合 (Question Aggregate)

- **迁移要点**：统计图表 → 渐变配色，错题列表 → ClayCard

### 3.2 错题详情 (Question Detail)

- **迁移要点**：题目展示卡片 + AI 解析区域样式

### 3.3 模型总览 (Global Model)

- **迁移要点**：模型树 → Clay 节点样式

### 3.4 模型详情 (Model Detail)

- **迁移要点**：详情面板 + 训练进度指示器

### 3.5 模型训练 (Model Training)

- **迁移要点**：6 步训练流程的步骤 UI

---

## 阶段 4：工具与分析页面

### 4.1 AI 诊断 (AI Diagnosis)

- **迁移要点**：Chat 组件组迁入，对话界面 Clay 化

### 4.2 成绩预测 (Prediction Center)

- **迁移要点**：预测图表 + 置信区间样式

### 4.3 考试分析 (Global Exam)

- **迁移要点**：考试统计卡片 + 趋势图

### 4.4 周报 (Weekly Review)

- **迁移要点**：周报卡片 + 数据可视化样式

### 4.5 上传相关 (Upload Menu / Upload History)

- **迁移要点**：上传入口卡片 + 历史记录列表

### 4.6 注册策略 (Register Strategy)

- **迁移要点**：策略选择卡片样式

---

## 阶段 5：收尾

### 5.1 登录/注册页美化

- A 独有的 auth 页面，参考 B 的设计语言自行美化
- 应用 Claymorphism 输入框、按钮、背景

### 5.2 全局检查

- 所有页面在 Claymorphism 主题下的一致性
- 深色/浅色模式兼容性（如需要）
- 不同屏幕尺寸的响应式表现

### 5.3 清理

- 移除 A 中不再使用的旧 iOS 风格代码
- 确认无残留的硬编码旧颜色值

---

## 每页迁移 SOP（标准操作流程）

对于每个页面，执行以下步骤：

```
1. 并排打开 A 和 B 的对应页面文件
2. 识别 B 中纯 UI 变更（颜色/阴影/圆角/字体/布局）
3. 识别 B 中的 mock 数据 / 假路由 → 标记为【忽略】
4. 将 UI 变更逐 widget 应用到 A，保留 A 的 provider 数据绑定
5. 编译运行，确认页面正常渲染且后端数据正常显示
6. 提交 commit：`style(页面名): 迁移 Claymorphism UI`
```

---

## 风险与注意事项

| 风险                              | 应对                            |
| --------------------------------- | ------------------------------- |
| B 的 widget 引用了 B 独有的 model | 改为使用 A 的 model，只取 UI 层 |
| Google Fonts 网络加载慢           | 考虑预打包字体文件              |
| Clay 阴影在低端设备性能差         | 可选降级：减少阴影层数          |
| B 中某些 UI 依赖 mock 数据结构    | 适配 A 的真实数据结构，字段映射 |
| 迁移过程中 A 的后端接口变更       | 先完成后端稳定，再批量迁移 UI   |

---

## 页面清单速查（共 22 页）

| #  | 页面               | 阶段 | 复杂度         |
| -- | ------------------ | ---- | -------------- |
| 1  | Home               | 1    | ★★★         |
| 2  | Profile            | 1    | ★★           |
| 3  | Community          | 1    | ★★★         |
| 4  | Global Knowledge   | 2    | ★★           |
| 5  | Knowledge Detail   | 2    | ★★           |
| 6  | Knowledge Learning | 2    | ★★★         |
| 7  | Flashcard Review   | 2    | ★★           |
| 8  | Memory             | 2    | ★★           |
| 9  | Question Aggregate | 3    | ★★           |
| 10 | Question Detail    | 3    | ★★           |
| 11 | Global Model       | 3    | ★★           |
| 12 | Model Detail       | 3    | ★★           |
| 13 | Model Training     | 3    | ★★★         |
| 14 | AI Diagnosis       | 4    | ★★★         |
| 15 | Prediction Center  | 4    | ★★           |
| 16 | Global Exam        | 4    | ★★           |
| 17 | Weekly Review      | 4    | ★★           |
| 18 | Upload Menu        | 4    | ★             |
| 19 | Upload History     | 4    | ★             |
| 20 | Register Strategy  | 4    | ★             |
| 21 | Login / Register   | 5    | ★★           |
| 22 | Community Detail   | 1    | ★★（新增页） |
