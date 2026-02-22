import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/features/knowledge_detail/widgets/top_frame_widget.dart';
import 'package:echomind_app/features/knowledge_detail/widgets/mastery_dashboard_widget.dart';
import 'package:echomind_app/features/knowledge_detail/widgets/concept_test_records_widget.dart';
import 'package:echomind_app/features/knowledge_detail/widgets/related_models_widget.dart';

class KnowledgeDetailPage extends StatelessWidget {
  final String kpId;
  const KnowledgeDetailPage({super.key, required this.kpId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            TopFrameWidget(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 24),
                children: [
                  MasteryDashboardWidget(kpId: kpId),
                  SizedBox(height: 20),
                  ConceptTestRecordsWidget(),
                  SizedBox(height: 20),
                  RelatedModelsWidget(kpId: kpId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
