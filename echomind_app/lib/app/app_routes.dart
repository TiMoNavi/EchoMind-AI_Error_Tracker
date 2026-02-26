/// All named route paths for the app.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String community = '/community';
  static const String memory = '/memory';
  static const String profile = '/profile';
  static const String globalKnowledge = '/global-knowledge';
  static const String globalModel = '/global-model';
  static const String globalExam = '/global-exam';
  static const String aiDiagnosis = '/ai-diagnosis';
  static const String flashcardReview = '/flashcard-review';
  static const String knowledgeDetail = '/knowledge-detail/:id';
  static const String knowledgeLearning = '/knowledge-learning';
  static const String modelDetail = '/model-detail/:id';
  static const String modelTraining = '/model-training';
  static const String predictionCenter = '/prediction-center';
  static const String questionAggregate = '/question-aggregate';
  static const String questionDetail = '/question-detail/:id';
  static const String uploadHistory = '/upload-history';
  static const String uploadMenu = '/upload-menu';
  static const String weeklyReview = '/weekly-review';
  static const String registerStrategy = '/register-strategy';
  static const String login = '/login';
  static const String register = '/register';

  // 路径生成辅助方法
  static String knowledgeDetailPath(String id) => '/knowledge-detail/$id';
  static String modelDetailPath(String id) => '/model-detail/$id';
  static String questionDetailPath(String id) => '/question-detail/$id';
  static String aiDiagnosisPath({String? questionId}) =>
      questionId != null ? '/ai-diagnosis?questionId=$questionId' : '/ai-diagnosis';
  static String modelTrainingPath({
    required String modelId,
    String source = 'self_study',
    String? questionId,
  }) {
    final params = <String>['modelId=$modelId', 'source=$source'];
    if (questionId != null) params.add('questionId=$questionId');
    return '/model-training?${params.join('&')}';
  }
}
