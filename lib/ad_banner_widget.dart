
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

class AdBannerWidget extends StatefulWidget {
  final AdSize adSize;
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdFailed;

  const AdBannerWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.onAdLoaded,
    this.onAdFailed,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  final AdMobService _adService = AdMobService();
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobService.effectiveBannerAdUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
          widget.onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          widget.onAdFailed?.call();
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

// Premium Ad Banner - Shows only for non-premium users
class PremiumAdBanner extends StatelessWidget {
  final bool isPremium;
  final Widget child;

  const PremiumAdBanner({
    super.key,
    required this.isPremium,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isPremium) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        const AdBannerWidget(),
      ],
    );
  }
}

// Interstitial Ad Wrapper
class InterstitialAdWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAdDismissed;

  const InterstitialAdWrapper({
    super.key,
    required this.child,
    this.onAdDismissed,
  });

  @override
  State<InterstitialAdWrapper> createState() => _InterstitialAdWrapperState();
}

class _InterstitialAdWrapperState extends State<InterstitialAdWrapper> {
  final AdMobService _adService = AdMobService();

  @override
  void initState() {
    super.initState();
    _adService.loadInterstitialAd();
  }

  void showAd() {
    _adService.showInterstitialWithFrequency(
      onDismissed: () {
        _adService.loadInterstitialAd(); // Preload next ad
        widget.onAdDismissed?.call();
      },
      onFailed: () {
        widget.onAdDismissed?.call();
      },
    );
  }

  @override
  void dispose() {
    _adService.disposeInterstitialAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Rewarded Ad Button
class RewardedAdButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Function(int points) onRewardEarned;
  final VoidCallback? onAdFailed;

  const RewardedAdButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onRewardEarned,
    this.onAdFailed,
  });

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  final AdMobService _adService = AdMobService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _adService.loadRewardedAd(
      onLoaded: () => setState(() => _isLoading = false),
      onFailed: () => setState(() => _isLoading = false),
    );
  }

  void _showAd() {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    _adService.showRewardedAd(
      onRewarded: (amount, type) {
        widget.onRewardEarned(amount);
        _loadAd(); // Preload next ad
      },
      onDismissed: () {
        setState(() => _isLoading = false);
      },
      onFailed: () {
        setState(() => _isLoading = false);
        widget.onAdFailed?.call();
      },
    );
  }

  @override
  void dispose() {
    _adService.disposeRewardedAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _showAd,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(widget.icon),
      label: Text(widget.label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6584),
        foregroundColor: Colors.white,
      ),
    );
  }
}

// Triple Ad Points Button
class TripleAdPointsButton extends StatefulWidget {
  final Function(int totalPoints) onTripleReward;
  final VoidCallback? onFailed;

  const TripleAdPointsButton({
    super.key,
    required this.onTripleReward,
    this.onFailed,
  });

  @override
  State<TripleAdPointsButton> createState() => _TripleAdPointsButtonState();
}

class _TripleAdPointsButtonState extends State<TripleAdPointsButton> {
  final AdMobService _adService = AdMobService();
  int _adsWatched = 0;
  int _totalPoints = 0;
  bool _isLoading = false;

  void _watchAd() {
    if (_isLoading) return;
    if (_adsWatched >= 3) return;

    setState(() => _isLoading = true);

    _adService.loadRewardedAd(
      onLoaded: () {
        _adService.showRewardedAd(
          onRewarded: (amount, type) {
            setState(() {
              _adsWatched++;
              _totalPoints += amount;
              _isLoading = false;
            });

            if (_adsWatched >= 3) {
              // Triple the points!
              final triplePoints = _totalPoints * 3;
              widget.onTripleReward(triplePoints);
            } else {
              // Show continue dialog
              _showContinueDialog();
            }
          },
          onDismissed: () => setState(() => _isLoading = false),
          onFailed: () {
            setState(() => _isLoading = false);
            widget.onFailed?.call();
          },
        );
      },
      onFailed: () {
        setState(() => _isLoading = false);
        widget.onFailed?.call();
      },
    );
  }

  void _showContinueDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 إعلان تم!'),
        content: Text('شاهد ${_adsWatched}/3 إعلانات\n\nالنقاط الحالية: $_totalPoints\n\nهل تريد المتابعة للحصول على 3x النقاط؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onTripleReward(_totalPoints); // Give normal points
            },
            child: const Text('لا، احصل على النقاط العادية'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _watchAd();
            },
            child: Text('نعم! ($_adsWatched/3)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.local_play, size: 48, color: Color(0xFFFF6584)),
            const SizedBox(height: 8),
            Text(
              '3 إعلانات = 3x النقاط!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'شاهد 3 إعلانات واحصل على ثلاثة أضعاف النقاط',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _adsWatched / 3,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6584)),
            ),
            const SizedBox(height: 8),
            Text('$_adsWatched / 3 إعلانات'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _adsWatched >= 3 ? null : _watchAd,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_circle_outline),
              label: Text(_adsWatched >= 3 ? 'تم!' : 'شاهد إعلان'),
            ),
          ],
        ),
      ),
    );
  }
}
