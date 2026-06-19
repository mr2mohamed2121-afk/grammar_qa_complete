class QuizResult {
  final String id;
  final String userId;
  final String questionId;
  final bool isCorrect;
  final DateTime timestamp;

  QuizResult({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.isCorrect,
    required this.timestamp,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      questionId: json['questionId'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'questionId': questionId,
      'isCorrect': isCorrect,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}