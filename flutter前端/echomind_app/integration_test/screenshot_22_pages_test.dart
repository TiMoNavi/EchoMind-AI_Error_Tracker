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

/// EchoMind 22 个页面自动截图
///
/// 运行: cd "flutter前端/echomind_app"
///       flutter test integration_test/screenshot_22_pages_test.dart -d windows
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final outputDir = r'D:\AI\AI+high school homework\EchoMind-AI_Error_Tracker'
      r'\docs\第五阶段_前后端对接与UI分支合并\21个flutter页面的截图';

  Future<void> snap(WidgetTester tester, String name) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    final v = tester.binding.renderViews.first;
    final layer = v.debugLayer! as OffsetLayer;
    final img = await layer.toImage(v.paintBounds);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    File('$outputDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    img.dispose();
    debugPrint('OK $name.png');
  }

  Widget app() => ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        ),
      );

  void viewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
  }

  setUp(() => Directory(outputDir).createSync(recursive: true));

  // ── 认证页面（无 token）──────────────────────────

  testWidgets('01 登录页', (tester) async {
    SharedPreferences.setMockInitialValues({});
    viewport(tester);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await snap(tester, '01_login_page');
  });

  testWidgets('02 注册页', (tester) async {
    SharedPreferences.setMockInitialValues({});
    viewport(tester);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    appRouter.go('/register');
    await tester.pumpAndSettle();
    await snap(tester, '02_register_page');
  });

  // ── 需登录态的 20 个页面 ─────────────────────────

  testWidgets('03-22 批量截图', (tester) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'test_screenshot'});
    viewport(tester);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    const pages = [
      ('/register-strategy',        '03_register_strategy_page'),
      ('/',                          '04_home_page'),
      ('/profile',                   '05_profile_page'),
      ('/community',                 '06_community_page'),
      ('/knowledge-learning?kpId=demo&source=self_study',
                                     '07_knowledge_learning_page'),
      ('/knowledge-detail/demo',     '08_knowledge_detail_page'),
      ('/global-knowledge',          '09_global_knowledge_page'),
      ('/ai-diagnosis',              '10_ai_diagnosis_page'),
      ('/prediction-center',         '11_prediction_center_page'),
      ('/model-training?modelId=demo&source=self_study',
                                     '12_model_training_page'),
      ('/model-detail/demo',         '13_model_detail_page'),
      ('/global-model',              '14_global_model_page'),
      ('/global-exam',               '15_global_exam_page'),
      ('/question-detail/demo',      '16_question_detail_page'),
      ('/question-aggregate',        '17_question_aggregate_page'),
      ('/flashcard-review',          '18_flashcard_review_page'),
      ('/weekly-review',             '19_weekly_review_page'),
      ('/memory',                    '20_memory_page'),
      ('/upload-menu',               '21_upload_menu_page'),
      ('/upload-history',            '22_upload_history_page'),
    ];

    for (final (route, name) in pages) {
      appRouter.go(route);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await snap(tester, name);
    }
  });
}
