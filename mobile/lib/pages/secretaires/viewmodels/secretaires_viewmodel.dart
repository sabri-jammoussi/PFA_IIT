import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/secretaire_model.dart';
import '../services/secretaires_service.dart';

class SecretairesViewModel extends GetxController {
  final RxList<Secretaire> secretaires = <Secretaire>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSecretaires();
  }

  Future<void> loadSecretaires() async {
    isLoading.value = true;
    try {
      final List<Secretaire> list = await SecretairesService.getSecretaires();
      secretaires.assignAll(list);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSecretaire({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    isSubmitting.value = true;
    try {
      await SecretairesService.createSecretaire(
        nom: nom,
        prenom: prenom,
        email: email,
        password: password,
      );
      showThemedSnackbar('Succès', 'Secrétaire ajouté(e) avec succès.',
          type: SnackbarType.success);
      await loadSecretaires();
    } catch (_) {
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> toggleActive(Secretaire s) async {
    try {
      await SecretairesService.toggleActive(s.id, !s.isActive);
      await loadSecretaires();
      showThemedSnackbar(
        'Mise à jour',
        '${s.displayName} est maintenant ${!s.isActive ? 'activé(e)' : 'désactivé(e)'}.',
        type: SnackbarType.success,
      );
    } catch (_) {}
  }

  Future<void> deleteSecretaire(Secretaire s) async {
    try {
      await SecretairesService.deleteSecretaire(s.id);
      secretaires.remove(s);
      showThemedSnackbar('Supprimé', '${s.displayName} a été supprimé(e).',
          type: SnackbarType.success);
    } catch (_) {}
  }
}
