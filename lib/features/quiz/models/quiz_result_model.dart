import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResultModel {
  final String? id;
  final String userId;
  final String userEmail;
  final int score;
  final int totalQuestions;
  final String category;
  final DateTime completedAt;

  QuizResultModel({
    this.id,
    required this.userId,
    required this.userEmail,
    required this.score,
    required this.totalQuestions,
    required this.category,
    required this.completedAt,
  });

  factory QuizResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return QuizResultModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      score: (data['score'] ?? 0) as int,
      totalQuestions: (data['totalQuestions'] ?? 0) as int,
      category: data['category'] ?? '',
      completedAt: (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'score': score,
      'totalQuestions': totalQuestions,
      'category': category,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  double get percentage => totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;
}