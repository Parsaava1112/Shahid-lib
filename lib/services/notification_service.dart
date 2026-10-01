import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // اعلان در پس‌زمینه
  print('Background message: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // درخواست مجوز
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // هندلر پس‌زمینه
    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    // تنظیمات اعلان محلی
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // دریافت توکن
    final token = await _messaging.getToken();
    print('FCM Token: $token');

    // گوش دادن به اعلان‌ها در فورگراند
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _showLocalNotification(
          notification.title ?? '',
          notification.body ?? '',
        );
      }
    });
  }

  static Future<void> _showLocalNotification(
      String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'shahid_library_channel',
      'کتابخانه شهید سلیمانی',
      channelDescription: 'اعلان‌های کتابخانه',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(0, title, body, details);
  }

  /// ثبت توکن در بک‌اند
  static Future<void> registerToken(int userId) async {
    final token = await _messaging.getToken();
    if (token != null) {
      // ارسال به بک‌اند
      // ApiService.registerFcmToken(userId, token);
    }
  }
}