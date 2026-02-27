import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echomind_app/app/app_router.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const outputDir =
      r'D:\AI\AI+high school homework\EchoMind-AI_Error_Tracker\docs\第五阶段_前后端对接与UI分支合并\21个flutter页面的截图';

  setUp(() async {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  });

  Future<void> waitForRender(WidgetTester tester, {int frames = 15}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> snap(WidgetTester tester, String name) async {
    await waitForRender(tester);
    final renderView = tester.binding.renderViews.first;
    final layer = renderView.debugLayer! as OffsetLayer;
    final image = await layer.toImage(renderView.paintBounds);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$outputDir/$name.png')
        .writeAsBytesSync(byteData!.buffer.asUint8List());
    image.dispose();
    debugPrint('saved: $name.png');
  }

  void setViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
  }

  Widget buildApp() {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'EchoMind',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  testWidgets('01 login page', (tester) async {
    SharedPreferences.setMockInitialValues({});
    setViewport(tester);
    await tester.pumpWidget(buildApp());
    await waitForRender(tester, frames: 20);
    await snap(tester, '01_login_page');
  });

  testWidgets('02 register page', (tester) async {
    SharedPreferences.setMockInitialValues({});
    setViewport(tester);
    await tester.pumpWidget(buildApp());
    await waitForRender(tester, frames: 15);
    appRouter.go('/register');
    await waitForRender(tester, frames: 20);
    await snap(tester, '02_register_page');
  });

  testWidgets('03-22 protected pages', (tester) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'test_token'});
    setViewport(tester);
    await tester.pumpWidget(buildApp());
    await waitForRender(tester, frames: 20);

    const pages = [
      ('/register-strategy', '03_register_strategy_page'),
      ('/', '04_home_page'),
      ('/profile', '05_profile_page'),
      ('/community', '06_community_page'),
      (
        '/knowledge-learning?kpId=demo&source=self_study',
        '07_knowledge_learning_page'
      ),
      ('/knowledge-detail/demo', '08_knowledge_detail_page'),
      ('/global-knowledge', '09_global_knowledge_page'),
      ('/ai-diagnosis', '10_ai_diagnosis_page'),
      ('/prediction-center', '11_prediction_center_page'),
      (
        '/model-training?modelId=demo&source=self_study',
        '12_model_training_page'
      ),
      ('/model-detail/demo', '13_model_detail_page'),
      ('/global-model', '14_global_model_page'),
      ('/global-exam', '15_global_exam_page'),
      ('/question-detail/demo', '16_question_detail_page'),
      ('/question-aggregate', '17_question_aggregate_page'),
      ('/flashcard-review', '18_flashcard_review_page'),
      ('/weekly-review', '19_weekly_review_page'),
      ('/memory', '20_memory_page'),
      ('/upload-menu', '21_upload_menu_page'),
      ('/upload-history', '22_upload_history_page'),
    ];

    for (final (route, name) in pages) {
      try {
        appRouter.go(route);
        await waitForRender(tester, frames: 15);
        await snap(tester, name);
      } catch (e) {
        debugPrint('skip $name: $e');
      }
    }
  });
}
