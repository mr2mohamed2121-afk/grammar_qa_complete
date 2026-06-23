import 'package:equatable/equatable.dart';
import 'lesson_entity.dart';
import 'quiz_entity.dart';

class LevelEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final int requiredPoints;
  final String icon;
  final String color;
  final List<LessonEntity> lessons;
  final QuizEntity quiz;
  final bool isUnlocked;
  final double progress;

  const LevelEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredPoints,
    required this.icon,
    required this.color,
    required this.lessons,
    required this.quiz,
    this.isUnlocked = false,
    this.progress = 0.0,
  });

  LevelEntity copyWith({
    int? id,
    String? title,
    String? description,
    int? requiredPoints,
    String? icon,
    String? color,
    List<LessonEntity>? lessons,
    QuizEntity? quiz,
    bool? isUnlocked,
    double? progress,
  }) {
    return LevelEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      lessons: lessons ?? this.lessons,
      quiz: quiz ?? this.quiz,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
        id, title, description, requiredPoints, icon, color,
        lessons, quiz, isUnlocked, progress,
      ];
}