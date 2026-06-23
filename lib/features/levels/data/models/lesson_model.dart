import '../../domain/entities/lesson_entity.dart';

class LessonModel extends LessonEntity {
  const LessonModel({
    required super.id,
    required super.title,
    required super.content,
    required super.videoUrl,
    required super.duration,
    required super.points,
    required super.quizId,
    super.isCompleted,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      videoUrl: json['video_url'] as String? ?? '',
      duration: json['duration'] as int,
      points: json['points'] as int,
      quizId: json['quiz_id'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'video_url': videoUrl,
      'duration': duration,
      'points': points,
      'quiz_id': quizId,
      'is_completed': isCompleted,
    };
  }

  LessonModel copyWithModel({
    String? id,
    String? title,
    String? content,
    String? videoUrl,
    int? duration,
    int? points,
    String? quizId,
    bool? isCompleted,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      points: points ?? this.points,
      quizId: quizId ?? this.quizId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}