
import 'package:equatable/equatable.dart';

enum QuestionType { multipleChoice, trueFalse, fillInBlank, matching }
enum DifficultyLevel { easy, medium, hard }

class QuestionEntity extends Equatable {
  final String id;
  final String questionText;
  final QuestionType type;
  final DifficultyLevel difficulty;
  final String category;
  final String? explanation;
  final List<String> options;
  final int correctAnswerIndex;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isActive;

  const QuestionEntity({
    required this.id,
    required this.questionText,
    required this.type,
    required this.difficulty,
    required this.category,
    this.explanation,
    required this.options,
    required this.correctAnswerIndex,
    this.imageUrl,
    required this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id, questionText, type, difficulty, category,
    explanation, options, correctAnswerIndex, imageUrl, isActive,
  ];
}

class QuizResultEntity extends Equatable {
  final String id;
  final String userId;
  final String category;
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final DateTime completedAt;
  final List<QuestionAnswerEntity> answers;

  const QuizResultEntity({
    required this.id,
    required this.userId,
    required this.category,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.completedAt,
    required this.answers,
  });

  @override
  List<Object?> get props => [
    id, userId, category, totalQuestions, correctAnswers, score, completedAt,
  ];
}

class QuestionAnswerEntity extends Equatable {
  final String questionId;
  final int selectedAnswer;
  final bool isCorrect;
  final int timeSpent;

  const QuestionAnswerEntity({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.timeSpent,
  });

  @override
  List<Object?> get props => [questionId, selectedAnswer, isCorrect, timeSpent];
}
