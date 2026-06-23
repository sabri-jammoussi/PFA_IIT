import 'package:get/get.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import '../models/consultation_model.dart';
import '../services/consultation_service.dart';

/// Tooth clinical status, mirrors the Vue getToothStatus():
/// - healthy: no treatment recorded
/// - treated: has at least one treatment
/// - alarm:   has a root-canal ("canal") or extraction act
enum ToothStatus { healthy, treated, alarm }

class ConsultationViewModel extends GetxController {
  final RxInt selectedPatientId = 0.obs;
  final Rx<PatientClinical?> patient = Rx<PatientClinical?>(null);

  final RxList<Consultation> consultations = <Consultation>[].obs;
  final RxList<Treatment> treatments = <Treatment>[].obs;
  final RxList<Prescription> prescriptions = <Prescription>[].obs;

  final RxBool isLoading = false.obs;
  final RxInt selectedTooth = (-1).obs;

  void selectTooth(int toothNumber) {
    selectedTooth.value =
        selectedTooth.value == toothNumber ? -1 : toothNumber;
  }

  /// Treatments recorded on a given tooth.
  List<Treatment> treatmentsForTooth(int tooth) =>
      treatments.where((t) => t.numeroDent == tooth).toList();

  int treatmentCountFor(int tooth) =>
      treatments.where((t) => t.numeroDent == tooth).length;

  ToothStatus statusFor(int tooth) {
    final List<Treatment> list = treatmentsForTooth(tooth);
    if (list.isEmpty) return ToothStatus.healthy;
    final bool critical = list.any((t) {
      final String l = (t.acteMedicalLibelle ?? '').toLowerCase();
      return l.contains('canal') || l.contains('extraction');
    });
    return critical ? ToothStatus.alarm : ToothStatus.treated;
  }

  Future<void> loadForPatient(int patientId) async {
    selectedPatientId.value = patientId;
    isLoading.value = true;
    selectedTooth.value = -1;
    try {
      final results = await Future.wait([
        ConsultationService.getPatient(patientId),
        ConsultationService.getConsultations(patientId),
        ConsultationService.getTreatments(patientId),
        ConsultationService.getPrescriptions(patientId),
      ]);
      patient.value = results[0] as PatientClinical;
      consultations.assignAll(results[1] as List<Consultation>);
      treatments.assignAll(results[2] as List<Treatment>);
      prescriptions.assignAll(results[3] as List<Prescription>);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> _currentDentisteId() async {
    final claims = await UserClaimsService.currentUser();
    return int.tryParse(claims.id) ?? 0;
  }

  /// Returns an active consultation id for the selected patient, reusing the
  /// most recent one or creating a fresh "session" consultation if none exist.
  /// Mirrors the Vue auto-create behaviour.
  Future<int> _ensureActiveConsultation(String defaultNote) async {
    if (consultations.isNotEmpty && consultations.first.id > 0) {
      return consultations.first.id;
    }
    final int dentisteId = await _currentDentisteId();
    final int id = await ConsultationService.addConsultation(Consultation(
      id: 0,
      patientId: selectedPatientId.value,
      dentisteId: dentisteId,
      dateConsultation: DateTime.now().toUtc().toIso8601String(),
      notesObservations: defaultNote,
    ));
    return id;
  }

  /// Records a treatment on the selected tooth (auto-binds a consultation).
  Future<void> addTreatment({
    required int acteMedicalId,
    required int numeroDent,
    required String faceDentaire,
    required double prixApplique,
    String? notes,
  }) async {
    final int consultationId =
        await _ensureActiveConsultation('Session ouverte pour soins cliniques');
    await ConsultationService.addTreatment(Treatment(
      id: 0,
      numeroDent: numeroDent,
      faceDentaire: faceDentaire,
      prixApplique: prixApplique,
      notes: (notes == null || notes.trim().isEmpty) ? null : notes.trim(),
      consultationId: consultationId,
      acteMedicalId: acteMedicalId,
    ));
    await loadForPatient(selectedPatientId.value);
  }

  /// Saves a new clinical-notes consultation entry (journal).
  Future<void> addClinicalNote(String note) async {
    final int dentisteId = await _currentDentisteId();
    await ConsultationService.addConsultation(Consultation(
      id: 0,
      patientId: selectedPatientId.value,
      dentisteId: dentisteId,
      dateConsultation: DateTime.now().toUtc().toIso8601String(),
      notesObservations: note.trim(),
    ));
    await loadForPatient(selectedPatientId.value);
  }

  /// Saves a prescription (ordonnance) bound to an active consultation.
  Future<void> addPrescription(String traitement) async {
    final int consultationId =
        await _ensureActiveConsultation('Séance ordonnance');
    await ConsultationService.addPrescription(Prescription(
      id: 0,
      consultationId: consultationId,
      dateEmission: DateTime.now().toUtc().toIso8601String(),
      traitement: traitement.trim(),
    ));
    await loadForPatient(selectedPatientId.value);
  }
}
