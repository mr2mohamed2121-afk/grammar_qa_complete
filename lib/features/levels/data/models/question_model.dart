import '../../domain/entities/question_entity.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.type,
    required super.question,
    required super.options,
    required super.correct,
    required super.explanation,
    super.userAnswer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int,
      type: json['type'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List<dynamic>),
      correct: json['correct'] as int,
      explanation: json['explanation'] as String,
      userAnswer: json['user_answer'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'question': question,
      'options': options,
      'correct': correct,
      'explanation': explanation,
      'user_answer': userAnswer,
    };
  }

  QuestionModel copyWithModel({
    int? id,
    String? type,
    String? question,
    List<String>? options,
    int? correct,
    String? explanation,
    int? userAnswer,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
      correct: correct ?? this.correct,
      explanation: explanation ?? this.explanation,
      userAnswer: userAnswer ?? this.userAnswer,
    );
  }
}