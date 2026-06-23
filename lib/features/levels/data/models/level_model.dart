import '../../domain/entities/level_entity.dart';
import 'lesson_model.dart';
import 'quiz_model.dart';

class LevelModel extends LevelEntity {
  const LevelModel({
    required super.id,
    required super.title,
    required super.description,
    required super.requiredPoints,
    required super.icon,
    required super.color,
    required super.lessons,
    required super.quiz,
    super.isUnlocked,
    super.progress,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      requiredPoints: json['required_points'] as int,
      icon: json['icon'] as String,
      color: json['color'] as String,
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      quiz: QuizModel.fromJson(json['quiz'] as Map<String, dynamic>),
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'required_points': requiredPoints,
      'icon': icon,
      'color': color,
      'lessons': lessons.map((e) => (e as LessonModel).toJson()).toList(),
      'quiz': (quiz as QuizModel).toJson(),
      'is_unlocked': isUnlocked,
      'progress': progress,
    };
  }

  LevelModel copyWithModel({
    int? id,
    String? title,
    String? description,
    int? requiredPoints,
    String? icon,
    String? color,
    List<LessonModel>? lessons,
    QuizModel? quiz,
    bool? isUnlocked,
    double? progress,
  }) {
    return LevelModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      lessons: lessons ?? this.lessons.cast<LessonModel>(),
      quiz: quiz ?? this.quiz as QuizModel,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
    );
  }
}