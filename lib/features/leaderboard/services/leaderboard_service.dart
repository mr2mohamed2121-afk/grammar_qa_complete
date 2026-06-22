import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/leaderboard_model.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _leaderboardRef => _firestore.collection('leaderboard');

  Stream<List<LeaderboardEntry>> getTopPlayers({int limit = 50}) {
    return _leaderboardRef
        .orderBy('totalScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaderboardEntry.fromFirestore(doc))
            .toList());
  }

  Future<void> updateUserScore(int quizScore, int totalQuestions) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _leaderboardRef.doc(user.uid);
    final doc = await docRef.get();

    if (doc.exists) {
      final current = LeaderboardEntry.fromFirestore(doc);
      final newTotalQuizzes = current.totalQuizzes + 1;
      final newTotalScore = current.totalScore + quizScore;
      final newAverage = newTotalScore / newTotalQuizzes;
      final newBest = quizScore > current.bestScore ? quizScore : current.bestScore;

      await docRef.update({
        'totalScore': newTotalScore,
        'totalQuizzes': newTotalQuizzes,
        'averageScore': newAverage,
        'bestScore': newBest,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      });
    } else {
      await docRef.set({
        'userName': user.displayName ?? user.email?.split('@')[0] ?? 'مستخدم',
        'userPhotoUrl': user.photoURL,
        'totalScore': quizScore,
        'totalQuizzes': 1,
        'averageScore': quizScore.toDouble(),
        'bestScore': quizScore,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  Future<int?> getCurrentUserRank() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final allDocs = await _leaderboardRef
        .orderBy('totalScore', descending: true)
        .get();

    for (int i = 0; i < allDocs.docs.length; i++) {
      if (allDocs.docs[i].id == user.uid) {
        return i + 1;
      }
    }
    return null;
  }
}