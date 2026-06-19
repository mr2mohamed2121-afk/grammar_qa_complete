
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../core/services/local_storage_service.dart';
import '../features/auth/domain/entities/user_entity.dart';

@lazySingleton
class PremiumAdLogic {
  final LocalStorageService _localStorage;

  PremiumAdLogic(this._localStorage);

  // Check if user should see ads
  bool shouldShowAds(UserEntity? user) {
    // No user = show ads (not logged in)
    if (user == null) return true;

    // Premium users = no ads
    if (user.isPremium) return false;

    // Check if premium expired
    if (user.premiumExpiresAt != null) {
      if (DateTime.now().isAfter(user.premiumExpiresAt!)) {
        // Premium expired, show ads
        return true;
      }
    }

    // Check local premium status
    final localPremium = _localStorage.isPremiumValid();
    if (localPremium) return false;

    // Default: show ads for non-premium
    return true;
  }

  // Check if user can watch rewarded ads (for points)
  bool canWatchRewardedAd(UserEntity? user) {
    if (user == null) return false;

    // Check daily limit
    if (_localStorage.shouldResetAdCount()) {
      _localStorage.resetDailyAdCount();
    }

    final dailyCount = _localStorage.getDailyAdCount();
    return dailyCount < 10; // Daily limit: 10 ads
  }

  // Increment ad count
  Future<void> incrementAdCount() async {
    final current = _localStorage.getDailyAdCount();
    await _localStorage.setDailyAdCount(current + 1);
  }

  // Get remaining ad count
  int getRemainingAdCount() {
    if (_localStorage.shouldResetAdCount()) {
      _localStorage.resetDailyAdCount();
    }
    return 10 - _localStorage.getDailyAdCount();
  }

  // Check if user has unlimited cards
  bool hasUnlimitedCards(UserEntity? user) {
    if (user == null) return false;
    if (user.isPremium) return true;
    return false;
  }

  // Check if user can add more cards
  bool canAddCard(UserEntity? user, int currentCardCount) {
    if (hasUnlimitedCards(user)) return true;
    return currentCardCount < 50; // Free limit: 50 cards
  }

  // Get max cards for user
  int getMaxCards(UserEntity? user) {
    if (hasUnlimitedCards(user)) return -1; // Unlimited
    return 50;
  }

  // Show premium dialog if needed
  void showPremiumDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✨ Upgrade to Premium'),
        content: Text(
          'Upgrade to Premium to unlock $feature and enjoy unlimited access!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to premium screen
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}
