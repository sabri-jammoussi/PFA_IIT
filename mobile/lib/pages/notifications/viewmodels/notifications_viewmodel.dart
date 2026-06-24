import 'dart:async';
import 'package:get/get.dart';
import 'package:dentiflow/core/services/signalr_service.dart';
import '../models/notification_model.dart';
import '../services/notification_service_api.dart';

class NotificationsViewModel extends GetxController {
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  StreamSubscription<SignalRNotificationEvent>? _liveSub;

  @override
  void onInit() {
    super.onInit();
    load();
    // Refresh the list live whenever a real-time notification arrives.
    _liveSub = SignalRService.instance.notificationEventsStream.stream
        .listen((_) => load());
  }

  @override
  void onClose() {
    _liveSub?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        NotificationApiService.getNotifications(),
        NotificationApiService.getCount(),
      ]);
      notifications.assignAll(results[0] as List<AppNotification>);
      unreadCount.value = results[1] as int;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markSeen(int id) async {
    try {
      await NotificationApiService.markSeen(id);
      final int idx = notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        notifications[idx].isSeen = true;
        notifications.refresh();
        if (unreadCount.value > 0) unreadCount.value--;
      }
    } catch (_) {}
  }

  Future<void> markAllSeen() async {
    try {
      await NotificationApiService.markAllSeen();
      for (final n in notifications) {
        n.isSeen = true;
      }
      notifications.refresh();
      unreadCount.value = 0;
    } catch (_) {}
  }
}
