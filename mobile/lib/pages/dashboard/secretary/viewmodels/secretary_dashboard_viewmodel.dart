import 'package:get/get.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import '../services/secretary_dashboard_service.dart';

class SecretaryDashboardViewModel extends GetxController {
  final RxList<Map<String, dynamic>> todayAppointments =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> pendingRequests =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  // Billing summary
  final RxInt unpaidCount = 0.obs;
  final RxDouble unpaidTotal = 0.0.obs;

  // Header info
  final RxString fullName = ''.obs;
  final RxString cabinetName = ''.obs;

  int get pendingCount => pendingRequests.length;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> _loadUser() async {
    final UserClaims user = await UserClaimsService.currentUser();
    fullName.value =
        user.displayName.isNotEmpty ? user.displayName : 'Secrétaire';
    cabinetName.value = user.cabinetName;
  }

  void _computeBilling(List<Map<String, dynamic>> invoices) {
    double total = 0;
    int count = 0;
    for (final f in invoices) {
      final double montant =
          ((f['montantTotal'] ?? f['total'] ?? 0) as num).toDouble();
      final double paye =
          ((f['montantPaye'] ?? f['paye'] ?? 0) as num).toDouble();
      final double balance = montant - paye;
      if (balance > 0.0001) {
        count++;
        total += balance;
      }
    }
    unpaidCount.value = count;
    unpaidTotal.value = total;
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await _loadUser();
      final results = await Future.wait([
        SecretaryDashboardService.getTodayAppointments(),
        SecretaryDashboardService.getPendingRequests(),
        SecretaryDashboardService.getInvoices(),
      ]);
      todayAppointments.assignAll(results[0]);
      pendingRequests.assignAll(results[1]);
      _computeBilling(results[2]);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
