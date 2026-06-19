
import 'package:injectable/injectable.dart';
import '../core/services/local_storage_service.dart';

@lazySingleton
class AdaptiveLearningService {
  final LocalStorageService _localStorage;

  AdaptiveLearningService(this._localStorage);

  // Analyze user performance and adjust difficulty
  Future<AdaptiveLevel> analyzeUserLevel(String userId, List<QuizResult> results) async {
    if (results.isEmpty) return AdaptiveLevel.beginner;

    // Calculate accuracy for each difficulty
    final easyAccuracy = _calculateAccuracyForDifficulty(results, 'easy');
    final mediumAccuracy = _calculateAccuracyForDifficulty(results, 'medium');
    final hardAccuracy = _calculateAccuracyForDifficulty(results, 'hard');

    // Determine adaptive level
    if (hardAccuracy > 0.8) {
      return AdaptiveLevel.advanced;
    } else if (mediumAccuracy > 0.7) {
      return AdaptiveLevel.intermediate;
    } else if (easyAccuracy > 0.6) {
      return AdaptiveLevel.beginner;
    } else {
      return AdaptiveLevel.newbie;
    }
  }

  double _calculateAccuracyForDifficulty(List<QuizResult> results, String difficulty) {
    final filtered = results.where((r) => r.difficulty == difficulty).toList();
    if (filtered.isEmpty) return 0.0;

    final totalCorrect = filtered.fold<int>(0, (sum, r) => sum + r.correctAnswers);
    final totalQuestions = filtered.fold<int>(0, (sum, r) => sum + r.totalQuestions);

    return totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0;
  }

  // Get recommended difficulty for next quiz
  String getRecommendedDifficulty(AdaptiveLevel level) {
    switch (level) {
      case AdaptiveLevel.newbie:
        return 'easy';
      case AdaptiveLevel.beginner:
        return 'easy'; // 70% easy, 30% medium
      case AdaptiveLevel.intermediate:
        return 'medium'; // 50% medium, 30% easy, 20% hard
      case AdaptiveLevel.advanced:
        return 'hard'; // 60% hard, 40% medium
    }
  }

  // Generate adaptive question mix
  List<QuestionDifficulty> generateAdaptiveMix(AdaptiveLevel level, int totalQuestions) {
    final mix = <QuestionDifficulty>[];

    switch (level) {
      case AdaptiveLevel.newbie:
        // 100% easy
        for (var i = 0; i < totalQuestions; i++) {
          mix.add(QuestionDifficulty.easy);
        }
        break;

      case AdaptiveLevel.beginner:
        // 70% easy, 30% medium
        for (var i = 0; i < totalQuestions; i++) {
          mix.add(i < totalQuestions * 0.7 ? QuestionDifficulty.easy : QuestionDifficulty.medium);
        }
        break;

      case AdaptiveLevel.intermediate:
        // 50% medium, 30% easy, 20% hard
        for (var i = 0; i < totalQuestions; i++) {
          if (i < totalQuestions * 0.3) {
            mix.add(QuestionDifficulty.easy);
          } else if (i < totalQuestions * 0.8) {
            mix.add(QuestionDifficulty.medium);
          } else {
            mix.add(QuestionDifficulty.hard);
          }
        }
        break;

      case AdaptiveLevel.advanced:
        // 60% hard, 40% medium
        for (var i = 0; i < totalQuestions; i++) {
          mix.add(i < totalQuestions * 0.6 ? QuestionDifficulty.hard : QuestionDifficulty.medium);
        }
        break;
    }

    return mix;
  }

  // Track weak areas for focused practice
  Future<void> trackWeakArea(String userId, String category, String questionType, bool isCorrect) async {
    final key = 'weak_areas_$userId';
    final data = _localStorage.getUserData() ?? {};

    if (!data.containsKey(key)) {
      data[key] = {};
    }

    final weakAreas = data[key] as Map<String, dynamic>;
    final categoryKey = '${category}_$questionType';

    if (!weakAreas.containsKey(categoryKey)) {
      weakAreas[categoryKey] = {'correct': 0, 'total': 0};
    }

    weakAreas[categoryKey]['total'] = (weakAreas[categoryKey]['total'] as int) + 1;
    if (isCorrect) {
      weakAreas[categoryKey]['correct'] = (weakAreas[categoryKey]['correct'] as int) + 1;
    }

    data[key] = weakAreas;
    await _localStorage.saveUserData(data);
  }

  // Get weak areas for focused practice
  List<String> getWeakAreas(String userId) {
    final data = _localStorage.getUserData();
    if (data == null) return [];

    final key = 'weak_areas_$userId';
    final weakAreas = data[key] as Map<String, dynamic>?;
    if (weakAreas == null) return [];

    // Sort by accuracy (ascending) - weakest first
    final sorted = weakAreas.entries.toList()
      ..sort((a, b) {
        final aAccuracy = (a.value['correct'] as int) / (a.value['total'] as int);
        final bAccuracy = (b.value['correct'] as int) / (b.value['total'] as int);
        return aAccuracy.compareTo(bAccuracy);
      });

    return sorted.map((e) => e.key).toList();
  }

  // Generate personalized study plan
  StudyPlan generateStudyPlan(String userId, List<QuizResult> results) {
    final weakAreas = getWeakAreas(userId);
    final level = analyzeUserLevel(userId, results);

    return StudyPlan(
      level: level,
      weakAreas: weakAreas.take(5).toList(), // Top 5 weak areas
      recommendedDailyQuestions: _getRecommendedDailyQuestions(level),
      focusCategories: weakAreas.map((area) => area.split('_')[0]).toSet().toList(),
    );
  }

  int _getRecommendedDailyQuestions(AdaptiveLevel level) {
    switch (level) {
      case AdaptiveLevel.newbie:
        return 10;
      case AdaptiveLevel.beginner:
        return 15;
      case AdaptiveLevel.intermediate:
        return 20;
      case AdaptiveLevel.advanced:
        return 25;
    }
  }
}

enum AdaptiveLevel { newbie, beginner, intermediate, advanced }
enum QuestionDifficulty { easy, medium, hard }

class QuizResult {
  final String difficulty;
  final int correctAnswers;
  final int totalQuestions;

  QuizResult({
    required this.difficulty,
    required this.correctAnswers,
    required this.totalQuestions,
  });
}

class StudyPlan {
  final AdaptiveLevel level;
  final List<String> weakAreas;
  final int recommendedDailyQuestions;
  final List<String> focusCategories;

  StudyPlan({
    required this.level,
    required this.weakAreas,
    required this.recommendedDailyQuestions,
    required this.focusCategories,
  });
}
