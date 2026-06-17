import 'package:get/get.dart';
import '../models/dentist_stats_model.dart';
import '../services/dentist_dashboard_service.dart';

class DentistDashboardViewModel extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> todayAppointments =
      <Map<String, dynamic>>[].obs;
  final RxDouble revenue = 0.0.obs;

  DentistStats get stats {
    final int total = todayAppointments.length;
    final int completed = todayAppointments
        .where((a) =>
            (a['statut'] ?? a['status'] ?? '').toString().toLowerCase() ==
            'terminé')
        .length;
    return DentistStats(
      todayCount: total,
      completedCount: completed,
      pendingCount: total - completed,
      revenue: revenue.value,
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        DentistDashboardService.getTodayAppointments(),
        DentistDashboardService.getInvoices(),
      ]);
      todayAppointments.assignAll(results[0]);
      revenue.value = results[1].fold<double>(
        0.0,
        (sum, inv) =>
            sum + ((inv['montantTotal'] ?? inv['total'] ?? 0) as num).toDouble(),
      );
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
