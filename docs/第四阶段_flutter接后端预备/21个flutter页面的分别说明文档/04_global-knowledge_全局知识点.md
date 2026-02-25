# global-knowledge（全局知识点）

## 当前状态

第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识

`/global-knowledge`

## 组件树

```
GlobalKnowledgePage (PageShell, tabIndex: 1)
├── TopFrameWidget — 页面标题「全局知识」+ Clay Tab 栏（知识点/模型方法/高考卷子）
└── KnowledgeTreeWidget — 学科筛选 + 三级可折叠知识树
    ├── _ClayFilterChip — 学科筛选（物理/数学）
    └── ClayCard × N — 章节卡片
        ├── _LevelPill — 掌握等级徽章
        └── 小节/知识点行 — 可展开子项
```

## 页面截图

![global-knowledge-390x844](../flutter截图验证/global-knowledge/full/global-knowledge__390x844__full.png)

---

## 组件详情

### top-frame

![top-frame](../flutter截图验证/global-knowledge/components/top-frame__390x844.png)

- 功能说明: 页面标题「全局知识」+ Clay 凹陷 Tab 栏，三个 Tab 切换全局子页面
- 对应 dart 文件: `lib/features/global_knowledge/widgets/top_frame_widget.dart`
- 当前数据状态: 已参数化（`activeTab` / `onTabChanged`）
- 硬编码值:
  - 标题: `'全局知识'`
  - Tab 列表: `['知识点', '模型/方法', '高考卷子']`
  - 路由映射: `[null, '/global-model', '/global-exam']`（当前页 activeTab=0）
- 对应数据模型: 无（纯导航组件）
- 需要的 API 字段: 无

---

### knowledge-tree

![knowledge-tree](../flutter截图验证/global-knowledge/components/knowledge-tree__390x844.png)

- 功能说明: 三级可折叠知识树（章节→小节→知识点），带学科筛选芯片和掌握等级色标
- 对应 dart 文件: `lib/features/global_knowledge/widgets/knowledge_tree_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 学科筛选: `['物理', '数学']`
  - 章节: `力学(level:4)`, `静电场(level:3)`, `电磁感应(level:0)`
  - 小节示例: `力的概念(5, 3/3)`, `牛顿运动定律(3, 2/3)`, `摩擦力(2, 0/2)`
  - 知识点示例: `力的定义(5)`, `牛顿第二定律(3)`, `滑动摩擦力(3)`
  - 等级色标: 0=红/未掌握, 1=橙/薄弱, 2=黄/一般, 3=蓝/良好, 4=绿/熟练, 5=深绿/精通
- 对应数据模型: `TreeNode`（来自 `lib/shared/models/global_models.dart`）
- 需要的 API 字段:
  - `id` (String) — 节点唯一标识
  - `name` (String) — 节点名称
  - `level` (String) — 掌握等级
  - `mastery_status` (String) — 掌握状态描述
  - `children` (List\<TreeNode\>) — 子节点列表（递归）

---

## 数据模型

来自 `lib/shared/models/global_models.dart`：

```dart
class TreeNode {
  final String id;
  final String name;
  final String? level;
  final String? masteryStatus;
  final List<TreeNode> children;
}
```

## API 接口清单

| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/global/knowledge-tree` | GET | 获取知识点树（按学科） | `List<TreeNode>` |
| `/api/global/knowledge-tree?subject=physics` | GET | 按学科筛选知识树 | `List<TreeNode>` |

## 接入示例

```dart
// 获取知识树
final resp = await api.get(
  '/api/global/knowledge-tree',
  queryParameters: {'subject': 'physics'},
);
final tree = (resp.data as List)
    .map((e) => TreeNode.fromJson(e))
    .toList();

KnowledgeTreeWidget(tree: tree);
```

## 页面跳转

- Tab「模型/方法」→ `/global-model`
- Tab「高考卷子」→ `/global-exam`
- 知识点行点击 → `/knowledge-detail`
