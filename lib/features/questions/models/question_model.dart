class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  final String? category;
  final DifficultyLevel? difficulty;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    this.category,
    this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      explanation: json['explanation'],
      category: json['category'],
      difficulty: json['difficulty'] != null 
          ? DifficultyLevel.values.firstWhere(
              (e) => e.name == json['difficulty'],
              orElse: () => DifficultyLevel.easy,
            )
          : null,
    );
  }
}

enum DifficultyLevel {
  easy,
  medium,
  hard,
}