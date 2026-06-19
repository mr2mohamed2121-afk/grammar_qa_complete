
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/payment_service.dart';
import '../services/admob_service.dart';
import '../widgets/ad_banner_widget.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;
  int _userPoints = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isPremium = state is AuthAuthenticated && state.user.isPremium;

        return Scaffold(
          appBar: AppBar(
            title: const Text('الاشتراكات والنقاط'),
            actions: [
              if (!isPremium)
                Chip(
                  label: Text('$_userPoints نقطة'),
                  backgroundColor: const Color(0xFFFF6584),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              const SizedBox(width: 16),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Status Card
                _buildPremiumStatusCard(isPremium),
                const SizedBox(height: 24),

                if (!isPremium) ...[
                  // Subscription Plans
                  _buildSectionTitle('خطط الاشتراك'),
                  const SizedBox(height: 12),
                  ...PaymentService.subscriptionPlans.map((plan) => 
                    _buildPlanCard(plan, isEGP: true)
                  ),
                  const SizedBox(height: 24),

                  // Card Packs
                  _buildSectionTitle('حزم البطاقات'),
                  const SizedBox(height: 12),
                  ...PaymentService.cardPacks.map((pack) => 
                    _buildCardPackCard(pack, isEGP: true)
                  ),
                  const SizedBox(height: 24),

                  // Reward Points
                  _buildSectionTitle('مكافآت النقاط'),
                  const SizedBox(height: 12),
                  ...PaymentService.rewardTiers.entries.map((entry) => 
                    _buildRewardCard(entry.key, entry.value)
                  ),
                  const SizedBox(height: 24),

                  // Earn Points Section
                  _buildSectionTitle('اكسب النقاط'),
                  const SizedBox(height: 12),
                  _buildEarnPointsSection(),
                ],

                if (isPremium) ...[
                  // Premium Features
                  _buildSectionTitle('مميزات Premium'),
                  const SizedBox(height: 12),
                  _buildPremiumFeaturesList(),
                ],
              ],
            ),
          ),
          bottomNavigationBar: !isPremium ? const AdBannerWidget() : null,
        );
      },
    );
  }

  Widget _buildPremiumStatusCard(bool isPremium) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isPremium ? Icons.diamond : Icons.lock_outline,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            isPremium ? 'أنت مشترك Premium! 💎' : 'Upgrade to Premium',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPremium
                ? 'استمتع بجميع المميزات بدون قيود'
                : 'احصل على بطاقات غير محدودة وبدون إعلانات',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          if (!isPremium) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeatureChip('✓ Unlimited Cards'),
                const SizedBox(width: 8),
                _buildFeatureChip('✓ No Ads'),
                const SizedBox(width: 8),
                _buildFeatureChip('✓ AI Analysis'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, {required bool isEGP}) {
    final bool isYearly = plan['duration'] == 'year';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isYearly
            ? const BorderSide(color: Color(0xFF6C63FF), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (plan['savePercent'] > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'وفر ${plan['savePercent']}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan['description'],
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  isEGP
                      ? '${plan['priceEGP']} ج.م'
                      : '\$${plan['priceUSD']}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/${plan['duration']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _subscribe(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isYearly
                      ? const Color(0xFF6C63FF)
                      : Colors.white,
                  foregroundColor: isYearly
                      ? Colors.white
                      : const Color(0xFF6C63FF),
                  side: isYearly
                      ? null
                      : const BorderSide(color: Color(0xFF6C63FF)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('اشترك الآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPackCard(Map<String, dynamic> pack, {required bool isEGP}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.style,
            color: Color(0xFF6C63FF),
          ),
        ),
        title: Text(pack['name']),
        subtitle: Text('${pack['cardCount']} بطاقة'),
        trailing: ElevatedButton(
          onPressed: _isLoading ? null : () => _buyCardPack(pack),
          child: Text(
            isEGP ? '${pack['priceEGP']} ج.م' : '\$${pack['priceUSD']}',
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard(String rewardType, Map<String, dynamic> reward) {
    final bool canAfford = _userPoints >= (reward['points'] as int);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: canAfford
                ? const Color(0xFFFF6584).withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.card_giftcard,
            color: canAfford ? const Color(0xFFFF6584) : Colors.grey,
          ),
        ),
        title: Text(reward['description']),
        subtitle: Text('${reward['points']} نقطة'),
        trailing: ElevatedButton(
          onPressed: canAfford && !_isLoading
              ? () => _redeemReward(rewardType, reward)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canAfford ? const Color(0xFFFF6584) : Colors.grey,
          ),
          child: const Text('استبدال'),
        ),
      ),
    );
  }

  Widget _buildEarnPointsSection() {
    return Column(
      children: [
        TripleAdPointsButton(
          onTripleReward: (points) {
            setState(() => _userPoints += points);
            _showSuccessDialog('🎉 تهانينا!', 'حصلت على $points نقطة!');
          },
          onFailed: () {
            _showErrorDialog('لا يوجد إعلانات متاحة حالياً');
          },
        ),
        const SizedBox(height: 12),
        RewardedAdButton(
          label: 'شاهد إعلان واحصل على 30 نقطة',
          icon: Icons.play_circle_outline,
          onRewardEarned: (points) {
            setState(() => _userPoints += points);
            _showSuccessDialog('🎉 تم!', 'حصلت على $points نقطة!');
          },
          onAdFailed: () {
            _showErrorDialog('لا يوجد إعلانات متاحة حالياً');
          },
        ),
      ],
    );
  }

  Widget _buildPremiumFeaturesList() {
    final features = [
      {'icon': Icons.all_inclusive, 'title': 'بطاقات غير محدودة', 'desc': 'أضف أي عدد من البطاقات'},
      {'icon': Icons.block, 'title': 'بدون إعلانات', 'desc': 'استمتع بتجربة خالية من الإعلانات'},
      {'icon': Icons.psychology, 'title': 'تحليل AI', 'desc': 'تحليل ذكي للأخطاء'},
      {'icon': Icons.speed, 'title': 'مزامنة سريعة', 'desc': 'مزامنة فورية مع السحابة'},
      {'icon': Icons.support_agent, 'title': 'دعم مميز', 'desc': 'دعم فني أولوية'},
    ];

    return Column(
      children: features.map((feature) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(feature['icon'] as IconData, color: const Color(0xFF6C63FF)),
          title: Text(feature['title'] as String),
          subtitle: Text(feature['desc'] as String),
        ),
      )).toList(),
    );
  }

  void _subscribe(Map<String, dynamic> plan) async {
    setState(() => _isLoading = true);

    try {
      // Show payment method selection
      final method = await _showPaymentMethodDialog();
      if (method == null) {
        setState(() => _isLoading = false);
        return;
      }

      if (method == 'paymob') {
        // Paymob payment
        final result = await _paymentService.createPaymobPayment(
          userId: 'current_user_id',
          planType: plan['id'],
          amount: plan['priceEGP'].toDouble(),
          email: 'user@example.com',
          phone: '01234567890',
        );

        if (result['success'] == true) {
          // Open payment URL in WebView
          _showPaymentWebView(result['paymentUrl']);
        } else {
          _showErrorDialog(result['error'] ?? 'فشل إنشاء الدفع');
        }
      } else {
        // In-App Purchase
        final products = await _paymentService.getAvailableProducts();
        final product = products.firstWhere(
          (p) => p.id == plan['id'],
          orElse: () => throw Exception('Product not found'),
        );
        await _paymentService.purchaseProduct(product);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _buyCardPack(Map<String, dynamic> pack) async {
    setState(() => _isLoading = true);

    try {
      final products = await _paymentService.getAvailableProducts();
      final product = products.firstWhere(
        (p) => p.id == pack['id'],
        orElse: () => throw Exception('Product not found'),
      );
      await _paymentService.purchaseConsumable(product);
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _redeemReward(String rewardType, Map<String, dynamic> reward) async {
    setState(() => _isLoading = true);

    try {
      // Call Cloud Function to redeem
      // final result = await _paymentService.redeemPoints(rewardType);

      setState(() => _userPoints -= (reward['points'] as int));
      _showSuccessDialog(
        '🎁 مبروك!',
        'تم استبدال ${reward['description']}',
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _showPaymentMethodDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر طريقة الدفع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Paymob (فودافون كاش - بطاقة)'),
              subtitle: const Text('الدفع بالجنيه المصري'),
              onTap: () => Navigator.pop(context, 'paymob'),
            ),
            ListTile(
              leading: const Icon(Icons.shop),
              title: const Text('Google Play / App Store'),
              subtitle: const Text('الدفع بالدولار'),
              onTap: () => Navigator.pop(context, 'iap'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentWebView(String url) {
    // Implement WebView for payment
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إتمام الدفع'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'جاري فتح صفحة الدفع...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  url,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
