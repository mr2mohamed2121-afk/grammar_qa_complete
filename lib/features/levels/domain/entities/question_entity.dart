import 'package:equatable/equatable.dart';

class QuestionEntity extends Equatable {
  final int id;
  final String type;
  final String question;
  final List<String> options;
  final int correct;
  final String explanation;
  final int? userAnswer;

  const QuestionEntity({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correct,
    required this.explanation,
    this.userAnswer,
  });

  QuestionEntity copyWith({
    int? id,
    String? type,
    String? question,
    List<String>? options,
    int? correct,
    String? explanation,
    int? userAnswer,
  }) {
    return QuestionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
      correct: correct ?? this.correct,
      explanation: explanation ?? this.explanation,
      userAnswer: userAnswer ?? this.userAnswer,
    );
  }

  @override
  List<Object?> get props => [id, type, question, options, correct, explanation, userAnswer];
}