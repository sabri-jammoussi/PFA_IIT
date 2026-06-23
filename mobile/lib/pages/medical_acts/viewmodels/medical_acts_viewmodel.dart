import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/constants/user_role.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import '../models/medical_act_model.dart';
import '../services/medical_acts_service.dart';

class MedicalActsViewModel extends GetxController {
  final RxList<MedicalAct> acts = <MedicalAct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString search = ''.obs;

  // Only the Dentiste may create / edit / delete — the backend gates
  // POST/PUT/DELETE on /actes-medicaux to the Dentiste role (Secretaire is
  // read-only). The UI hides those affordances accordingly.
  final RxBool canManage = false.obs;

  @override
  void onInit() {
    super.onInit();
    _resolveRole();
    loadActs();
  }

  Future<void> _resolveRole() async {
    final UserClaims user = await UserClaimsService.currentUser();
    canManage.value = user.role == UserRole.dentist;
  }

  /// Acts filtered by the current search term (libellé or code nomenclature).
  List<MedicalAct> get filteredActs {
    final String q = search.value.trim().toLowerCase();
    if (q.isEmpty) return acts;
    return acts
        .where((a) =>
            a.libelle.toLowerCase().contains(q) ||
            (a.codeNomenclature?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  Future<void> loadActs() async {
    isLoading.value = true;
    try {
      acts.assignAll(await MedicalActsService.getActs());
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAct(MedicalAct a) async {
    try {
      final MedicalAct created = await MedicalActsService.addAct(a);
      acts.insert(0, created);
      showThemedSnackbar('Acte ajouté', a.libelle, type: SnackbarType.success);
    } catch (_) {}
  }

  Future<void> updateAct(MedicalAct a) async {
    try {
      final MedicalAct updated = await MedicalActsService.updateAct(a);
      final int idx = acts.indexWhere((x) => x.id == a.id);
      if (idx != -1) acts[idx] = updated;
      showThemedSnackbar('Acte mis à jour', a.libelle,
          type: SnackbarType.success);
    } catch (_) {}
  }

  Future<void> deleteAct(MedicalAct a) async {
    try {
      await MedicalActsService.deleteAct(a.id);
      acts.removeWhere((x) => x.id == a.id);
      showThemedSnackbar('Acte supprimé', a.libelle,
          type: SnackbarType.success);
    } catch (_) {}
  }
}
