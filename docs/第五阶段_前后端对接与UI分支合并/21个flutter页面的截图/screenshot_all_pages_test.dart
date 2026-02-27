import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:echomind_app/main.dart';
import 'package:echomind_app/app/app_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final outputDir =
      r'D:\AI\AI+high school homework\EchoMind-AI_Error_Tracker\docs\第二阶段_html转flutter\截图验证\all_pages';

  setUp(() {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);
  });

  Future<void> screenshot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    final renderObject = tester.binding.renderViews.first;
    final layer = renderObject.debugLayer! as OffsetLayer;
    final image = await layer.toImage(renderObject.paintBounds);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$outputDir/$name.png').writeAsBytesSync(byteData!.buffer.asUint8List());
    image.dispose();
  }

  const pages = [
    ('/', '01_home'),
    ('/global-knowledge', '02_global_knowledge'),
    ('/memory', '03_memory'),
    ('/community', '04_community'),
    ('/profile', '05_profile'),
    ('/global-model', '06_global_model'),
    ('/global-exam', '07_global_exam'),
    ('/ai-diagnosis', '08_ai_diagnosis'),
    ('/flashcard-review', '09_flashcard_review'),
    ('/knowledge-detail', '10_knowledge_detail'),
    ('/knowledge-learning', '11_knowledge_learning'),
    ('/model-detail', '12_model_detail'),
    ('/model-training', '13_model_training'),
    ('/prediction-center', '14_prediction_center'),
    ('/question-aggregate', '15_question_aggregate'),
    ('/question-detail', '16_question_detail'),
    ('/upload-history', '17_upload_history'),
    ('/upload-menu', '18_upload_menu'),
    ('/weekly-review', '19_weekly_review'),
    ('/register-strategy', '20_register_strategy'),
  ];

  testWidgets('Screenshot all 20 routes', (tester) async {
    // Constrain to mobile viewport 390x844
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const EchoMindApp());
    await tester.pumpAndSettle();

    for (final (route, name) in pages) {
      appRouter.go(route);
      await tester.pumpAndSettle();
      await screenshot(tester, name);
    }
  });
}
