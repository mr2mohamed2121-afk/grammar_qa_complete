
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LocalStorageService {
  final SharedPreferences _prefs;
  late Box<dynamic> _cacheBox;

  LocalStorageService(this._prefs);

  Future<void> init() async {
    _cacheBox = await Hive.openBox('app_cache');
  }

  // ==================== AUTH ====================

  Future<void> saveAuthToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  String? getAuthToken() {
    return _prefs.getString('auth_token');
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove('auth_token');
  }

  Future<void> saveUserId(String userId) async {
    await _prefs.setString('user_id', userId);
  }

  String? getUserId() {
    return _prefs.getString('user_id');
  }

  Future<void> clearUserId() async {
    await _prefs.remove('user_id');
  }

  Future<void> setIsAdmin(bool isAdmin) async {
    await _prefs.setBool('is_admin', isAdmin);
  }

  bool? getIsAdmin() {
    return _prefs.getBool('is_admin');
  }

  // ==================== USER DATA ====================

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString('user_data', jsonEncode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final data = _prefs.getString('user_data');
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> clearUserData() async {
    await _prefs.remove('user_data');
  }

  // ==================== PREMIUM STATUS ====================

  Future<void> setPremiumStatus(bool isPremium) async {
    await _prefs.setBool('is_premium', isPremium);
  }

  bool getPremiumStatus() {
    return _prefs.getBool('is_premium') ?? false;
  }

  Future<void> setPremiumExpiry(DateTime expiry) async {
    await _prefs.setString('premium_expiry', expiry.toIso8601String());
  }

  DateTime? getPremiumExpiry() {
    final expiry = _prefs.getString('premium_expiry');
    if (expiry == null) return null;
    return DateTime.parse(expiry);
  }

  bool isPremiumValid() {
    final expiry = getPremiumExpiry();
    if (expiry == null) return getPremiumStatus();
    return DateTime.now().isBefore(expiry);
  }

  // ==================== POINTS ====================

  Future<void> savePoints(int points) async {
    await _prefs.setInt('user_points', points);
  }

  int getPoints() {
    return _prefs.getInt('user_points') ?? 0;
  }

  Future<void> addPoints(int points) async {
    final current = getPoints();
    await savePoints(current + points);
  }

  // ==================== STREAK ====================

  Future<void> saveStreak(int streak) async {
    await _prefs.setInt('streak_days', streak);
  }

  int getStreak() {
    return _prefs.getInt('streak_days') ?? 0;
  }

  Future<void> saveLastStudyDate(DateTime date) async {
    await _prefs.setString('last_study', date.toIso8601String());
  }

  DateTime? getLastStudyDate() {
    final date = _prefs.getString('last_study');
    if (date == null) return null;
    return DateTime.parse(date);
  }

  // ==================== CACHE (HIVE) ====================

  Future<void> cacheQuestions(List<Map<String, dynamic>> questions) async {
    await _cacheBox.put('cached_questions', jsonEncode(questions));
    await _cacheBox.put('questions_cache_time', DateTime.now().toIso8601String());
  }

  List<Map<String, dynamic>>? getCachedQuestions() {
    final data = _cacheBox.get('cached_questions');
    if (data == null) return null;

    // Check cache validity (24 hours)
    final cacheTime = _cacheBox.get('questions_cache_time');
    if (cacheTime != null) {
      final parsed = DateTime.parse(cacheTime);
      if (DateTime.now().difference(parsed).inHours > 24) {
        return null; // Cache expired
      }
    }

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> cacheCategories(List<Map<String, dynamic>> categories) async {
    await _cacheBox.put('cached_categories', jsonEncode(categories));
  }

  List<Map<String, dynamic>>? getCachedCategories() {
    final data = _cacheBox.get('cached_categories');
    if (data == null) return null;
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> cacheLeaderboard(List<Map<String, dynamic>> leaderboard) async {
    await _cacheBox.put('cached_leaderboard', jsonEncode(leaderboard));
    await _cacheBox.put('leaderboard_cache_time', DateTime.now().toIso8601String());
  }

  List<Map<String, dynamic>>? getCachedLeaderboard() {
    final data = _cacheBox.get('cached_leaderboard');
    if (data == null) return null;

    // Check cache validity (1 hour)
    final cacheTime = _cacheBox.get('leaderboard_cache_time');
    if (cacheTime != null) {
      final parsed = DateTime.parse(cacheTime);
      if (DateTime.now().difference(parsed).inHours > 1) {
        return null;
      }
    }

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  // ==================== SETTINGS ====================

  Future<void> setDailyAdCount(int count) async {
    await _prefs.setInt('daily_ad_count', count);
  }

  int getDailyAdCount() {
    return _prefs.getInt('daily_ad_count') ?? 0;
  }

  Future<void> setLastAdResetDate(DateTime date) async {
    await _prefs.setString('last_ad_reset', date.toIso8601String());
  }

  DateTime? getLastAdResetDate() {
    final date = _prefs.getString('last_ad_reset');
    if (date == null) return null;
    return DateTime.parse(date);
  }

  bool shouldResetAdCount() {
    final lastReset = getLastAdResetDate();
    if (lastReset == null) return true;

    final now = DateTime.now();
    return now.day != lastReset.day || now.month != lastReset.month || now.year != lastReset.year;
  }

  Future<void> resetDailyAdCount() async {
    await setDailyAdCount(0);
    await setLastAdResetDate(DateTime.now());
  }

  // ==================== QUIZ HISTORY ====================

  Future<void> saveQuizHistory(Map<String, dynamic> result) async {
    final history = getQuizHistory();
    history.add(result);

    // Keep only last 50 results
    if (history.length > 50) {
      history.removeAt(0);
    }

    await _prefs.setString('quiz_history', jsonEncode(history));
  }

  List<Map<String, dynamic>> getQuizHistory() {
    final data = _prefs.getString('quiz_history');
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  // ==================== CLEAR ALL ====================

  Future<void> clearAll() async {
    await _prefs.clear();
    await _cacheBox.clear();
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }
}
