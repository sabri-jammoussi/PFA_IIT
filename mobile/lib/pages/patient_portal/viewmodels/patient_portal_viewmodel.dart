import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import '../models/patient_portal_model.dart';
import '../services/patient_portal_service.dart';

class PatientPortalViewModel extends GetxController {
  final RxList<MyAppointment> myAppointments = <MyAppointment>[].obs;

  // Header info (greeting + cabinet)
  final RxString patientName = ''.obs;
  final RxString cabinetName = ''.obs;
  final Rx<FullMedicalRecord?> fullMedicalRecord =
      Rx<FullMedicalRecord?>(null);
  final RxList<AppointmentSlot> availableSlots = <AppointmentSlot>[].obs;
  final RxList<Map<String, dynamic>> dentists =
      <Map<String, dynamic>>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt selectedDentisteId = 0.obs;
  final Rx<AppointmentSlot?> selectedSlot = Rx<AppointmentSlot?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingSlots = false.obs;
  final RxBool isRequesting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  // ─── KPI getters (mirror the Vue dashboard cards) ────────────────────────

  /// Soonest upcoming, non-cancelled, non-finished appointment.
  MyAppointment? get nextAppointment {
    final upcoming = myAppointments
        .where((a) => a.isUpcomingStatus && !a.isPast && a.dateTime != null)
        .toList()
      ..sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  int get totalConsultations =>
      fullMedicalRecord.value?.consultations.length ?? 0;

  int get totalPrescriptions =>
      fullMedicalRecord.value?.prescriptions.length ?? 0;

  double get outstandingBalance =>
      (fullMedicalRecord.value?.invoices ?? [])
          .fold(0.0, (s, inv) => s + inv.reste);

  List<MyAppointment> get upcomingAppointments => myAppointments
      .where((a) => a.isUpcomingStatus && !a.isPast)
      .toList()
    ..sort((a, b) {
      final da = a.dateTime, db = b.dateTime;
      if (da == null || db == null) return 0;
      return da.compareTo(db);
    });

  List<MyAppointment> get pastAppointments => myAppointments
      .where((a) => !(a.isUpcomingStatus && !a.isPast))
      .toList();

  // ─── Loading ─────────────────────────────────────────────────────────────

  Future<void> _loadUser() async {
    try {
      final UserClaims user = await UserClaimsService.currentUser();
      patientName.value =
          user.displayName.isNotEmpty ? user.displayName : 'Patient';
      cabinetName.value = user.cabinetName;
    } catch (_) {}
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      await _loadUser();
      final results = await Future.wait([
        PatientPortalService.getMyAppointments(),
        PatientPortalService.getDentists(),
        PatientPortalService.getFullMedicalRecord(),
      ]);
      myAppointments.assignAll(results[0] as List<MyAppointment>);
      dentists.assignAll(results[1] as List<Map<String, dynamic>>);
      fullMedicalRecord.value = results[2] as FullMedicalRecord?;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAvailability() async {
    if (selectedDentisteId.value == 0) return;
    isLoadingSlots.value = true;
    availableSlots.clear();
    selectedSlot.value = null;
    try {
      final List<AppointmentSlot> slots =
          await PatientPortalService.getAvailability(
              selectedDate.value, selectedDentisteId.value);
      availableSlots.assignAll(slots);
    } catch (_) {
    } finally {
      isLoadingSlots.value = false;
    }
  }

  Future<void> requestAppointment(String motif, {String note = ''}) async {
    if (selectedDentisteId.value == 0 ||
        selectedSlot.value == null ||
        motif.trim().isEmpty) {
      showThemedSnackbar('Formulaire incomplet',
          'Sélectionnez un dentiste, un créneau et saisissez le motif.',
          type: SnackbarType.warning);
      return;
    }
    isRequesting.value = true;
    try {
      // Prefer the slot's own dateTime (already includes the date + time).
      String dateHeure = selectedSlot.value!.dateTime;
      if (dateHeure.isEmpty) {
        final DateTime date = selectedDate.value;
        final List<String> parts = selectedSlot.value!.time.split(':');
        final DateTime dt = DateTime(
          date.year,
          date.month,
          date.day,
          int.tryParse(parts.isNotEmpty ? parts[0] : '9') ?? 9,
          int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
        );
        dateHeure = dt.toIso8601String();
      } else {
        // Normalize to ISO with timezone for consistency with the web client.
        dateHeure =
            (DateTime.tryParse(dateHeure) ?? DateTime.now()).toIso8601String();
      }
      await PatientPortalService.requestAppointment(
        dentisteId: selectedDentisteId.value,
        dateHeure: dateHeure,
        motif: motif.trim(),
        note: note.trim(),
      );
      showThemedSnackbar('Demande envoyée',
          'Votre demande de rendez-vous a été soumise au secrétariat. En attente de confirmation.',
          type: SnackbarType.success);
      _resetBooking();
      await loadAll();
    } catch (_) {
    } finally {
      isRequesting.value = false;
    }
  }

  void _resetBooking() {
    selectedSlot.value = null;
    selectedDentisteId.value = 0;
    selectedDate.value = DateTime.now();
    availableSlots.clear();
  }
}
