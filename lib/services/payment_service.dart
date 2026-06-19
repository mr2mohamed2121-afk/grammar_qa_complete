
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PaymentService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // Paymob Configuration
  static const String _paymobApiKey = 'YOUR_PAYMOB_API_KEY';
  static const String _paymobIntegrationId = 'YOUR_PAYMOB_INTEGRATION_ID';
  static const String _paymobBaseUrl = 'https://accept.paymob.com/api';

  // In-App Purchase Product IDs
  static const Set<String> _kProductIds = {
    'premium_monthly',      // $4.99
    'premium_yearly',       // $49.99
    'cards_50',             // $1.99
    'cards_100',            // $3.49
  };

  Stream<List<PurchaseDetails>> get purchaseStream => _inAppPurchase.purchaseStream;

  // Initialize
  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      throw Exception('In-App Purchase not available');
    }
  }

  // ============================================
  // PAYMOB PAYMENT (Egypt - EGP)
  // ============================================

  Future<Map<String, dynamic>> createPaymobPayment({
    required String userId,
    required String planType,
    required double amount,
    required String email,
    required String phone,
  }) async {
    try {
      // Step 1: Authentication
      final authResponse = await http.post(
        Uri.parse('$_paymobBaseUrl/auth/tokens'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'api_key': _paymobApiKey}),
      );

      if (authResponse.statusCode != 201) {
        throw Exception('Paymob authentication failed');
      }

      final authToken = jsonDecode(authResponse.body)['token'];

      // Step 2: Order Registration
      final orderResponse = await http.post(
        Uri.parse('$_paymobBaseUrl/ecommerce/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'auth_token': authToken,
          'delivery_needed': false,
          'amount_cents': (amount * 100).round(), // Convert to cents
          'currency': 'EGP',
          'items': [],
          'merchant_order_id': 'order_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      if (orderResponse.statusCode != 201) {
        throw Exception('Paymob order creation failed');
      }

      final orderData = jsonDecode(orderResponse.body);
      final orderId = orderData['id'];

      // Step 3: Payment Key
      final paymentKeyResponse = await http.post(
        Uri.parse('$_paymobBaseUrl/acceptance/payment_keys'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'auth_token': authToken,
          'amount_cents': (amount * 100).round(),
          'expiration': 3600,
          'order_id': orderId,
          'billing_data': {
            'apartment': 'NA',
            'email': email,
            'floor': 'NA',
            'first_name': email.split('@')[0],
            'street': 'NA',
            'building': 'NA',
            'phone_number': phone,
            'shipping_method': 'NA',
            'postal_code': 'NA',
            'city': 'Cairo',
            'country': 'EG',
            'last_name': 'User',
            'state': 'Cairo',
          },
          'currency': 'EGP',
          'integration_id': _paymobIntegrationId,
          'lock_order_when_paid': true,
        }),
      );

      if (paymentKeyResponse.statusCode != 201) {
        throw Exception('Paymob payment key creation failed');
      }

      final paymentKeyData = jsonDecode(paymentKeyResponse.body);
      final paymentToken = paymentKeyData['token'];

      // Step 4: Return payment URL
      final paymentUrl = 'https://accept.paymob.com/api/acceptance/iframes/$_paymobIntegrationId?payment_token=$paymentToken';

      return {
        'success': true,
        'paymentUrl': paymentUrl,
        'orderId': orderId.toString(),
        'paymentToken': paymentToken,
      };

    } catch (e) {
      debugPrint('❌ Paymob payment error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Verify Paymob Payment
  Future<bool> verifyPaymobPayment(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_paymobBaseUrl/ecommerce/orders/$orderId'),
        headers: {'Authorization': 'Bearer $_paymobApiKey'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['paid'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Paymob verification error: $e');
      return false;
    }
  }

  // ============================================
  // IN-APP PURCHASE (Google Play / App Store)
  // ============================================

  Future<List<ProductDetails>> getAvailableProducts() async {
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kProductIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('⚠️ Products not found: ${response.notFoundIDs}');
    }

    return response.productDetails;
  }

  Future<void> purchaseProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> purchaseConsumable(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchase);
    }
  }

  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  // ============================================
  // PREMIUM STATUS CHECK
  // ============================================

  Future<bool> checkPremiumStatus(String userId) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('checkPremiumStatus');
      final result = await callable.call({'userId': userId});
      return result.data['isPremium'] ?? false;
    } catch (e) {
      debugPrint('❌ Premium check error: $e');
      return false;
    }
  }

  // ============================================
  // SUBSCRIPTION PLANS
  // ============================================

  static const List<Map<String, dynamic>> subscriptionPlans = [
    {
      'id': 'premium_monthly',
      'name': 'Monthly Premium',
      'description': 'Unlimited cards, no ads, AI analysis',
      'priceUSD': 4.99,
      'priceEGP': 150,
      'duration': 'month',
      'savePercent': 0,
    },
    {
      'id': 'premium_yearly',
      'name': 'Yearly Premium',
      'description': 'Unlimited cards, no ads, AI analysis',
      'priceUSD': 49.99,
      'priceEGP': 1500,
      'duration': 'year',
      'savePercent': 17,
    },
  ];

  static const List<Map<String, dynamic>> cardPacks = [
    {
      'id': 'cards_50',
      'name': '50 Cards Pack',
      'description': 'Get 50 additional flashcards',
      'priceUSD': 1.99,
      'priceEGP': 60,
      'cardCount': 50,
    },
    {
      'id': 'cards_100',
      'name': '100 Cards Pack',
      'description': 'Get 100 additional flashcards',
      'priceUSD': 3.49,
      'priceEGP': 105,
      'cardCount': 100,
    },
  ];

  // ============================================
  // REWARD POINTS SYSTEM
  // ============================================

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

  static Map<String, dynamic>? getRewardDetails(String rewardType) {
    return rewardTiers[rewardType];
  }

  // ============================================
  // FREE TIER LIMITS
  // ============================================

  static const int freeCardLimit = 50;
  static const int dailyAdWatchLimit = 10;
  static const int pointsPerAdWatch = 30; // Rewarded ad
  static const int tripleAdPoints = 90; // 3 ads = 3x points

  // ============================================
  // PAYMENT METHODS CONFIG
  // ============================================

  static const Map<String, Map<String, dynamic>> paymentMethods = {
    'paymob': {
      'name': 'Paymob',
      'currency': 'EGP',
      'icon': 'assets/icons/paymob.png',
      'supported': ['EG'],
    },
    'in_app_purchase': {
      'name': 'Google Play / App Store',
      'currency': 'USD',
      'icon': 'assets/icons/store.png',
      'supported': ['US', 'GLOBAL'],
    },
  };
}

// Payment Status Enum
enum PaymentStatus {
  pending,
  completed,
  failed,
  cancelled,
  refunded,
}

// Subscription Plan Enum
enum SubscriptionPlan {
  free,
  monthly,
  yearly,
}

// Extension for SubscriptionPlan
extension SubscriptionPlanExtension on SubscriptionPlan {
  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.monthly:
        return 'Monthly Premium';
      case SubscriptionPlan.yearly:
        return 'Yearly Premium';
    }
  }

  bool get hasUnlimitedCards {
    return this != SubscriptionPlan.free;
  }

  bool get hasNoAds {
    return this != SubscriptionPlan.free;
  }

  bool get hasAIAnalysis {
    return this != SubscriptionPlan.free;
  }
}
