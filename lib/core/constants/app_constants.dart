
class AppConstants {
  // App Info
  static const String appName = 'Grammar QA';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String questionsCollection = 'questions';
  static const String quizResultsCollection = 'quiz_results';
  static const String categoriesCollection = 'categories';
  static const String leaderboardCollection = 'leaderboard';
  static const String flashcardsCollection = 'flashcards';
  static const String achievementsCollection = 'achievements';
  static const String userPointsCollection = 'user_points';
  static const String subscriptionsCollection = 'subscriptions';
  static const String paymentsCollection = 'payments';
  static const String adminLogsCollection = 'admin_logs';

  // Cache Keys
  static const String questionsCacheKey = 'cached_questions';
  static const String categoriesCacheKey = 'cached_categories';
  static const String leaderboardCacheKey = 'cached_leaderboard';

  // Cache Durations
  static const int questionsCacheDurationHours = 24;
  static const int leaderboardCacheDurationHours = 1;

  // Ad Limits
  static const int dailyAdLimit = 10;
  static const int pointsPerRewardedAd = 30;
  static const int tripleAdMultiplier = 3;

  // Free Tier Limits
  static const int freeCardLimit = 50;

  // Premium Plans
  static const Map<String, Map<String, dynamic>> premiumPlans = {
    'monthly': {
      'name': 'Monthly Premium',
      'priceUSD': 4.99,
      'priceEGP': 150,
      'duration': 'month',
    },
    'yearly': {
      'name': 'Yearly Premium',
      'priceUSD': 49.99,
      'priceEGP': 1500,
      'duration': 'year',
      'savePercent': 17,
    },
  };

  // Card Packs
  static const Map<String, Map<String, dynamic>> cardPacks = {
    'cards_50': {
      'name': '50 Cards Pack',
      'priceUSD': 1.99,
      'priceEGP': 60,
      'cardCount': 50,
    },
    'cards_100': {
      'name': '100 Cards Pack',
      'priceUSD': 3.49,
      'priceEGP': 105,
      'cardCount': 100,
    },
  };

  // Reward Tiers
  static const Map<String, Map<String, dynamic>> rewardTiers = {
    '5_flashcards': {
      'points': 100,
      'value': 0.50,
      'description': 'Unlock 5 new flashcards',
    },
    'remove_ads_day': {
      'points': 500,
      'value': 1.00,
      'description': 'Remove ads for 1 day',
    },
    'premium_month': {
      'points': 1000,
      'value': 4.99,
      'description': '1 month Premium free',
    },
    'premium_year': {
      'points': 5000,
      'value': 49.99,
      'description': '1 year Premium free',
    },
    'unlimited_cards': {
      'points': 10000,
      'value': 99.99,
      'description': 'Unlimited cards forever',
    },
  };

  // Ad Points
  static const Map<String, int> adPoints = {
    'banner': 5,
    'interstitial': 15,
    'rewarded': 30,
    'native': 10,
  };

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double cardElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
