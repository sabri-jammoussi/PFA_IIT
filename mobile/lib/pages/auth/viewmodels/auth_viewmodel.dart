import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/constants/user_role.dart';
import 'package:dentiflow/core/storage/secure_token_storage.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import '../services/auth_service.dart';

class AuthViewModel extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Forgot-password flow state
  final RxBool isResetMode = false.obs;
  final RxBool isResetLoading = false.obs;
  final RxString resetError = ''.obs;

  Future<void> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      errorMessage.value = 'Veuillez remplir tous les champs.';
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final String token = await AuthService.login(username.trim(), password);
      await SecureStorage.writeToken(token);
      final claims = UserClaimsService.fromToken(token);
      Get.offAllNamed(claims.role.landingRoute);
    } catch (e) {
      final String msg = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = msg.isNotEmpty ? msg : 'Identifiants invalides.';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleResetMode(bool value) {
    isResetMode.value = value;
    resetError.value = '';
    errorMessage.value = '';
  }

  Future<void> forgetPassword(String matriculeOrEmail) async {
    if (matriculeOrEmail.trim().isEmpty) {
      resetError.value = 'Veuillez saisir votre adresse email ou matricule.';
      return;
    }
    isResetLoading.value = true;
    resetError.value = '';
    try {
      await AuthService.forgetPassword(matriculeOrEmail.trim());
      showThemedSnackbar(
        'Demande envoyée',
        'Si un compte est associé à ce matricule, un email a été envoyé.',
        type: SnackbarType.success,
      );
      isResetMode.value = false;
    } catch (e) {
      final String msg = e.toString().replaceFirst('Exception: ', '');
      resetError.value =
          msg.isNotEmpty ? msg : "Une erreur est survenue lors de l'envoi.";
    } finally {
      isResetLoading.value = false;
    }
  }
}
