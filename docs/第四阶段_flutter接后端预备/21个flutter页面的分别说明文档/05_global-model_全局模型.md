# global-model（全局模型）

## 当前状态

第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识

`/global-model`

## 组件树

```
GlobalModelPage (PageShell, tabIndex: 1)
├── TopFrameWidget — 页面标题「全局知识」+ Clay Tab 栏（activeIndex=1 模型/方法）
└── ModelTreeWidget — 二级可折叠模型树（分类→模型项）
    ├── ClayCard × N — 分类卡片（受力分析/运动学/能量守恒/电磁学）
    ├── _LevelPill — 掌握等级徽章
    └── 模型项行 — 可展开子项
```

## 页面截图

![global-model-390x844](../flutter截图验证/global-model/full/global-model__390x844__full.png)

---

## 组件详情

### top-frame

![top-frame](../flutter截图验证/global-model/components/top-frame__390x844.png)

- 功能说明: 页面标题「全局知识」+ Clay 凹陷 Tab 栏，当前激活「模型/方法」
- 对应 dart 文件: `lib/features/global_model/widgets/top_frame_widget.dart`
- 当前数据状态: 静态，activeIndex 硬编码为 1
- 硬编码值:
  - 标题: `'全局知识'`
  - Tab 列表: `['知识点', '模型/方法', '高考卷子']`
  - 路由映射: `['/global-knowledge', null, '/global-exam']`（当前页 activeIndex=1）
- 对应数据模型: 无（纯导航组件）
- 需要的 API 字段: 无

---

### model-tree

![model-tree](../flutter截图验证/global-model/components/model-tree__390x844.png)

- 功能说明: 二级可折叠模型树（分类→模型项），带掌握等级色标和掌握计数
- 对应 dart 文件: `lib/features/global_model/widgets/model_tree_widget.dart`
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 分类: `受力分析模型(level:4, 4/5)`, `运动学模型(level:3, 2/4)`, `能量守恒模型(level:1, 1/3)`, `电磁学模型(level:0, 0/3)`
  - 模型项示例: `整体法与隔离法(5)`, `板块运动(2)`, `追及相遇(1)`, `功能关系(0)`
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
| `/api/global/model-tree` | GET | 获取模型/方法树 | `List<TreeNode>` |

## 接入示例

```dart
// 获取模型树
final resp = await api.get('/api/global/model-tree');
final tree = (resp.data as List)
    .map((e) => TreeNode.fromJson(e))
    .toList();

ModelTreeWidget(tree: tree);
```

## 页面跳转

- Tab「知识点」→ `/global-knowledge`
- Tab「高考卷子」→ `/global-exam`
- 模型项行点击 → `/model-detail`
