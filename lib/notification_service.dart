
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

@lazySingleton
class NotificationService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  NotificationService(this._messaging, this._localNotifications);

  Future<void> initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Get FCM token
    final token = await _messaging.getToken();
    print('FCM Token: $token');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background message
    print('Background message: ${message.notification?.title}');
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'grammar_qa_channel',
      'Grammar QA Notifications',
      channelDescription: 'Notifications for Grammar QA app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Schedule daily reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily study reminder',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Smart notifications based on streak
  Future<void> sendStreakReminder(int streakDays) async {
    String title;
    String body;

    if (streakDays >= 7) {
      title = '🔥 سلسلة نجاحك مستمرة!';
      body = 'لقد حافظت على سلسلة نجاحك لمدة $streakDays أيام. استمر!';
    } else if (streakDays >= 3) {
      title = '⚡ أنت على الطريق!';
      body = 'سلسلة نجاحك: $streakDays أيام. لا تفوت اليوم!';
    } else {
      title = '📚 وقت الدراسة!';
      body = 'حافظ على سلسلة نجاحك. ادخل الآن واكمل درسك!';
    }

    await _showLocalNotification(title: title, body: body);
  }

  // Achievement notification
  Future<void> sendAchievementNotification(String achievementName) async {
    await _showLocalNotification(
      title: '🏆 إنجاز جديد!',
      body: 'تهانينا! لقد حصلت على إنجاز: $achievementName',
    );
  }

  // Premium expiration warning
  Future<void> sendPremiumExpirationWarning(int daysLeft) async {
    await _showLocalNotification(
      title: '⏰ Premium سينتهي قريباً',
      body: 'اشتراك Premium سينتهي خلال $daysLeft أيام. جدد الآن!',
    );
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
