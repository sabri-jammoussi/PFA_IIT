import 'dart:async';

import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/secretaire_model.dart';
import '../services/secretaires_service.dart';

class SecretairesViewModel extends GetxController {
  final RxList<Secretaire> secretaires = <Secretaire>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString search = ''.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadSecretaires();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void onSearchChanged(String value) {
    search.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), loadSecretaires);
  }

  Future<void> loadSecretaires() async {
    isLoading.value = true;
    try {
      final List<Secretaire> list =
          await SecretairesService.getSecretaires(search: search.value);
      secretaires.assignAll(list);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createSecretaire({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    String? username,
  }) async {
    isSubmitting.value = true;
    try {
      await SecretairesService.createSecretaire(
        nom: nom,
        prenom: prenom,
        email: email,
        password: password,
        username: username,
      );
      showThemedSnackbar(
        'Secrétaire ajoutée',
        "Le compte a été créé. Un e-mail d'invitation avec les identifiants a été envoyé à $email.",
        type: SnackbarType.success,
      );
      await loadSecretaires();
      return true;
    } catch (_) {
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateSecretaire({
    required Secretaire original,
    required String nom,
    required String prenom,
    required String email,
    required bool isActive,
    String? username,
    String? password,
  }) async {
    isSubmitting.value = true;
    try {
      await SecretairesService.updateSecretaire(
        id: original.id,
        nom: nom,
        prenom: prenom,
        email: email,
        isActive: isActive,
        username: username,
        password: password,
      );
      showThemedSnackbar(
        'Secrétaire modifiée',
        'Le profil de $prenom $nom a été mis à jour.',
        type: SnackbarType.success,
      );
      await loadSecretaires();
      return true;
    } catch (_) {
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteSecretaire(Secretaire s) async {
    try {
      await SecretairesService.deleteSecretaire(s.id);
      secretaires.remove(s);
      showThemedSnackbar(
        'Compte supprimé',
        'Le compte de ${s.displayName} a été supprimé avec succès.',
        type: SnackbarType.success,
      );
    } catch (_) {}
  }
}
