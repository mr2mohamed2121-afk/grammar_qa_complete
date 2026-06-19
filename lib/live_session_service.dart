
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:injectable/injectable.dart';
import '../core/services/local_storage_service.dart';
import '../features/auth/domain/entities/user_entity.dart';

@lazySingleton
class LiveSessionService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final LocalStorageService _localStorage;

  LiveSessionService(this._firestore, this._functions, this._localStorage);

  // UPDATED PRICES - LOWER AND MORE AFFORDABLE
  static const Map<String, Map<String, dynamic>> sessionPlans = {
    'single_session': {
      'name': 'حصة فردية',
      'description': 'حصة مباشرة واحدة مع الأستاذ',
      'priceUSD': 6.50,        // Was $15.00 - Reduced 57%
      'priceEGP': 200,         // Was 450 - Reduced 56%
      'duration': 60,          // minutes
      'sessions': 1,
    },
    'pack_5': {
      'name': 'باقة 5 حصص',
      'description': '5 حصص مباشرة مع الأستاذ',
      'priceUSD': 26.00,       // Was $65.00 - Reduced 60%
      'priceEGP': 800,         // Was 1950 - Reduced 59%
      'duration': 60,
      'sessions': 5,
      'savePercent': 20,       // Save 20% vs single sessions
      'pricePerSession': 160,  // 160 EGP per session
    },
    'pack_10': {
      'name': 'باقة 10 حصص',
      'description': '10 حصص مباشرة مع الأستاذ',
      'priceUSD': 48.00,       // Was $120.00 - Reduced 60%
      'priceEGP': 1500,        // Was 3600 - Reduced 58%
      'duration': 60,
      'sessions': 10,
      'savePercent': 25,       // Save 25% vs single sessions
      'pricePerSession': 150,  // 150 EGP per session
    },
    'monthly_unlimited': {
      'name': 'شهر غير محدود',
      'description': 'حصص غير محدودة لمدة شهر',
      'priceUSD': 80.00,       // Was $199.00 - Reduced 60%
      'priceEGP': 2500,        // Was 6000 - Reduced 58%
      'duration': 60,
      'sessions': -1,          // unlimited
      'savePercent': 0,
    },
  };

  // Get available time slots
  Future<List<TimeSlot>> getAvailableSlots(DateTime date) async {
    try {
      final snapshot = await _firestore
          .collection('live_sessions')
          .doc('schedule')
          .collection('slots')
          .where('date', isEqualTo: _formatDate(date))
          .where('isBooked', isEqualTo: false)
          .get();

      return snapshot.docs.map((doc) => TimeSlot.fromJson(doc.data())).toList();
    } catch (e) {
      // Return mock data for testing
      return _generateMockSlots(date);
    }
  }

  List<TimeSlot> _generateMockSlots(DateTime date) {
    final slots = <TimeSlot>[];
    final startHour = 16; // 4 PM
    final endHour = 21;   // 9 PM

    for (var hour = startHour; hour < endHour; hour++) {
      slots.add(TimeSlot(
        id: 'slot_${date.day}_$hour',
        date: date,
        startTime: DateTime(date.year, date.month, date.day, hour, 0),
        endTime: DateTime(date.year, date.month, date.day, hour + 1, 0),
        isBooked: false,
      ));
    }

    return slots;
  }

  // Book a session
  Future<BookingResult> bookSession({
    required String userId,
    required String userName,
    required String userEmail,
    required TimeSlot slot,
    required String planId,
    required String paymentMethod,
  }) async {
    try {
      // Check if slot is still available
      final slotDoc = await _firestore
          .collection('live_sessions')
          .doc('schedule')
          .collection('slots')
          .doc(slot.id)
          .get();

      if (slotDoc.exists && slotDoc.data()?['isBooked'] == true) {
        return BookingResult.error('هذا الموعد محجوز بالفعل، يرجى اختيار موعد آخر');
      }

      // Create booking
      final bookingRef = _firestore.collection('session_bookings').doc();
      final booking = SessionBooking(
        id: bookingRef.id,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        slot: slot,
        planId: planId,
        status: 'pending_payment',
        createdAt: DateTime.now(),
      );

      await bookingRef.set(booking.toJson());

      // Reserve the slot
      await _firestore
          .collection('live_sessions')
          .doc('schedule')
          .collection('slots')
          .doc(slot.id)
          .update({'isBooked': true, 'bookingId': bookingRef.id});

      return BookingResult.success(bookingRef.id, 'تم حجز الموعد بنجاح، يرجى إتمام الدفع');
    } catch (e) {
      return BookingResult.error('حدث خطأ في الحجز: $e');
    }
  }

  // Process payment for session
  Future<PaymentResult> processSessionPayment({
    required String bookingId,
    required String planId,
    required String paymentMethod,
    String? email,
    String? phone,
  }) async {
    try {
      final plan = sessionPlans[planId];
      if (plan == null) {
        return PaymentResult.error('خطة غير صالحة');
      }

      if (paymentMethod == 'paymob') {
        // Create Paymob payment
        final result = await _createPaymobPayment(
          amount: plan['priceEGP'].toDouble(),
          email: email ?? '',
          phone: phone ?? '',
          bookingId: bookingId,
        );

        if (result['success'] == true) {
          return PaymentResult.redirect(result['paymentUrl']!, bookingId);
        } else {
          return PaymentResult.error(result['error'] ?? 'فشل إنشاء الدفع');
        }
      } else if (paymentMethod == 'iap') {
        // In-App Purchase
        return PaymentResult.inAppPurchase(bookingId, planId);
      }

      return PaymentResult.error('طريقة دفع غير صالحة');
    } catch (e) {
      return PaymentResult.error('خطأ في الدفع: $e');
    }
  }

  Future<Map<String, dynamic>> _createPaymobPayment({
    required double amount,
    required String email,
    required String phone,
    required String bookingId,
  }) async {
    try {
      final callable = _functions.httpsCallable('createPaymobSessionPayment');
      final result = await callable.call({
        'amount': amount,
        'email': email,
        'phone': phone,
        'bookingId': bookingId,
      });
      return result.data as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Confirm payment and activate session
  Future<void> confirmPayment(String bookingId) async {
    await _firestore.collection('session_bookings').doc(bookingId).update({
      'status': 'confirmed',
      'paidAt': DateTime.now().toIso8601String(),
    });
  }

  // Get user's bookings
  Future<List<SessionBooking>> getUserBookings(String userId) async {
    final snapshot = await _firestore
        .collection('session_bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => SessionBooking.fromJson(doc.data())).toList();
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    final booking = await _firestore.collection('session_bookings').doc(bookingId).get();
    if (!booking.exists) return;

    final data = booking.data()!;
    final slotId = data['slot']['id'];

    // Free the slot
    await _firestore
        .collection('live_sessions')
        .doc('schedule')
        .collection('slots')
        .doc(slotId)
        .update({'isBooked': false, 'bookingId': null});

    // Update booking status
    await _firestore.collection('session_bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': DateTime.now().toIso8601String(),
    });
  }

  // Get session link (Zoom/Google Meet)
  Future<String?> getSessionLink(String bookingId) async {
    final doc = await _firestore.collection('session_bookings').doc(bookingId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    if (data['status'] != 'confirmed') return null;

    return data['sessionLink'] as String?;
  }

  // Check if user has available sessions
  Future<bool> hasAvailableSessions(String userId) async {
    final snapshot = await _firestore
        .collection('session_packages')
        .where('userId', isEqualTo: userId)
        .where('remainingSessions', isGreaterThan: 0)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get remaining sessions count
  Future<int> getRemainingSessions(String userId) async {
    final snapshot = await _firestore
        .collection('session_packages')
        .where('userId', isEqualTo: userId)
        .get();

    int total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['remainingSessions'] as int? ?? 0);
    }
    return total;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// Models
class TimeSlot {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;

  TimeSlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isBooked: json['isBooked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isBooked': isBooked,
    };
  }

  String get formattedTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }
}

class SessionBooking {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final TimeSlot slot;
  final String planId;
  final String status;
  final DateTime createdAt;
  final String? sessionLink;
  final DateTime? paidAt;
  final DateTime? cancelledAt;

  SessionBooking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.slot,
    required this.planId,
    required this.status,
    required this.createdAt,
    this.sessionLink,
    this.paidAt,
    this.cancelledAt,
  });

  factory SessionBooking.fromJson(Map<String, dynamic> json) {
    return SessionBooking(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      slot: TimeSlot.fromJson(json['slot']),
      planId: json['planId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      sessionLink: json['sessionLink'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'slot': slot.toJson(),
      'planId': planId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'sessionLink': sessionLink,
      'paidAt': paidAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }
}

class BookingResult {
  final bool success;
  final String? bookingId;
  final String message;

  BookingResult._({required this.success, this.bookingId, required this.message});

  factory BookingResult.success(String bookingId, String message) {
    return BookingResult._(success: true, bookingId: bookingId, message: message);
  }

  factory BookingResult.error(String message) {
    return BookingResult._(success: false, message: message);
  }
}

class PaymentResult {
  final bool success;
  final String? paymentUrl;
  final String? bookingId;
  final bool isInAppPurchase;
  final String message;

  PaymentResult._({
    required this.success,
    this.paymentUrl,
    this.bookingId,
    this.isInAppPurchase = false,
    required this.message,
  });

  factory PaymentResult.redirect(String url, String bookingId) {
    return PaymentResult._(
      success: true,
      paymentUrl: url,
      bookingId: bookingId,
      message: 'Redirect to payment',
    );
  }

  factory PaymentResult.inAppPurchase(String bookingId, String planId) {
    return PaymentResult._(
      success: true,
      bookingId: bookingId,
      isInAppPurchase: true,
      message: 'In-App Purchase required',
    );
  }

  factory PaymentResult.error(String message) {
    return PaymentResult._(success: false, message: message);
  }
}
