import 'dart:io';
import 'dart:ui' as ui;

import 'package:echomind_app/app/app_router.dart';
import 'package:echomind_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const outputDir = r'D:\AI\AI+high school homework\EchoMind-AI_Error_Tracker'
      r'\docs\第五阶段_前后端对接与UI分支合并\22个flutter页面的截图_纯UI改动版';

  const pages = [
    ('/', '04_home_page'),
    ('/profile', '05_profile_page'),
    ('/community', '06_community_page'),
    ('/knowledge-learning', '07_knowledge_learning_page'),
    ('/knowledge-detail', '08_knowledge_detail_page'),
    ('/global-knowledge', '09_global_knowledge_page'),
    ('/ai-diagnosis', '10_ai_diagnosis_page'),
    ('/prediction-center', '11_prediction_center_page'),
    ('/model-training', '12_model_training_page'),
    ('/model-detail', '13_model_detail_page'),
    ('/global-model', '14_global_model_page'),
    ('/global-exam', '15_global_exam_page'),
    ('/question-detail', '16_question_detail_page'),
    ('/question-aggregate', '17_question_aggregate_page'),
    ('/flashcard-review', '18_flashcard_review_page'),
    ('/weekly-review', '19_weekly_review_page'),
    ('/memory', '20_memory_page'),
    ('/upload-menu', '21_upload_menu_page'),
    ('/upload-history', '22_upload_history_page'),
  ];

  Future<void> pumpFrames(WidgetTester tester, {int frames = 15}) async {
    for (int i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> saveScreenshot(WidgetTester tester, String name) async {
    final renderView = tester.binding.renderViews.first;
    final layer = renderView.debugLayer! as OffsetLayer;
    final image = await layer.toImage(renderView.paintBounds);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$outputDir/$name.png').writeAsBytesSync(byteData!.buffer.asUint8List());
    image.dispose();
    debugPrint('Saved: $name.png');
  }

  setUpAll(() {
    Directory(outputDir).createSync(recursive: true);
  });

  testWidgets('Batch screenshot pure UI pages 04-22', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const EchoMindApp());
    await pumpFrames(tester, frames: 20);

    for (final (route, name) in pages) {
      appRouter.go(route);
      await pumpFrames(tester);
      await saveScreenshot(tester, name);
    }
  });
}
