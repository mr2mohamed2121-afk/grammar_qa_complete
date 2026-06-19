
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/live_session_service.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

class LiveSessionScreen extends StatefulWidget {
  const LiveSessionScreen({super.key});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  final LiveSessionService _sessionService = LiveSessionService();
  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedSlot;
  String? _selectedPlan;
  List<TimeSlot> _availableSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() => _isLoading = true);
    final slots = await _sessionService.getAvailableSlots(_selectedDate);
    setState(() {
      _availableSlots = slots;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 الحصص المباشرة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Calendar
            _buildCalendar(),
            const SizedBox(height: 24),

            // Available Slots
            _buildSlotsSection(),
            const SizedBox(height: 24),

            // Session Plans
            _buildPlansSection(),
            const SizedBox(height: 24),

            // Book Button
            _buildBookButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.video_call,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'حصص مباشرة مع الأستاذ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'احجز حصة مباشرة مع مستر محمد أحمد الوهيدي',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // NEW: Price tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ابتداء من 200 ج.م فقط!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 30)),
          focusedDay: _selectedDate,
          selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDate = selectedDay;
              _selectedSlot = null;
            });
            _loadSlots();
          },
          calendarFormat: CalendarFormat.week,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF6C63FF),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المواعيد المتاحة ${_selectedDate.day}/${_selectedDate.month}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_availableSlots.isEmpty)
          _buildEmptySlots()
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSlots.map((slot) => _buildSlotChip(slot)).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptySlots() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'لا توجد مواعيد متاحة',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotChip(TimeSlot slot) {
    final isSelected = _selectedSlot?.id == slot.id;

    return ChoiceChip(
      label: Text(slot.formattedTime),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSlot = selected ? slot : null;
        });
      },
      selectedColor: const Color(0xFF6C63FF),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildPlansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر الباقة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...LiveSessionService.sessionPlans.entries.map((entry) => 
          _buildPlanCard(entry.key, entry.value)
        ),
      ],
    );
  }

  Widget _buildPlanCard(String planId, Map<String, dynamic> plan) {
    final isSelected = _selectedPlan == planId;
    final sessions = plan['sessions'] as int;
    final priceEGP = plan['priceEGP'] as int;
    final pricePerSession = plan['pricePerSession'] as int?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Color(0xFF6C63FF), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPlan = planId;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.video_call,
                  color: Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (pricePerSession != null)
                      Text(
                        '$pricePerSession ج.م / الحصة',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF27AE60),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$priceEGP ج.م',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  if (plan['savePercent'] > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'وفر ${plan['savePercent']}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    final canBook = _selectedSlot != null && _selectedPlan != null;

    return ElevatedButton.icon(
      onPressed: canBook ? _bookSession : null,
      icon: const Icon(Icons.calendar_today),
      label: const Text('احجز الآن'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFF6C63FF),
      ),
    );
  }

  Future<void> _bookSession() async {
    if (_selectedSlot == null || _selectedPlan == null) return;

    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        _showError('يرجى تسجيل الدخول أولاً');
        return;
      }

      final user = authState.user;

      // Show payment method selection
      final paymentMethod = await _showPaymentMethodDialog();
      if (paymentMethod == null) return;

      // Book the session
      final result = await _sessionService.bookSession(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        slot: _selectedSlot!,
        planId: _selectedPlan!,
        paymentMethod: paymentMethod,
      );

      if (result.success) {
        // Process payment
        final paymentResult = await _sessionService.processSessionPayment(
          bookingId: result.bookingId!,
          planId: _selectedPlan!,
          paymentMethod: paymentMethod,
          email: user.email,
        );

        if (paymentResult.success) {
          if (paymentResult.isInAppPurchase) {
            _showInAppPurchaseDialog(result.bookingId!);
          } else if (paymentResult.paymentUrl != null) {
            _showPaymentWebView(paymentResult.paymentUrl!);
          }
        } else {
          _showError(paymentResult.message);
        }
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('حدث خطأ: $e');
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
              subtitle: const Text('الدفع بالدولار الأمريكي'),
              onTap: () => Navigator.pop(context, 'iap'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInAppPurchaseDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إتمام الدفع'),
        content: const Text('سيتم توجيهك إلى متجر التطبيقات لإتمام الدفع'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement In-App Purchase flow
            },
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }

  void _showPaymentWebView(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إتمام الدفع'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
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
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
