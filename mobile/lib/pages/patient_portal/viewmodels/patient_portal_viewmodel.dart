import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/patient_portal_model.dart';
import '../services/patient_portal_service.dart';

class PatientPortalViewModel extends GetxController {
  final RxList<MyAppointment> myAppointments = <MyAppointment>[].obs;
  final Rx<MedicalRecordSummary?> medicalRecord =
      Rx<MedicalRecordSummary?>(null);
  final RxList<String> availableSlots = <String>[].obs;
  final RxList<Map<String, dynamic>> dentists =
      <Map<String, dynamic>>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt selectedDentisteId = 0.obs;
  final RxString selectedSlot = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingSlots = false.obs;
  final RxBool isRequesting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        PatientPortalService.getMyAppointments(),
        PatientPortalService.getMedicalRecord(),
        PatientPortalService.getDentists(),
      ]);
      myAppointments.assignAll(results[0] as List<MyAppointment>);
      medicalRecord.value = results[1] as MedicalRecordSummary?;
      dentists.assignAll(results[2] as List<Map<String, dynamic>>);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAvailability() async {
    if (selectedDentisteId.value == 0) return;
    isLoadingSlots.value = true;
    availableSlots.clear();
    selectedSlot.value = '';
    try {
      final Availability? avail = await PatientPortalService.getAvailability(
          selectedDate.value, selectedDentisteId.value);
      if (avail != null) availableSlots.assignAll(avail.slots);
    } catch (_) {
    } finally {
      isLoadingSlots.value = false;
    }
  }

  Future<void> requestAppointment(String motif) async {
    if (selectedDentisteId.value == 0 || selectedSlot.value.isEmpty) {
      showThemedSnackbar('Informations manquantes',
          'Sélectionnez un dentiste et un créneau.',
          type: SnackbarType.warning);
      return;
    }
    isRequesting.value = true;
    try {
      final DateTime date = selectedDate.value;
      final List<String> parts = selectedSlot.value.split(':');
      final DateTime dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.tryParse(parts[0]) ?? 9,
        int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      );
      await PatientPortalService.requestAppointment(
        dentisteId: selectedDentisteId.value,
        dateHeure: dateTime.toIso8601String(),
        motif: motif,
      );
      showThemedSnackbar('Demande envoyée',
          'Votre demande de rendez-vous a été soumise.',
          type: SnackbarType.success);
      selectedSlot.value = '';
      await loadAll();
    } catch (_) {
    } finally {
      isRequesting.value = false;
    }
  }
}
