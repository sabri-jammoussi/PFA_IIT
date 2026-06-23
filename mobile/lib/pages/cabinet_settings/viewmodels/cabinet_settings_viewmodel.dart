import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/cabinet_settings_model.dart';
import '../services/cabinet_settings_service.dart';

class CabinetSettingsViewModel extends GetxController {
  final Rxn<CabinetSettings> settings = Rxn<CabinetSettings>();
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      settings.value = await CabinetSettingsService.getSettings();
    } catch (_) {
      settings.value ??= CabinetSettings();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save(CabinetSettings updated) async {
    isSaving.value = true;
    try {
      await CabinetSettingsService.saveSettings(updated);
      showThemedSnackbar(
        'Succès',
        'Configuration SMTP du cabinet mise à jour.',
        type: SnackbarType.success,
      );
      // Re-fetch so the password field resets and "stored" hint refreshes.
      await loadSettings();
    } catch (_) {
    } finally {
      isSaving.value = false;
    }
  }
}
