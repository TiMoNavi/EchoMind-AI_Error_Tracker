import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/features/auth/login_page.dart';
import 'package:echomind_app/features/auth/register_page.dart';
import 'package:echomind_app/features/home/home_page.dart';
import 'package:echomind_app/features/community/community_page.dart';
import 'package:echomind_app/features/memory/memory_page.dart';
import 'package:echomind_app/features/profile/profile_page.dart';
import 'package:echomind_app/features/global_knowledge/global_knowledge_page.dart';
import 'package:echomind_app/features/global_model/global_model_page.dart';
import 'package:echomind_app/features/global_exam/global_exam_page.dart';
import 'package:echomind_app/features/ai_diagnosis/ai_diagnosis_page.dart';
import 'package:echomind_app/features/flashcard_review/flashcard_review_page.dart';
import 'package:echomind_app/features/knowledge_detail/knowledge_detail_page.dart';
import 'package:echomind_app/features/knowledge_learning/knowledge_learning_page.dart';
import 'package:echomind_app/features/model_detail/model_detail_page.dart';
import 'package:echomind_app/features/model_training/model_training_page.dart';
import 'package:echomind_app/features/prediction_center/prediction_center_page.dart';
import 'package:echomind_app/features/question_aggregate/question_aggregate_page.dart';
import 'package:echomind_app/features/question_detail/question_detail_page.dart';
import 'package:echomind_app/features/upload_history/upload_history_page.dart';
import 'package:echomind_app/features/upload_menu/upload_menu_page.dart';
import 'package:echomind_app/features/weekly_review/weekly_review_page.dart';
import 'package:echomind_app/features/register_strategy/register_strategy_page.dart';

const _authRoutes = {AppRoutes.login, AppRoutes.register};

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  redirect: (BuildContext context, GoRouterState state) async {
    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.getString('auth_token') != null;
    final isAuthRoute = _authRoutes.contains(state.matchedLocation);
    if (!hasToken && !isAuthRoute) return AppRoutes.login;
    if (hasToken && isAuthRoute) return AppRoutes.home;
    return null;
  },
  routes: [
    // Auth pages
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
    GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterPage()),
    // 5 tab pages
    GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
    GoRoute(path: AppRoutes.globalKnowledge, builder: (_, __) => const GlobalKnowledgePage()),
    GoRoute(path: AppRoutes.memory, builder: (_, __) => const MemoryPage()),
    GoRoute(path: AppRoutes.community, builder: (_, __) => const CommunityPage()),
    GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfilePage()),
    // Detail & sub pages
    GoRoute(path: AppRoutes.globalModel, builder: (_, __) => const GlobalModelPage()),
    GoRoute(path: AppRoutes.globalExam, builder: (_, __) => const GlobalExamPage()),
    GoRoute(path: AppRoutes.aiDiagnosis, builder: (_, state) {
      final questionId = state.uri.queryParameters['questionId'];
      return AiDiagnosisPage(questionId: questionId);
    }),
    GoRoute(path: AppRoutes.flashcardReview, builder: (_, __) => const FlashcardReviewPage()),
    GoRoute(path: AppRoutes.knowledgeDetail, builder: (_, state) => KnowledgeDetailPage(kpId: state.pathParameters['id']!)),
    GoRoute(
      path: AppRoutes.knowledgeLearning,
      builder: (_, state) => KnowledgeLearningPage(
        knowledgePointId: state.uri.queryParameters['kpId'] ?? '',
        source: state.uri.queryParameters['source'] ?? 'self_study',
      ),
    ),
    GoRoute(path: AppRoutes.modelDetail, builder: (_, state) => ModelDetailPage(modelId: state.pathParameters['id']!)),
    GoRoute(path: AppRoutes.modelTraining, builder: (_, state) {
      final modelId = state.uri.queryParameters['modelId'];
      final source = state.uri.queryParameters['source'] ?? 'self_study';
      final questionId = state.uri.queryParameters['questionId'];
      return ModelTrainingPage(modelId: modelId, source: source, questionId: questionId);
    }),
    GoRoute(path: AppRoutes.predictionCenter, builder: (_, __) => const PredictionCenterPage()),
    GoRoute(path: AppRoutes.questionAggregate, builder: (_, __) => const QuestionAggregatePage()),
    GoRoute(path: AppRoutes.questionDetail, builder: (_, state) => QuestionDetailPage(questionId: state.pathParameters['id']!)),
    GoRoute(path: AppRoutes.uploadHistory, builder: (_, __) => const UploadHistoryPage()),
    GoRoute(path: AppRoutes.uploadMenu, builder: (_, __) => const UploadMenuPage()),
    GoRoute(path: AppRoutes.weeklyReview, builder: (_, __) => const WeeklyReviewPage()),
    GoRoute(path: AppRoutes.registerStrategy, builder: (_, __) => const RegisterStrategyPage()),
  ],
);
