
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // Predefined events
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logQuizStart({
    required String category,
    required String difficulty,
  }) async {
    await _analytics.logEvent(
      name: 'quiz_start',
      parameters: {
        'category': category,
        'difficulty': difficulty,
      },
    );
  }

  Future<void> logQuizComplete({
    required String category,
    required int score,
    required int totalQuestions,
  }) async {
    await _analytics.logEvent(
      name: 'quiz_complete',
      parameters: {
        'category': category,
        'score': score,
        'total_questions': totalQuestions,
        'accuracy': (score / totalQuestions * 100).round(),
      },
    );
  }

  Future<void> logAdImpression({
    required String adType,
    required String adUnit,
  }) async {
    await _analytics.logEvent(
      name: 'ad_impression',
      parameters: {
        'ad_type': adType,
        'ad_unit': adUnit,
      },
    );
  }

  Future<void> logPurchase({
    required String productId,
    required double value,
    required String currency,
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      value: value,
      items: [AnalyticsEventItem(itemId: productId, itemName: productId)],
    );
  }

  Future<void> logPremiumUpgrade({
    required String plan,
    required double price,
  }) async {
    await _analytics.logEvent(
      name: 'premium_upgrade',
      parameters: {
        'plan': plan,
        'price': price,
      },
    );
  }

  Future<void> logShare({
    required String contentType,
    required String itemId,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
    );
  }

  Future<void> setUserProperties({
    required String userId,
    String? userType,
    bool? isPremium,
  }) async {
    await _analytics.setUserId(id: userId);
    if (userType != null) {
      await _analytics.setUserProperty(name: 'user_type', value: userType);
    }
    if (isPremium != null) {
      await _analytics.setUserProperty(
        name: 'is_premium',
        value: isPremium.toString(),
      );
    }
  }

  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }
}
