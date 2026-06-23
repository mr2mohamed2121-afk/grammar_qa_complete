import 'package:equatable/equatable.dart';
import 'question_entity.dart';

class QuizEntity extends Equatable {
  final String id;
  final String title;
  final List<QuestionEntity> questions;
  final int? userScore;
  final bool? isPassed;

  const QuizEntity({
    required this.id,
    required this.title,
    required this.questions,
    this.userScore,
    this.isPassed,
  });

  QuizEntity copyWith({
    String? id,
    String? title,
    List<QuestionEntity>? questions,
    int? userScore,
    bool? isPassed,
  }) {
    return QuizEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      questions: questions ?? this.questions,
      userScore: userScore ?? this.userScore,
      isPassed: isPassed ?? this.isPassed,
    );
  }

  @override
  List<Object?> get props => [id, title, questions, userScore, isPassed];
}