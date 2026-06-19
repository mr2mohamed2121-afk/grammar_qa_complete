
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Ad Unit IDs - Production (replace with your actual IDs)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx'; // Android Banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx'; // iOS Banner
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx'; // Android Interstitial
    } else if (Platform.isIOS) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx'; // iOS Interstitial
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx'; // Android Rewarded
    } else if (Platform.isIOS) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx'; // iOS Rewarded
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx'; // Android Native
    } else if (Platform.isIOS) {
      return 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx'; // iOS Native
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Test IDs for development
  static String get testBannerAdUnitId => 'ca-app-pub-3940256099942544/6300978111';
  static String get testInterstitialAdUnitId => 'ca-app-pub-3940256099942544/1033173712';
  static String get testRewardedAdUnitId => 'ca-app-pub-3940256099942544/5224354917';
  static String get testNativeAdUnitId => 'ca-app-pub-3940256099942544/2247696110';

  // Use test IDs in debug mode
  static bool get _isTestMode {
    bool isDebug = false;
    assert(isDebug = true);
    return isDebug;
  }

  static String get effectiveBannerAdUnitId => _isTestMode ? testBannerAdUnitId : bannerAdUnitId;
  static String get effectiveInterstitialAdUnitId => _isTestMode ? testInterstitialAdUnitId : interstitialAdUnitId;
  static String get effectiveRewardedAdUnitId => _isTestMode ? testRewardedAdUnitId : rewardedAdUnitId;
  static String get effectiveNativeAdUnitId => _isTestMode ? testNativeAdUnitId : nativeAdUnitId;

  // Initialize AdMob
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    debugPrint('✅ AdMob initialized successfully');
  }

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  void loadBannerAd({VoidCallback? onLoaded, VoidCallback? onFailed}) {
    _bannerAd = BannerAd(
      adUnitId: effectiveBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          debugPrint('✅ Banner Ad loaded');
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
          debugPrint('❌ Banner Ad failed: ${error.message}');
          onFailed?.call();
        },
      ),
    );
    _bannerAd!.load();
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  void loadInterstitialAd({VoidCallback? onLoaded, VoidCallback? onFailed}) {
    InterstitialAd.load(
      adUnitId: effectiveInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          debugPrint('✅ Interstitial Ad loaded');
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          debugPrint('❌ Interstitial Ad failed: ${error.message}');
          onFailed?.call();
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onDismissed, VoidCallback? onFailed}) {
    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialAdLoaded = false;
          onDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isInterstitialAdLoaded = false;
          onFailed?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      debugPrint('⚠️ Interstitial Ad not loaded yet');
      onFailed?.call();
    }
  }

  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdLoaded = false;
  }

  // Rewarded Ad
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;

  void loadRewardedAd({VoidCallback? onLoaded, VoidCallback? onFailed}) {
    RewardedAd.load(
      adUnitId: effectiveRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          debugPrint('✅ Rewarded Ad loaded');
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          debugPrint('❌ Rewarded Ad failed: ${error.message}');
          onFailed?.call();
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(int amount, String type) onRewarded,
    VoidCallback? onDismissed,
    VoidCallback? onFailed,
  }) {
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedAdLoaded = false;
          onDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isRewardedAdLoaded = false;
          onFailed?.call();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('🎁 User earned reward: ${reward.amount} ${reward.type}');
          onRewarded(reward.amount, reward.type);
        },
      );
    } else {
      debugPrint('⚠️ Rewarded Ad not loaded yet');
      onFailed?.call();
    }
  }

  void disposeRewardedAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdLoaded = false;
  }

  // Native Ad
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  void loadNativeAd({VoidCallback? onLoaded, VoidCallback? onFailed}) {
    _nativeAd = NativeAd(
      adUnitId: effectiveNativeAdUnitId,
      request: const AdRequest(),
      factoryId: 'nativeAdFactory',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _isNativeAdLoaded = true;
          debugPrint('✅ Native Ad loaded');
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          _isNativeAdLoaded = false;
          ad.dispose();
          debugPrint('❌ Native Ad failed: ${error.message}');
          onFailed?.call();
        },
      ),
    );
    _nativeAd!.load();
  }

  NativeAd? get nativeAd => _nativeAd;
  bool get isNativeAdLoaded => _isNativeAdLoaded;

  void disposeNativeAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _isNativeAdLoaded = false;
  }

  // Dispose all ads
  void disposeAllAds() {
    disposeBannerAd();
    disposeInterstitialAd();
    disposeRewardedAd();
    disposeNativeAd();
  }

  // Ad Frequency Control
  DateTime? _lastInterstitialShow;
  static const Duration _minInterstitialInterval = Duration(minutes: 3);

  bool canShowInterstitial() {
    if (_lastInterstitialShow == null) return true;
    return DateTime.now().difference(_lastInterstitialShow!) >= _minInterstitialInterval;
  }

  void markInterstitialShown() {
    _lastInterstitialShow = DateTime.now();
  }

  // Show interstitial with frequency control
  void showInterstitialWithFrequency({
    VoidCallback? onDismissed,
    VoidCallback? onFailed,
  }) {
    if (!canShowInterstitial()) {
      debugPrint('⏳ Interstitial frequency limit reached');
      onFailed?.call();
      return;
    }

    showInterstitialAd(
      onDismissed: () {
        markInterstitialShown();
        onDismissed?.call();
      },
      onFailed: onFailed,
    );
  }
}

// Ad Points Configuration
class AdPointsConfig {
  static const Map<String, int> adPoints = {
    'banner': 5,
    'interstitial': 15,
    'rewarded': 30,
    'native': 10,
  };

  static int getPointsForAdType(String adType) {
    return adPoints[adType] ?? 0;
  }
}
