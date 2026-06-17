import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/medical_act_model.dart';
import '../services/medical_acts_service.dart';

class MedicalActsViewModel extends GetxController {
  final RxList<MedicalAct> acts = <MedicalAct>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadActs();
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
      showThemedSnackbar('Acte mis à jour', a.libelle, type: SnackbarType.success);
    } catch (_) {}
  }
}
