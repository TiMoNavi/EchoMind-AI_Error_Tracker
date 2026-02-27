# Flutter 页面自动截图操作文档

## 概述

使用 Flutter Integration Test 对 EchoMind 全部 22 个页面进行自动化截图。测试启动时先调用真实登录 API 获取合法 JWT token，注入 SharedPreferences，使所有页面的后端请求都携带有效凭证，避免 "Invalid token" 错误。

## 前置条件

- Flutter SDK（已配置 Windows desktop 支持）
- 项目依赖已安装（`flutter pub get`）
- 后端服务可达（`http://8.130.16.212:8001`）
- 有效的测试账号（当前配置在测试文件常量中）

## 运行命令

```bash
cd echomind_app
flutter test integration_test/screenshot_22_pages_test.dart -d windows
```

## 截图输出目录

```
docs/第五阶段_前后端对接与UI分支合并/22个flutter页面的截图_接入后端版flutter/
```

## 22 个页面清单

| 编号 | 文件名 | 页面 | 路由 |
|------|--------|------|------|
| 01 | 01_login_page.png | 登录页 | `/login` |
| 02 | 02_register_page.png | 注册页 | `/register` |
| 03 | 03_register_strategy_page.png | 注册策略页 | `/register-strategy` |
| 04 | 04_home_page.png | 首页 | `/` |
| 05 | 05_profile_page.png | 个人中心 | `/profile` |
| 06 | 06_community_page.png | 社区 | `/community` |
| 07 | 07_knowledge_learning_page.png | 知识点学习 | `/knowledge-learning?kpId=demo&source=self_study` |
| 08 | 08_knowledge_detail_page.png | 知识点详情 | `/knowledge-detail/demo` |
| 09 | 09_global_knowledge_page.png | 全局知识库 | `/global-knowledge` |
| 10 | 10_ai_diagnosis_page.png | AI 诊断 | `/ai-diagnosis` |
| 11 | 11_prediction_center_page.png | 预测中心 | `/prediction-center` |
| 12 | 12_model_training_page.png | 模型训练 | `/model-training?modelId=demo&source=self_study` |
| 13 | 13_model_detail_page.png | 模型详情 | `/model-detail/demo` |
| 14 | 14_global_model_page.png | 全局模型 | `/global-model` |
| 15 | 15_global_exam_page.png | 全局考试 | `/global-exam` |
| 16 | 16_question_detail_page.png | 题目详情 | `/question-detail/demo` |
| 17 | 17_question_aggregate_page.png | 题目聚合 | `/question-aggregate` |
| 18 | 18_flashcard_review_page.png | 闪卡复习 | `/flashcard-review` |
| 19 | 19_weekly_review_page.png | 周报回顾 | `/weekly-review` |
| 20 | 20_memory_page.png | 记忆库 | `/memory` |
| 21 | 21_upload_menu_page.png | 上传菜单 | `/upload-menu` |
| 22 | 22_upload_history_page.png | 上传历史 | `/upload-history` |

## 技术要点

### 1. 无限动画处理

项目中 `ClayBackgroundBlobs` 组件包含无限循环动画，导致 `pumpAndSettle()` 永远不会返回。解决方案是用固定次数的 `pump` 循环替代：

```dart
// ✗ 会超时
await tester.pumpAndSettle();

// ✓ 正确做法：固定帧数等待
for (int i = 0; i < 15; i++) {
  await tester.pump(const Duration(milliseconds: 100));
}
```

### 2. 真实登录获取 Token（关键改进）

之前的方案用假 token（`'test_screenshot'`）绕过路由守卫，但页面内的 API 请求会被后端拒绝（"Invalid token"）。

当前方案：测试启动时先用 Dio 调用真实登录接口，获取合法 JWT，再注入 SharedPreferences：

```dart
// 第一步：调用真实登录 API
Future<String> _fetchRealToken() async {
  final dio = Dio(BaseOptions(baseUrl: 'http://8.130.16.212:8001/api'));
  final res = await dio.post('/auth/login', data: {
    'phone': '18222830713',
    'password': 'yanbaojie00000',
  });
  return (res.data as Map<String, dynamic>)['access_token'] as String;
}

// 第二步：注入真实 token
final realToken = await _fetchRealToken();
SharedPreferences.setMockInitialValues({'auth_token': realToken});
```

这样 `ApiClient` 的 `_AuthInterceptor` 读取到的是真实 JWT，所有页面的后端请求都能正常通过认证。

未登录态的页面（登录页、注册页）仍使用空 mock：

```dart
SharedPreferences.setMockInitialValues({});
```

### 3. 更换测试账号

如需更换账号，修改测试文件顶部的两个常量即可：

```dart
const _loginPhone = '18222830713';
const _loginPassword = 'yanbaojie00000';
```

### 3. 截图实现原理

```dart
final renderView = tester.binding.renderViews.first;
final layer = renderView.debugLayer! as OffsetLayer;
final image = await layer.toImage(renderView.paintBounds);
final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
File('path/name.png').writeAsBytesSync(byteData!.buffer.asUint8List());
```

核心流程：获取渲染树根节点 → 转为 OffsetLayer → 导出为 Image → 编码为 PNG 字节 → 写入文件。

### 4. 视口设置

统一使用 iPhone 14 尺寸（390×844），devicePixelRatio 设为 1.0 以获得 1:1 像素输出：

```dart
tester.view.physicalSize = const Size(390, 844);
tester.view.devicePixelRatio = 1.0;
```

## 测试文件位置

```
echomind_app/integration_test/screenshot_22_pages_test.dart
```

## 常见问题

**Q: 运行报错 `pumpAndSettle timed out`？**
A: 项目有无限动画组件，必须使用 `pump` 循环而非 `pumpAndSettle`。

**Q: 截图是空白或黑屏？**
A: 增加 `pump` 的循环次数（如从 15 增加到 30），给页面更多渲染时间。

**Q: 需要带参数的页面怎么截图？**
A: 直接在路由中传入 demo 参数，如 `/knowledge-detail/demo`、`/model-training?modelId=demo&source=self_study`。

**Q: 页面显示 "Invalid token" 错误？**
A: 说明使用了假 token。确保测试文件中使用了 `_fetchRealToken()` 获取真实 JWT，而非硬编码假 token。同时确认后端服务可达、账号密码正确。

**Q: 登录接口报错 "连接超时"？**
A: 检查网络是否能访问 `http://8.130.16.212:8001`，以及后端服务是否正常运行。

**Q: Token 过期了怎么办？**
A: 每次运行测试都会重新调用登录 API 获取新 token，无需手动处理过期问题。
