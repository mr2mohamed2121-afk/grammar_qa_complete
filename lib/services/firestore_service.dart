import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/questions/models/question_model.dart';
import '../features/quiz/models/quiz_result_model.dart';
import '../features/auth/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== Users ====================

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return UserModel.fromJson(data);
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  Future<void> updateUserScore(String userId, int score) async {
    final docRef = _firestore.collection('users').doc(userId);
    final doc = await docRef.get();

    if (doc.exists) {
      final currentData = doc.data() ?? {};
      await docRef.update({
        'totalScore': ((currentData['totalScore'] ?? 0) as num) + score,
      });
    }
  }

  // ==================== Questions ====================

  Future<List<QuestionModel>> getQuestions({
    String? category,
    String? difficulty,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('questions');

    // ✅ نبحث بالقيمة اللي جاية (عربي أو إنجليزي)
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (difficulty != null && difficulty.isNotEmpty) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }
    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => QuestionModel.fromFirestore(doc))
        .toList();
  }

  // ✅ دالة جديدة: جيب كل التصنيفات المتاحة (عربي)
  Future<List<String>> getCategories() async {
    final snapshot = await _firestore.collection('questions').get();
    final categories = snapshot.docs
        .map((doc) => doc.data()['category'] as String?)
        .where((c) => c != null)
        .toSet()
        .cast<String>()
        .toList();
    return categories;
  }

  // ✅ دالة جديدة: جيب كل مستويات الصعوبة المتاحة (عربي)
  Future<List<String>> getDifficulties() async {
    final snapshot = await _firestore.collection('questions').get();
    final difficulties = snapshot.docs
        .map((doc) => doc.data()['difficulty'] as String?)
        .where((d) => d != null)
        .toSet()
        .cast<String>()
        .toList();
    return difficulties;
  }

  Future<void> addQuestion(QuestionModel question) async {
    await _firestore.collection('questions').add(question.toMap());
  }

  Future<void> updateQuestion(String id, QuestionModel question) async {
    await _firestore.collection('questions').doc(id).update(question.toMap());
  }

  Future<void> deleteQuestion(String id) async {
    await _firestore.collection('questions').doc(id).delete();
  }

  // ==================== Quiz Results ====================

  Future<void> saveQuizResult(QuizResultModel result) async {
    await _firestore.collection('quiz_results').add(result.toMap());
  }

  Future<List<QuizResultModel>> getUserResults(String userId) async {
    final snapshot = await _firestore
        .collection('quiz_results')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => QuizResultModel.fromFirestore(doc))
        .toList();
  }

  // ==================== Leaderboard ====================

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('leaderboard')
        .orderBy('totalScore', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> updateLeaderboard(String userId, String displayName, int score) async {
    final docRef = _firestore.collection('leaderboard').doc(userId);
    final doc = await docRef.get();

    if (doc.exists) {
      final currentData = doc.data() ?? {};
      await docRef.update({
        'totalScore': ((currentData['totalScore'] ?? 0) as num) + score,
        'quizzesCompleted': ((currentData['quizzesCompleted'] ?? 0) as num) + 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.set({
        'displayName': displayName,
        'totalScore': score,
        'quizzesCompleted': 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  // ==================== Admin ====================

  Future<List<Map<String, dynamic>>> adminGetAllUsers({int limit = 100}) async {
    final snapshot = await _firestore
        .collection('users')
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<Map<String, dynamic>> adminGetStats() async {
    final usersCount = await _firestore.collection('users').count().get();
    final questionsCount = await _firestore.collection('questions').count().get();
    final resultsCount = await _firestore.collection('quiz_results').count().get();

    return {
      'totalUsers': usersCount.count,
      'totalQuestions': questionsCount.count,
      'totalQuizzes': resultsCount.count,
    };
  }

  // ==================== Levels ====================

  Future<List<Map<String, dynamic>>> getLevels() async {
    final snapshot = await _firestore.collection('levels').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}