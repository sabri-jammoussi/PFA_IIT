import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  static Future<void> show({
    required String title,
    required String body,
    int id = 0,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'dentiflow_channel',
        'DentiFlow Notifications',
        importance: Importance.high,
        priority: Priority.high,
      );
      const NotificationDetails details =
          NotificationDetails(android: androidDetails);
      await _plugin.show(id, title, body, details);
    } catch (e) {
      debugPrint('[Notifications] show failed: $e');
    }
  }
}
