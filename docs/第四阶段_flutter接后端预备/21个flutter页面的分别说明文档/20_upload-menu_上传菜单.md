# upload-menu（上传菜单）

## 当前状态
第四阶段：Claymorphism 美化完成，后端预备就绪。数据模型已创建，三态组件（Loading/Error/Empty）已就绪。

## 路由标识
`/upload-menu`

## 组件树
```
UploadMenuPage (Scaffold, StatefulWidget)
├── _buildTopBar()                    ← 返回按钮 + 标题"上传错题"
└── Expanded
    └── SingleChildScrollView
        ├── _buildModeSwitch()        ← 拍照上传/文本输入 切换栏
        ├── _buildPhotoUpload()       ← 拍照上传区域（mode=0）
        ├── _buildTextUpload()        ← 文本输入区域（mode=1）
        ├── _buildSubjectSelector()   ← 科目选择器
        └── _buildSubmitButton()      ← 提交诊断按钮
```

## 页面截图
![upload-menu-390x844](../flutter截图验证/upload-menu/full/upload-menu__390x844__full.png)

---

## 组件详情

### TopBar（内联方法）
![top_frame_widget](../flutter截图验证/upload-menu/components/top_frame_widget__390x844.png)
- 功能说明: 顶部导航栏，包含返回按钮和页面标题"上传错题"
- 对应 dart 文件: `lib/features/upload_menu/upload_menu_page.dart`（`_buildTopBar()` 方法）
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 标题文字: `'上传错题'`
- 对应数据模型: 无独立模型
- 需要的 API 字段: 无（纯静态标题）

---

### ModeSwitch（内联方法）
![main_content_widget](../flutter截图验证/upload-menu/components/main_content_widget__390x844.png)
- 功能说明: 拍照上传/文本输入模式切换栏，Claymorphism 内凹容器 + 选中态凸起白色胶囊
- 对应 dart 文件: `lib/features/upload_menu/upload_menu_page.dart`（`_buildModeSwitch()` 方法）
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 模式标签: `['拍照上传', '文本输入']`
- 对应数据模型: 无独立模型（纯 UI 切换）
- 需要的 API 字段: 无

---

### PhotoUpload / TextUpload（内联方法）
- 功能说明: 拍照上传区域显示相机图标和提示文字；文本输入区域包含题目内容输入框和答案输入框
- 对应 dart 文件: `lib/features/upload_menu/upload_menu_page.dart`（`_buildPhotoUpload()` / `_buildTextUpload()` 方法）
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 拍照提示: `'点击拍照或从相册选择'`, `'支持 JPG / PNG，最多 5 张'`
  - 文本输入提示: `'粘贴或输入题目内容...'`, `'输入你的作答...'`
- 对应数据模型: 无独立模型
- 需要的 API 字段: 无（用户输入内容）

---

### SubjectSelector（内联方法）
- 功能说明: 科目选择器，Wrap 布局的胶囊按钮组，选中态为紫色渐变背景
- 对应 dart 文件: `lib/features/upload_menu/upload_menu_page.dart`（`_buildSubjectSelector()` 方法）
- 当前数据状态: 硬编码 mock
- 硬编码值:
  - 科目列表: `['物理', '数学', '化学', '生物', '英语']`
  - 默认选中: `'物理'`
- 对应数据模型: 无独立模型
- 需要的 API 字段:
  - `subjects` (List&lt;String&gt;) — 可选科目列表（可从用户配置获取）

---

### SubmitButton（内联方法）
- 功能说明: 提交诊断按钮，渐变紫色背景，上传中显示 CircularProgressIndicator，成功后弹出对话框
- 对应 dart 文件: `lib/features/upload_menu/upload_menu_page.dart`（`_buildSubmitButton()` 方法）
- 当前数据状态: 硬编码 mock（模拟 2 秒延迟上传）
- 硬编码值:
  - 按钮文字: `'提交诊断'`
  - 成功对话框: `'上传成功'`, `'错题已提交，AI 将在后台进行诊断分析。'`
- 对应数据模型: 无独立模型
- 需要的 API 字段: 无（提交动作）

---

## 数据模型

无独立数据模型。本页为纯导航/操作页面，所有 UI 逻辑内联在 `upload_menu_page.dart` 中。

> **备注**: `widgets/top_frame_widget.dart` 和 `widgets/main_content_widget.dart` 均为 `Placeholder` 占位组件，实际 UI 全部在页面文件的内联方法中实现。

## API 接口清单
| 接口 | 方法 | 用途 | 返回模型 |
|------|------|------|----------|
| `/api/upload/photo` | POST | 上传拍照错题图片 | `{ id, status }` |
| `/api/upload/text` | POST | 上传文本错题内容 | `{ id, status }` |
| `/api/user/subjects` | GET | 获取用户可选科目列表 | `List<String>` |

## 接入示例

```dart
// 1. 提交拍照上传
void _onSubmit() async {
  setState(() => _uploading = true);
  try {
    if (_mode == 0) {
      await api.uploadPhoto(
        images: _selectedImages,
        subject: _selectedSubject,
      );
    } else {
      await api.uploadText(
        content: _textController.text,
        answer: _answerController.text,
        subject: _selectedSubject,
      );
    }
    _showSuccessDialog();
  } finally {
    setState(() => _uploading = false);
  }
}
```

## 页面跳转
- 返回按钮 → `context.pop()`（返回上一页）
- 成功对话框"返回首页" → `context.pop()`
