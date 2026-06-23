import 'dart:async';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentsViewModel extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<Appointment> appointments = <Appointment>[].obs;
  final RxList<Appointment> pendingRequests = <Appointment>[].obs;
  final RxList<Dentist> dentists = <Dentist>[].obs;
  final Rxn<int> selectedDentistId = Rxn<int>();
  final RxBool isLoading = false.obs;
  final RxBool isLoadingPending = false.obs;

  /// Ticks every 30s so "imminent" badges refresh without a manual reload.
  final Rx<DateTime> now = DateTime.now().obs;
  Timer? _ticker;

  /// Standard consultation slots (matches the web agenda grid).
  static const List<String> timeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30',
  ];

  @override
  void onInit() {
    super.onInit();
    _ticker = Timer.periodic(
        const Duration(seconds: 30), (_) => now.value = DateTime.now());
    loadDentists();
    loadAppointments(selectedDate.value);
    loadPending();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  /// Active appointments (cancelled ones are excluded from slot/conflict logic).
  List<Appointment> get _activeAppointments =>
      appointments.where((a) => !a.isAnnule).toList();

  /// Time strings ("HH:mm") already booked by an active appointment.
  Set<String> get _bookedTimes =>
      _activeAppointments.map((a) => a.formattedTime).toSet();

  /// Free slots = standard slots not already booked.
  List<String> get availableSlots =>
      timeSlots.where((s) => !_bookedTimes.contains(s)).toList();

  /// True when two active appointments share the exact same start time.
  bool get hasConflict {
    final times = _activeAppointments.map((a) => a.formattedTime).toList();
    return times.length != times.toSet().length;
  }

  Future<void> loadAppointments(DateTime date) async {
    selectedDate.value = date;
    isLoading.value = true;
    try {
      appointments.assignAll(await AppointmentService.getAppointments(
        date: date,
        dentisteId: selectedDentistId.value,
      ));
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAppointments() => loadAppointments(selectedDate.value);

  Future<void> loadPending() async {
    isLoadingPending.value = true;
    try {
      pendingRequests.assignAll(await AppointmentService.getPendingRequests());
    } catch (_) {
    } finally {
      isLoadingPending.value = false;
    }
  }

  Future<void> loadDentists() async {
    try {
      dentists.assignAll(await AppointmentService.getDentists());
      if (selectedDentistId.value == null && dentists.isNotEmpty) {
        selectedDentistId.value = dentists.first.id;
      }
    } catch (_) {}
  }

  void setDentist(int? id) {
    selectedDentistId.value = id;
    refreshAppointments();
  }

  Future<bool> addAppointment(Appointment a) async {
    try {
      await AppointmentService.addAppointment(a);
      await refreshAppointments();
      showThemedSnackbar('Rendez-vous planifié',
          'Le rendez-vous a été enregistré.',
          type: SnackbarType.success);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> cancelAppointment(int id) async {
    try {
      await AppointmentService.cancelAppointment(id);
      appointments.removeWhere((a) => a.id == id);
      showThemedSnackbar('Annulé', 'Rendez-vous annulé.',
          type: SnackbarType.success);
    } catch (_) {}
  }

  Future<void> confirmArrival(int id) async {
    try {
      await AppointmentService.confirmArrival(id);
      await refreshAppointments();
      showThemedSnackbar('Arrivée confirmée', 'Le médecin a été notifié.',
          type: SnackbarType.success);
    } catch (_) {}
  }

  /// Accept a pending request and schedule it -> status Planifie (PUT full DTO).
  Future<bool> acceptAndSchedule(Appointment scheduled) async {
    try {
      await AppointmentService.updateAppointment(scheduled);
      pendingRequests.removeWhere((a) => a.id == scheduled.id);
      await refreshAppointments();
      showThemedSnackbar('Rendez-vous planifié',
          'La demande a été acceptée et planifiée.',
          type: SnackbarType.success);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Reject / propose another slot -> status Annule (PUT full DTO).
  Future<bool> rejectRequest(Appointment req, {String? note}) async {
    try {
      final rejected = Appointment(
        id: req.id,
        patientId: req.patientId,
        dentisteId: req.dentisteId,
        dateHeure: req.dateHeure,
        dureeEstimee: req.dureeEstimee,
        motif: req.motif,
        note: note ?? 'Rejeté par le secrétariat (créneau indisponible)',
        statut: 'Annule',
      );
      await AppointmentService.updateAppointment(rejected);
      pendingRequests.removeWhere((a) => a.id == req.id);
      showThemedSnackbar('Demande rejetée',
          'La demande de rendez-vous a été annulée.',
          type: SnackbarType.info);
      return true;
    } catch (_) {
      return false;
    }
  }

  void goToPrevDay() =>
      loadAppointments(selectedDate.value.subtract(const Duration(days: 1)));
  void goToNextDay() =>
      loadAppointments(selectedDate.value.add(const Duration(days: 1)));
  void goToToday() => loadAppointments(DateTime.now());
}
