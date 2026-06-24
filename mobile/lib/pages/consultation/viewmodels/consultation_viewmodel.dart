import 'package:get/get.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import 'package:dentiflow/pages/stock/models/stock_model.dart';
import 'package:dentiflow/pages/stock/services/stock_service.dart';
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

  // Stock consumption + invoicing
  final RxList<ConsommationArticle> consommations = <ConsommationArticle>[].obs;
  final RxList<StockItem> articles = <StockItem>[].obs;
  final RxList<RecetteSuggestion> recetteSuggestions = <RecetteSuggestion>[].obs;
  final RxBool finalizing = false.obs;

  // Waiting room
  final RxList<WaitingEntry> waitingRoom = <WaitingEntry>[].obs;
  final RxBool loadingWaiting = false.obs;

  final RxBool isLoading = false.obs;
  final RxInt selectedTooth = (-1).obs;

  Future<void> loadWaitingRoom() async {
    loadingWaiting.value = true;
    try {
      final int dentisteId = await _currentDentisteId();
      waitingRoom.assignAll(await ConsultationService.getWaitingRoom(dentisteId));
    } catch (_) {
    } finally {
      loadingWaiting.value = false;
    }
  }

  /// Clears the active patient to return to the waiting-room list.
  void clearSelection() {
    selectedPatientId.value = 0;
    patient.value = null;
    consultations.clear();
    treatments.clear();
    prescriptions.clear();
    consommations.clear();
    recetteSuggestions.clear();
    selectedTooth.value = -1;
  }

  /// Most recent consultation = the session currently being worked on.
  int get activeConsultationId =>
      consultations.isNotEmpty ? consultations.first.id : 0;

  /// Total of the active visit's treatments = amount the secretary will collect.
  double get consultationTotal {
    final int cid = activeConsultationId;
    if (cid == 0) return 0;
    return treatments
        .where((t) => t.consultationId == cid)
        .fold(0.0, (sum, t) => sum + t.prixApplique);
  }

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
      recetteSuggestions.clear();
      await Future.wait([
        loadArticles(),
        loadConsommations(),
      ]);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadArticles() async {
    try {
      articles.assignAll(await StockService.getItems());
    } catch (_) {}
  }

  Future<void> loadConsommations() async {
    final int cid = activeConsultationId;
    if (cid == 0) {
      consommations.clear();
      return;
    }
    try {
      consommations.assignAll(await ConsultationService.getConsommations(cid));
    } catch (_) {
      consommations.clear();
    }
  }

  /// Loads the editable consumable suggestions for the selected act.
  Future<void> loadRecette(int acteMedicalId) async {
    try {
      recetteSuggestions.assignAll(await ConsultationService.getRecette(acteMedicalId));
    } catch (_) {
      recetteSuggestions.clear();
    }
  }

  Future<void> addConsommation({required int articleId, required int quantite}) async {
    final int consultationId =
        await _ensureActiveConsultation('Séance de soins');
    await ConsultationService.addConsommation(
      consultationId: consultationId,
      articleId: articleId,
      quantite: quantite,
    );
    // Refresh consultations (in case one was just created) then dependent lists.
    await loadForPatient(selectedPatientId.value);
  }

  Future<void> deleteConsommation(int id) async {
    await ConsultationService.deleteConsommation(id);
    await Future.wait([loadConsommations(), loadArticles()]);
  }

  /// Closes the consultation: generates one invoice and notifies the secretary.
  /// Returns the created invoice payload, or null on failure / nothing to bill.
  Future<Map<String, dynamic>?> finalize() async {
    final int cid = activeConsultationId;
    if (cid == 0) return null;
    finalizing.value = true;
    try {
      return await ConsultationService.finalizeConsultation(cid);
    } finally {
      finalizing.value = false;
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
