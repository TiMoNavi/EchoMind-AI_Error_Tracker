# Flutter 入门介绍（面向当前项目）

## 1. Flutter 是什么（先一句话）

- Flutter 是 Google 的跨平台 UI 框架：用一套代码开发 Android、iOS、Web、桌面应用。

## 2. 为什么你们这个项目适合 Flutter

- 你们是“页面很多 + 交互统一 + 需要安卓/iOS同时上线”的产品。
- 现在已有完整前端原型（页面结构清晰），非常适合迁移到 Flutter 页面组件。
- Flutter 在复杂 UI（卡片、树形、进度、聊天气泡）上表现稳定，UI 一致性高。

## 3. 你需要先懂的 6 个核心概念

1.`Dart`：Flutter 使用 Dart 语言，语法接近 JS/TS，前端转起来不难。

2.`Widget`：Flutter 一切都是 Widget（按钮、文本、页面、布局都算 Widget）。

3.`StatelessWidget / StatefulWidget`：前者纯展示，后者有状态变化（比如 Step 切换、Tab 切换、聊天输入）。

4.`Build 方法`：页面通过 `build()` 返回 Widget 树生成。

5.`路由（Navigation）`：相当于网页跳转，建议用 `go_router` 管理多页面。

6.`状态管理`：简单起步可用 `setState`，项目化推荐 `Riverpod`。

## 4. 对应你们项目的页面映射

1. 主导航 5 Tab：主页（`index`）、全局（知识点/模型/卷子）、记忆（闪卡）、社区、我的。
2. 业务主链路页面：题目详情、AI 诊断、模型训练（6步）、知识点学习（5步）、预测中心、题号聚合。
3. 当前缺页（建议优先补）：`upload-menu`、`register-strategy`。

## 5. 推荐技术栈（Flutter 版）

- 框架：`Flutter (stable)` + `Dart`
- 路由：`go_router`
- 状态管理：`flutter_riverpod`
- 网络请求：`dio`
- 数据模型：`freezed` + `json_serializable`（后期接后端再上也行）
- 本地存储：`shared_preferences`（轻量）或 `hive`（结构化）
- UI 规范：`ThemeData` + 统一设计 tokens（颜色、圆角、字号）

## 6. 建议目录结构（可直接照抄）

```text

lib/

  main.dart

  app/

    app.dart

    router.dart

    theme.dart

  features/

    home/

    global/

    question/

    diagnosis/

    model_training/

    knowledge_learning/

    memory/

    profile/

  shared/

    widgets/

    models/

    services/

```

## 7. 你可以这样开始（零基础最稳步骤）

1. 安装 Flutter SDK，执行 `flutter doctor`，先把环境全修到可用。
2. 新建项目：`flutter create ai_highschool_app`。
3. 先只做“静态页面迁移”，不接后端：先做 5 个底部 Tab 空页面，再做主链路（主页 -> 题目详情 -> AI诊断 -> 模型训练）。
4. 页面跑通后再接状态管理与假数据。
5. 最后再接真实接口。

## 8. 给你一个最小示例（先建立感觉）

```dart

import'package:flutter/material.dart';


voidmain() => runApp(constMyApp());


classMyAppextendsStatelessWidget {

  constMyApp({super.key});


  @override

  Widgetbuild(BuildContext context) {

    returnMaterialApp(

      title: 'AI高中',

      home: constHomePage(),

    );

  }

}


classHomePageextendsStatelessWidget {

  constHomePage({super.key});


  @override

  Widgetbuild(BuildContext context) {

    returnScaffold(

      appBar: AppBar(title: constText('主页')),

      body: constCenter(child: Text('今天开始 Flutter 迁移')),

    );

  }

}

```

## 9. 你当前最该关注的不是“炫技”，而是这三件事

1. 把页面结构和导航先搭起来（先有骨架）。
2. 把核心闭环先跑通（上传/题目 -> 诊断 -> 训练）。
3. 把可复用组件抽出来（Tab、卡片、等级、Step 进度、聊天气泡）。

## 10. 一句话结论

- Flutter 对你们这个“学生端为主、页面复杂、要多端上线”的项目是合适的。
- 你零基础也可以上手，先按页面迁移推进，不要一开始就陷入状态管理和架构细节。
