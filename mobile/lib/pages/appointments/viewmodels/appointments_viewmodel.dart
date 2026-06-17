import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentsViewModel extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<Appointment> appointments = <Appointment>[].obs;
  final RxList<Appointment> pendingRequests = <Appointment>[].obs;
  final RxList<Dentist> dentists = <Dentist>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAppointments(selectedDate.value);
    loadPending();
    loadDentists();
  }

  Future<void> loadAppointments(DateTime date) async {
    selectedDate.value = date;
    isLoading.value = true;
    try {
      appointments.assignAll(
          await AppointmentService.getAppointments(start: date, end: date));
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPending() async {
    try {
      pendingRequests.assignAll(await AppointmentService.getPendingRequests());
    } catch (_) {}
  }

  Future<void> loadDentists() async {
    try {
      dentists.assignAll(await AppointmentService.getDentists());
    } catch (_) {}
  }

  Future<void> addAppointment(Appointment a) async {
    try {
      final Appointment created = await AppointmentService.addAppointment(a);
      appointments.add(created);
      showThemedSnackbar('Rendez-vous ajouté', '', type: SnackbarType.success);
    } catch (_) {}
  }

  Future<void> cancelAppointment(int id) async {
    try {
      await AppointmentService.cancelAppointment(id);
      appointments.removeWhere((a) => a.id == id);
      showThemedSnackbar('Annulé', 'Rendez-vous annulé.', type: SnackbarType.success);
    } catch (_) {}
  }

  Future<void> approveRequest(int id) async {
    try {
      await AppointmentService.approveRequest(id);
      pendingRequests.removeWhere((a) => a.id == id);
      await loadAppointments(selectedDate.value);
      showThemedSnackbar('Approuvé', '', type: SnackbarType.success);
    } catch (_) {}
  }

  void goToPrevDay() => loadAppointments(
      selectedDate.value.subtract(const Duration(days: 1)));
  void goToNextDay() =>
      loadAppointments(selectedDate.value.add(const Duration(days: 1)));
  void goToToday() => loadAppointments(DateTime.now());
}
