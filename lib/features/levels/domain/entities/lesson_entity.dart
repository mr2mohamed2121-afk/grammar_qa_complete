import 'package:equatable/equatable.dart';

class LessonEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String videoUrl;
  final int duration;
  final int points;
  final String quizId;
  final bool isCompleted;

  const LessonEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.videoUrl,
    required this.duration,
    required this.points,
    required this.quizId,
    this.isCompleted = false,
  });

  LessonEntity copyWith({
    String? id,
    String? title,
    String? content,
    String? videoUrl,
    int? duration,
    int? points,
    String? quizId,
    bool? isCompleted,
  }) {
    return LessonEntity(
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

  @override
  List<Object?> get props => [id, title, content, videoUrl, duration, points, quizId, isCompleted];
}