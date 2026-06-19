
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../core/services/local_storage_service.dart';

@lazySingleton
class OfflineQuizCache {
  late Box<dynamic> _quizBox;
  late Box<dynamic> _progressBox;

  OfflineQuizCache() {
    _initBoxes();
  }

  Future<void> _initBoxes() async {
    _quizBox = await Hive.openBox('offline_quiz');
    _progressBox = await Hive.openBox('offline_progress');
  }

  // Cache questions for offline use
  Future<void> cacheQuestionsForCategory(
    String category, 
    List<Map<String, dynamic>> questions,
  ) async {
    final key = 'questions_$category';
    await _quizBox.put(key, jsonEncode(questions));
    await _quizBox.put('${key}_timestamp', DateTime.now().toIso8601String());
  }

  // Get cached questions
  List<Map<String, dynamic>>? getCachedQuestions(String category) {
    final key = 'questions_$category';
    final data = _quizBox.get(key);
    if (data == null) return null;

    // Check if cache is fresh (less than 7 days)
    final timestamp = _quizBox.get('${key}_timestamp');
    if (timestamp != null) {
      final cacheDate = DateTime.parse(timestamp);
      if (DateTime.now().difference(cacheDate).inDays > 7) {
        return null; // Cache expired
      }
    }

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  // Cache all categories for offline
  Future<void> cacheAllCategories(List<Map<String, dynamic>> categories) async {
    await _quizBox.put('categories', jsonEncode(categories));
  }

  List<Map<String, dynamic>>? getCachedCategories() {
    final data = _quizBox.get('categories');
    if (data == null) return null;
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  // Save offline quiz progress
  Future<void> saveOfflineProgress({
    required String userId,
    required String quizId,
    required List<Map<String, dynamic>> answers,
    required int score,
  }) async {
    final key = 'progress_${userId}_$quizId';
    await _progressBox.put(key, jsonEncode({
      'userId': userId,
      'quizId': quizId,
      'answers': answers,
      'score': score,
      'completedAt': DateTime.now().toIso8601String(),
      'synced': false,
    }));
  }

  // Get unsynced progress
  List<Map<String, dynamic>> getUnsyncedProgress(String userId) {
    final results = <Map<String, dynamic>>[];

    for (final key in _progressBox.keys) {
      if (key.toString().startsWith('progress_$userId')) {
        final data = jsonDecode(_progressBox.get(key));
        if (data['synced'] == false) {
          results.add(data);
        }
      }
    }

    return results;
  }

  // Mark progress as synced
  Future<void> markAsSynced(String userId, String quizId) async {
    final key = 'progress_${userId}_$quizId';
    final data = jsonDecode(_progressBox.get(key));
    data['synced'] = true;
    await _progressBox.put(key, jsonEncode(data));
  }

  // Cache user stats for offline
  Future<void> cacheUserStats(String userId, Map<String, dynamic> stats) async {
    await _progressBox.put('stats_$userId', jsonEncode(stats));
  }

  Map<String, dynamic>? getCachedUserStats(String userId) {
    final data = _progressBox.get('stats_$userId');
    if (data == null) return null;
    return jsonDecode(data);
  }

  // Clear old cache
  Future<void> clearOldCache() async {
    final now = DateTime.now();

    for (final key in _quizBox.keys) {
      if (key.toString().endsWith('_timestamp')) {
        final timestamp = _quizBox.get(key);
        if (timestamp != null) {
          final date = DateTime.parse(timestamp);
          if (now.difference(date).inDays > 30) {
            // Remove old cache
            final baseKey = key.toString().replaceAll('_timestamp', '');
            await _quizBox.delete(baseKey);
            await _quizBox.delete(key);
          }
        }
      }
    }
  }

  // Check if offline mode available
  bool isOfflineModeAvailable(String category) {
    return getCachedQuestions(category) != null;
  }

  // Get total cached questions count
  int getTotalCachedQuestions() {
    int count = 0;
    for (final key in _quizBox.keys) {
      if (key.toString().startsWith('questions_') && !key.toString().endsWith('_timestamp')) {
        final data = _quizBox.get(key);
        if (data != null) {
          final List<dynamic> decoded = jsonDecode(data);
          count += decoded.length;
        }
      }
    }
    return count;
  }
}
