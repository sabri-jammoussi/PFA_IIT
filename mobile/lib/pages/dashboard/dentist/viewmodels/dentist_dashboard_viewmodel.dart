import 'package:get/get.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import '../models/dentist_stats_model.dart';
import '../services/dentist_dashboard_service.dart';

class DentistDashboardViewModel extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> todayAppointments =
      <Map<String, dynamic>>[].obs;
  final RxDouble revenue = 0.0.obs;
  final Rxn<NextPatient> nextPatient = Rxn<NextPatient>();

  // Header info (greeting + cabinet)
  final RxString doctorName = ''.obs;
  final RxString cabinetName = ''.obs;

  static const double _averageFeeFallback = 120.0;

  static bool _isCompleted(String s) {
    final v = s.toLowerCase();
    return v == 'termine' ||
        v == 'terminé' ||
        v == 'confirme' ||
        v == 'confirmé';
  }

  static bool _isUrgent(String? motif) {
    if (motif == null) return false;
    final m = motif.toLowerCase();
    return m.contains('urg') ||
        m.contains('pain') ||
        m.contains('mal') ||
        m.contains('douleur') ||
        m.contains('accident');
  }

  static bool _isPlanned(String s) {
    final v = s.toLowerCase();
    return v == 'planifie' || v == 'planifié';
  }

  static String _fmtTime(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }

  DentistStats get stats {
    final list = todayAppointments;
    final int total = list.length;
    final int completed = list
        .where((a) => _isCompleted((a['statut'] ?? a['status'] ?? '').toString()))
        .length;
    final int urgences =
        list.where((a) => _isUrgent(a['motif']?.toString())).length;
    return DentistStats(
      todayCount: total,
      completedCount: completed,
      pendingCount: total - completed,
      urgencesCount: urgences,
      revenue: revenue.value,
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> _loadUser() async {
    final UserClaims user = await UserClaimsService.currentUser();
    final String name = user.nom.isNotEmpty
        ? user.nom
        : (user.displayName.isNotEmpty ? user.displayName : 'Praticien');
    doctorName.value = name;
    cabinetName.value = user.cabinetName;
  }

  void _computeNextPatient() {
    final list = todayAppointments;
    if (list.isEmpty) {
      nextPatient.value = NextPatient.none();
      return;
    }
    final now = DateTime.now();
    Map<String, dynamic>? pick;
    for (final a in list) {
      final iso = (a['dateHeure'] ?? '').toString();
      DateTime? dt;
      try {
        dt = DateTime.parse(iso).toLocal();
      } catch (_) {}
      if (dt != null &&
          dt.isAfter(now) &&
          _isPlanned((a['statut'] ?? '').toString())) {
        pick = a;
        break;
      }
    }
    pick ??= list.first;
    nextPatient.value = NextPatient(
      name: (pick['patientNomComplet'] ??
              pick['patientNom'] ??
              pick['patient'] ??
              'Patient')
          .toString(),
      motif: (pick['motif'] ?? 'Non spécifié').toString(),
      time: _fmtTime((pick['dateHeure'] ?? '').toString()),
    );
  }

  void _computeRevenue(List<Map<String, dynamic>> invoices) {
    final now = DateTime.now();
    final String today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final double todayTotal = invoices
        .where((f) =>
            (f['dateEmission'] ?? f['dateFacture'] ?? '')
                .toString()
                .startsWith(today))
        .fold<double>(
            0.0,
            (sum, f) =>
                sum + ((f['montantTotal'] ?? f['total'] ?? 0) as num).toDouble());

    if (todayTotal == 0 && stats.completedCount > 0) {
      // Fallback estimate, matching the Vue dashboard behaviour.
      revenue.value = stats.completedCount * _averageFeeFallback;
    } else {
      revenue.value = todayTotal;
    }
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await _loadUser();
      final UserClaims user = await UserClaimsService.currentUser();
      final results = await Future.wait([
        DentistDashboardService.getTodayAppointments(
            dentisteId: user.id.isNotEmpty ? user.id : null),
        DentistDashboardService.getInvoices(),
      ]);
      todayAppointments.assignAll(results[0]);
      _computeNextPatient();
      _computeRevenue(results[1]);
    } catch (_) {
      nextPatient.value ??= NextPatient.none();
    } finally {
      isLoading.value = false;
    }
  }
}
