import 'package:flutter/material.dart';

class LiveSessionsScreen extends StatefulWidget {
  const LiveSessionsScreen({super.key});

  @override
  State<LiveSessionsScreen> createState() => _LiveSessionsScreenState();
}

class _LiveSessionsScreenState extends State<LiveSessionsScreen> {
  int _selectedPackage = -1;

  final List<Map<String, dynamic>> _packages = const [
    {
      'title': 'جلسة واحدة',
      'price': '200',
      'currency': 'EGP',
      'icon': Icons.video_call,
      'color': Color(0xFF2E7D32),
      'sessions': '1 جلسة',
    },
    {
      'title': '5 جلسات',
      'price': '800',
      'currency': 'EGP',
      'icon': Icons.video_library,
      'color': Color(0xFF1E3A5F),
      'sessions': '5 جلسات',
      'badge': 'وفر 200',
    },
    {
      'title': '10 جلسات',
      'price': '1500',
      'currency': 'EGP',
      'icon': Icons.school,
      'color': Color(0xFFE94560),
      'sessions': '10 جلسات',
      'badge': 'وفر 500',
      'popular': true,
    },
    {
      'title': 'شهر غير محدود',
      'price': '2500',
      'currency': 'EGP',
      'icon': Icons.all_inclusive,
      'color': Color(0xFFFF8C00),
      'sessions': 'غير محدود',
      'badge': 'الأفضل قيمة',
    },
  ];

  void _selectPackage(int index) {
    setState(() => _selectedPackage = index);
    _showBookingDialog(_packages[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'الجلسات المباشرة',
          style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF16213E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE94560), Color(0xFF0F3460)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.live_tv, size: 60, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text(
                      'تعلم النحو مباشرة مع خبراء',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'جلسات تفاعلية مباشرة مع أفضل المدرسين',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'اختر باقتك',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),

              for (int i = 0; i < _packages.length; i++) ...[
                GestureDetector(
                  onTap: () => _selectPackage(i),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: _selectedPackage == i
                              ? const Color(0xFF0F3460)
                              : const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(16),
                          border: _selectedPackage == i
                              ? Border.all(color: const Color(0xFFE94560), width: 2)
                              : (_packages[i]['popular'] ?? false)
                                  ? Border.all(color: const Color(0xFFE94560), width: 2)
                                  : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: (_packages[i]['color'] as Color).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _packages[i]['icon'] as IconData,
                                  color: _packages[i]['color'] as Color,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _packages[i]['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _packages[i]['sessions'] as String,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${_packages[i]['price']}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: _packages[i]['color'] as Color,
                                    ),
                                  ),
                                  Text(
                                    _packages[i]['currency'] as String,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_packages[i]['popular'] ?? false)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE94560),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'الأكثر شيوعاً',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          'حجز ${package['title']}',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'السعر: ${package['price']} ${package['currency']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'اختر طريقة الدفع:',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Cairo',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption('Vodafone Cash', Icons.phone_android, 'vodafone', package),
              _buildPaymentOption('Etisalat Cash', Icons.phone_android, 'etisalat', package),
              _buildPaymentOption('Orange Cash', Icons.phone_android, 'orange', package),
              _buildPaymentOption('WE Pay', Icons.phone_android, 'we', package),
              _buildPaymentOption('PayPal', Icons.payment, 'paypal', package),
              _buildPaymentOption('InstaPay', Icons.account_balance, 'instapay', package),
              _buildPaymentOption('Bank Transfer', Icons.account_balance_wallet, 'bank', package),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, String method, Map<String, dynamic> package) {
    return Card(
      color: const Color(0xFF0F3460),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        onTap: () => _launchPayment(method, package),
      ),
    );
  }

  void _launchPayment(String method, Map<String, dynamic> package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'تعليمات الدفع',
          style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طريقة الدفع: $method',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'المبلغ: ${package['price']} ${package['currency']}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            const Text(
              'سيتم التواصل معك قريباً لإتمام عملية الدفع وتأكيد الحجز.',
              style: TextStyle(color: Colors.white70, fontFamily: 'Cairo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم إرسال طلب الحجز! سنتواصل معك قريباً.'),
                  backgroundColor: Color(0xFF2E7D32),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}