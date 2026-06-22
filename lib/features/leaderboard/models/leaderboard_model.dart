import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int totalScore;
  final int totalQuizzes;
  final double averageScore;
  final int bestScore;
  final DateTime lastUpdated;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.totalScore,
    required this.totalQuizzes,
    required this.averageScore,
    required this.bestScore,
    required this.lastUpdated,
  });

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      userId: doc.id,
      userName: data['userName'] ?? 'مستخدم مجهول',
      userPhotoUrl: data['userPhotoUrl'],
      totalScore: data['totalScore'] ?? 0,
      totalQuizzes: data['totalQuizzes'] ?? 0,
      averageScore: (data['averageScore'] ?? 0.0).toDouble(),
      bestScore: data['bestScore'] ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'totalScore': totalScore,
      'totalQuizzes': totalQuizzes,
      'averageScore': averageScore,
      'bestScore': bestScore,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}