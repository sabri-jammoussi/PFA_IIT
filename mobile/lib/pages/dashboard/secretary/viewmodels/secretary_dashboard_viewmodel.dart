import 'package:get/get.dart';
import '../services/secretary_dashboard_service.dart';

class SecretaryDashboardViewModel extends GetxController {
  final RxInt pendingCount = 0.obs;
  final RxList<Map<String, dynamic>> todayAppointments =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        SecretaryDashboardService.getTodayAppointments(),
        SecretaryDashboardService.getPendingCount(),
      ]);
      todayAppointments.assignAll(results[0] as List<Map<String, dynamic>>);
      pendingCount.value = results[1] as int;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
