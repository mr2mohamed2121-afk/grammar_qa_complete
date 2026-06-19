
class ApiConstants {
  // Paymob API
  static const String paymobBaseUrl = 'https://accept.paymob.com/api';
  static const String paymobAuthEndpoint = '/auth/tokens';
  static const String paymobOrderEndpoint = '/ecommerce/orders';
  static const String paymobPaymentKeyEndpoint = '/acceptance/payment_keys';

  // Cloud Functions
  static const String awardAdPointsFunction = 'awardAdPoints';
  static const String redeemPointsFunction = 'redeemPoints';
  static const String updateStreakFunction = 'updateStreak';
  static const String checkStreakWarningFunction = 'checkStreakWarning';
  static const String getLeaderboardFunction = 'getLeaderboard';
  static const String getAdminStatsFunction = 'getAdminStats';
  static const String adminCreateQuestionFunction = 'adminCreateQuestion';
  static const String adminUpdateQuestionFunction = 'adminUpdateQuestion';
  static const String adminDeleteQuestionFunction = 'adminDeleteQuestion';
  static const String adminGetUsersFunction = 'adminGetUsers';
  static const String adminGetUserDetailsFunction = 'adminGetUserDetails';
  static const String adminTogglePremiumFunction = 'adminTogglePremium';
  static const String paymobWebhookFunction = 'paymobWebhook';
  static const String inAppPurchaseWebhookFunction = 'inAppPurchaseWebhook';

  // In-App Purchase Product IDs
  static const String premiumMonthlyProductId = 'premium_monthly';
  static const String premiumYearlyProductId = 'premium_yearly';
  static const String cards50ProductId = 'cards_50';
  static const String cards100ProductId = 'cards_100';

  static const Set<String> allProductIds = {
    premiumMonthlyProductId,
    premiumYearlyProductId,
    cards50ProductId,
    cards100ProductId,
  };

  // AdMob Test IDs
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String testNativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
}
