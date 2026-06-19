import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/questions/models/question_model.dart';
import '../features/auth/models/user_model.dart';
import '../features/quiz/models/quiz_result.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!..['id'] = doc.id);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Questions
  Future<List<Question>> getQuestions({
    String? category,
    DifficultyLevel? difficulty,
    int limit = 50,
  }) async {
    Query query = _firestore.collection('questions')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty.name);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => 
      Question.fromJson(doc.data() as Map<String, dynamic>..['id'] = doc.id)
    ).toList();
  }

  Future<Question?> getQuestion(String questionId) async {
    final doc = await _firestore.collection('questions').doc(questionId).get();
    if (!doc.exists) return null;
    return Question.fromJson(doc.data()!..['id'] = doc.id);
  }

  // Quiz Results
  Future<void> saveQuizResult(QuizResult result) async {
    await _firestore.collection('quiz_results').doc(result.id).set(result.toJson());
  }

  Future<List<QuizResult>> getUserQuizResults(String userId, {int limit = 50}) async {
    final snapshot = await _firestore.collection('quiz_results')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => 
      QuizResult.fromJson(doc.data() as Map<String, dynamic>..['id'] = doc.id)
    ).toList();
  }

  // Flashcards
  Future<void> saveFlashcard(String userId, Map<String, dynamic> flashcard) async {
    await _firestore.collection('flashcards').add({
      ...flashcard,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserFlashcards(String userId) async {
    final snapshot = await _firestore.collection('flashcards')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    }).toList();
  }

  // Categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  // User Points
  Future<Map<String, dynamic>?> getUserPoints(String userId) async {
    final doc = await _firestore.collection('user_points').doc(userId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  // Leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    final snapshot = await _firestore.collection('leaderboard')
        .orderBy('totalScore', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.asMap().entries.map((entry) => {
      'rank': entry.key + 1,
      'id': entry.value.id,
      ...entry.value.data(),
    }).toList();
  }

  // Achievements
  Future<List<Map<String, dynamic>>> getUserAchievements(String userId) async {
    final snapshot = await _firestore.collection('achievements')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  // Admin: Get all users
  Future<List<Map<String, dynamic>>> adminGetAllUsers({int limit = 50}) async {
    final snapshot = await _firestore.collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  // Admin: Get stats
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
}