import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../services/auth_service.dart';

class RegisterClinicViewModel extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool success = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> register({
    required String nomCabinet,
    String? adresse,
    required String doctorNom,
    required String doctorPrenom,
    required String doctorEmail,
    required String doctorPassword,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await AuthService.registerClinic(
        nomCabinet: nomCabinet.trim(),
        adresse: adresse,
        doctorNom: doctorNom.trim(),
        doctorPrenom: doctorPrenom.trim(),
        doctorEmail: doctorEmail.trim(),
        doctorPassword: doctorPassword,
      );
      success.value = true;
      showThemedSnackbar(
        'Inscription réussie',
        'Votre cabinet a été créé avec succès.',
        type: SnackbarType.success,
      );
    } catch (e) {
      final String msg = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = msg.isNotEmpty
          ? msg
          : "Une erreur s'est produite lors de l'enregistrement.";
    } finally {
      isLoading.value = false;
    }
  }
}
