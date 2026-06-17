import 'package:get/get.dart';
import 'package:dentiflow/core/constants/user_role.dart';
import 'package:dentiflow/core/storage/secure_token_storage.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import '../services/auth_service.dart';

class AuthViewModel extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

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
}
