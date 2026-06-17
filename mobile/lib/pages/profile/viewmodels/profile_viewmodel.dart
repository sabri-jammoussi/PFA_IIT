import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileViewModel extends GetxController {
  final Rx<UserProfile?> profile = Rx<UserProfile?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  String _userId = '';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final claims = await UserClaimsService.currentUser();
      _userId = claims.id;
      profile.value = await ProfileService.getProfile(_userId);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save(UserProfile updated) async {
    isSaving.value = true;
    try {
      final UserProfile result =
          await ProfileService.updateProfile(_userId, updated);
      profile.value = result;
      showThemedSnackbar('Profil mis à jour', '', type: SnackbarType.success);
    } catch (_) {
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> changePassword(String current, String newPassword) async {
    try {
      await ProfileService.changePassword(_userId, current, newPassword);
      showThemedSnackbar('Mot de passe modifié', '', type: SnackbarType.success);
    } catch (_) {}
  }
}
