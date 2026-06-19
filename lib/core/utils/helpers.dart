
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Helpers {
  // Format date
  static String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern, 'ar').format(date);
  }

  // Format time
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a', 'ar').format(time);
  }

  // Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} سنة';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} شهر';
    } else if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()} أسبوع';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  // Format number with commas
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  // Format currency
  static String formatCurrency(double amount, {String currency = 'EGP'}) {
    return NumberFormat.currency(
      symbol: currency == 'EGP' ? 'ج.م' : '\$',
      decimalDigits: 2,
    ).format(amount);
  }

  // Format percentage
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  // Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // Generate avatar color based on name
  static Color getAvatarColor(String name) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
    ];

    int hash = 0;
    for (var i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }

  // Calculate accuracy percentage
  static double calculateAccuracy(int correct, int total) {
    if (total == 0) return 0.0;
    return (correct / total) * 100;
  }

  // Calculate score
  static int calculateScore(int correct, int total, {int timeBonus = 0}) {
    final baseScore = (correct / total) * 100;
    return (baseScore + timeBonus).round();
  }

  // Get difficulty label
  static String getDifficultyLabel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'سهل';
      case 'medium':
        return 'متوسط';
      case 'hard':
        return 'صعب';
      default:
        return difficulty;
    }
  }

  // Get difficulty color
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF27AE60);
      case 'medium':
        return const Color(0xFFF39C12);
      case 'hard':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  // Get streak emoji
  static String getStreakEmoji(int streak) {
    if (streak >= 30) return '🔥🔥🔥';
    if (streak >= 14) return '🔥🔥';
    if (streak >= 7) return '🔥';
    if (streak >= 3) return '⚡';
    return '💪';
  }

  // Get rank emoji
  static String getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '🏅';
    }
  }

  // Get ad type label
  static String getAdTypeLabel(String adType) {
    switch (adType) {
      case 'banner':
        return 'بانر';
      case 'interstitial':
        return 'إعلان بيني';
      case 'rewarded':
        return 'إعلان مكافأة';
      case 'native':
        return 'إعلان مدمج';
      default:
        return adType;
    }
  }

  // Get plan label
  static String getPlanLabel(String plan) {
    switch (plan) {
      case 'monthly':
        return 'شهري';
      case 'yearly':
        return 'سنوي';
      case 'cards_50':
        return '50 بطاقة';
      case 'cards_100':
        return '100 بطاقة';
      default:
        return plan;
    }
  }

  // Safe divide
  static double safeDivide(double numerator, double denominator) {
    if (denominator == 0) return 0;
    return numerator / denominator;
  }

  // Clamp value
  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  // Map value from one range to another
  static double mapRange(double value, double fromMin, double fromMax, double toMin, double toMax) {
    return (value - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin;
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  // Get greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'مساء الخير';
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
  }
}
