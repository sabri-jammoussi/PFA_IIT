import 'package:dentiflow/core/services/api_service.dart';
import '../models/notification_model.dart';

class NotificationApiService {
  static Future<List<AppNotification>> getNotifications() async {
    final dynamic data = await ApiService.get('/nf/notifications');
    if (data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();
    }
    return [];
  }

  static Future<int> getCount() async {
    final dynamic data = await ApiService.get('/nf/notifications/count');
    if (data is Map<String, dynamic>) {
      return (data['count'] ?? data['unread'] ?? 0) as int;
    }
    if (data is int) return data;
    return 0;
  }

  static Future<void> markSeen(int id) async {
    await ApiService.post('/nf/notifications/seen/$id');
  }

  static Future<void> markAllSeen() async {
    await ApiService.post('/nf/notifications/seen');
  }
}
