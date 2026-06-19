
import 'package:equatable/equatable.dart';

enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInBlank,
  matching,
}

enum DifficultyLevel {
  easy,
  medium,
  hard,
}

class Question extends Equatable {
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

  const Question({
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

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.toString() == 'QuestionType.${json['type']}',
        orElse: () => QuestionType.multipleChoice,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString() == 'DifficultyLevel.${json['difficulty']}',
        orElse: () => DifficultyLevel.easy,
      ),
      category: json['category'] as String,
      explanation: json['explanation'] as String?,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'type': type.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'category': category,
      'explanation': explanation,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
    id, questionText, type, difficulty, category,
    explanation, options, correctAnswerIndex, imageUrl, isActive,
  ];
}

class QuizResult extends Equatable {
  final String id;
  final String userId;
  final String category;
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final DateTime completedAt;
  final List<QuestionAnswer> answers;

  const QuizResult({
    required this.id,
    required this.userId,
    required this.category,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.completedAt,
    required this.answers,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] as String,
      userId: json['userId'] as String,
      category: json['category'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      score: json['score'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      answers: (json['answers'] as List)
          .map((e) => QuestionAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'score': score,
      'completedAt': completedAt.toIso8601String(),
      'answers': answers.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id, userId, category, totalQuestions, correctAnswers, score, completedAt,
  ];
}

class QuestionAnswer extends Equatable {
  final String questionId;
  final int selectedAnswer;
  final bool isCorrect;
  final int timeSpent; // in seconds

  const QuestionAnswer({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.timeSpent,
  });

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(
      questionId: json['questionId'] as String,
      selectedAnswer: json['selectedAnswer'] as int,
      isCorrect: json['isCorrect'] as bool,
      timeSpent: json['timeSpent'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
    };
  }

  @override
  List<Object?> get props => [questionId, selectedAnswer, isCorrect, timeSpent];
}
