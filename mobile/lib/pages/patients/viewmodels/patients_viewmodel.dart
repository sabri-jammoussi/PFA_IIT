import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';

class PatientsViewModel extends GetxController {
  final RxList<Patient> patients = <Patient>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt totalCount = 0.obs;

  int _currentPage = 1;
  bool _hasMore = true;
  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadPatients();
  }

  Future<void> loadPatients({bool refresh = true}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      isLoading.value = true;
    } else {
      if (!_hasMore || isLoadingMore.value) return;
      isLoadingMore.value = true;
    }
    try {
      final List<Patient> result = await PatientService.getPatients(
        page: _currentPage,
        pageSize: _pageSize,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      if (refresh) {
        patients.assignAll(result);
      } else {
        patients.addAll(result);
      }
      _hasMore = result.length == _pageSize;
      _currentPage++;
      totalCount.value = patients.length;
    } catch (_) {
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> search(String query) async {
    searchQuery.value = query;
    await loadPatients();
  }

  Future<void> loadMore() => loadPatients(refresh: false);

  /// Adds a patient. When [invite] is true the backend also creates a portal
  /// account and emails an invitation (mirrors the Vue PatientAddDialog).
  Future<void> addPatient(Patient p, {bool invite = false}) async {
    try {
      if (invite) {
        await PatientService.invitePatient(p);
        showThemedSnackbar(
          'Patient créé & invité',
          'Le patient a été créé et l\'invitation e-mail a été envoyée.',
          type: SnackbarType.success,
        );
        await loadPatients();
      } else {
        final Patient created = await PatientService.addPatient(p);
        patients.insert(0, created);
        totalCount.value = patients.length;
        showThemedSnackbar('Patient créé', 'La nouvelle fiche patient a été ajoutée.',
            type: SnackbarType.success);
      }
    } catch (_) {}
  }

  Future<void> updatePatient(Patient p) async {
    try {
      final Patient updated = await PatientService.updatePatient(p);
      final int idx = patients.indexWhere((x) => x.id == p.id);
      if (idx != -1) patients[idx] = updated;
      showThemedSnackbar('Patient mis à jour', 'Les modifications ont été enregistrées.',
          type: SnackbarType.success);
    } catch (_) {}
  }

  Future<void> archivePatient(int id) async {
    try {
      await PatientService.archivePatient(id);
      patients.removeWhere((p) => p.id == id);
      totalCount.value = patients.length;
      showThemedSnackbar('Archivé', 'Le dossier patient a été archivé.',
          type: SnackbarType.success);
    } catch (_) {}
  }
}
