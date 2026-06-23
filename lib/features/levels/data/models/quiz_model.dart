import '../../domain/entities/quiz_entity.dart';
import 'question_model.dart';

class QuizModel extends QuizEntity {
  const QuizModel({
    required super.id,
    required super.title,
    required super.questions,
    super.userScore,
    super.isPassed,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String,
      title: json['title'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      userScore: json['user_score'] as int?,
      isPassed: json['is_passed'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'questions': questions.map((e) => (e as QuestionModel).toJson()).toList(),
      'user_score': userScore,
      'is_passed': isPassed,
    };
  }

  QuizModel copyWithModel({
    String? id,
    String? title,
    List<QuestionModel>? questions,
    int? userScore,
    bool? isPassed,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      questions: questions ?? this.questions.cast<QuestionModel>(),
      userScore: userScore ?? this.userScore,
      isPassed: isPassed ?? this.isPassed,
    );
  }
}