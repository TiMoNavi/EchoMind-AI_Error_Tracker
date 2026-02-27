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

  final outputDir =
      r'D:\AI\AI+high school homework\EchoMind-AI_Error_Tracker\docs\第五阶段_前后端对接与UI分支合并\21个flutter页面的截图';

  setUp(() async {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    SharedPreferences.setMockInitialValues({'auth_token': 'test_token'});
  });

  Future<void> screenshot(WidgetTester tester, String name) async {
    // Use pump with fixed duration instead of pumpAndSettle
    // because ClayBackgroundBlobs has infinite animations
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final renderObject = tester.binding.renderViews.first;
    final layer = renderObject.debugLayer! as OffsetLayer;
    final image = await layer.toImage(renderObject.paintBounds);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    File('$outputDir/$name.png')
        .writeAsBytesSync(byteData!.buffer.asUint8List());
    image.dispose();
  }

  const simplePages = [
    ('/', '01_home'),
    ('/global-knowledge', '02_global_knowledge'),
    ('/memory', '03_memory'),
    ('/community', '04_community'),
    ('/profile', '05_profile'),
    ('/global-model', '06_global_model'),
    ('/global-exam', '07_global_exam'),
    ('/ai-diagnosis', '08_ai_diagnosis'),
    ('/flashcard-review', '09_flashcard_review'),
    ('/prediction-center', '14_prediction_center'),
    ('/question-aggregate', '15_question_aggregate'),
    ('/upload-history', '17_upload_history'),
    ('/upload-menu', '18_upload_menu'),
    ('/weekly-review', '19_weekly_review'),
    ('/register-strategy', '20_register_strategy'),
    ('/login', '21_login'),
  ];

  const paramPages = [
    ('/knowledge-detail/demo_kp', '10_knowledge_detail'),
    ('/knowledge-learning?kpId=demo_kp&source=self_study', '11_knowledge_learning'),
    ('/model-detail/demo_model', '12_model_detail'),
    ('/model-training?modelId=demo_model&source=self_study', '13_model_training'),
    ('/question-detail/demo_q', '16_question_detail'),
  ];

  testWidgets('Screenshot all pages', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          title: 'EchoMind',
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
    // Let the first frame render (don't use pumpAndSettle — infinite anims)
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final allPages = [...simplePages, ...paramPages];
    for (final (route, name) in allPages) {
      try {
        appRouter.go(route);
        for (int i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await screenshot(tester, name);
      } catch (e) {
        // Log but don't fail — continue to next page
        debugPrint('SKIP $name: $e');
      }
    }
  });
}
