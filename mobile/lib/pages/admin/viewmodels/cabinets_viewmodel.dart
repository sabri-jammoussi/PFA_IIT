import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../services/admin_service.dart';

class CabinetsViewModel extends GetxController {
  final RxList<Map<String, dynamic>> cabinets = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxSet<int> processing = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadCabinets();
  }

  Future<void> loadCabinets() async {
    isLoading.value = true;
    try {
      final list = await AdminService.getCabinets();
      cabinets.assignAll(list);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleSubscription(Map<String, dynamic> cabinet) async {
    final int id = (cabinet['id'] ?? 0) as int;
    final bool currentlyActive = (cabinet['isSubscriptionActive'] ?? true) as bool;
    processing.add(id);
    try {
      await AdminService.toggleSubscription(id, !currentlyActive);
      // Update local state
      final int idx = cabinets.indexWhere((c) => c['id'] == id);
      if (idx != -1) {
        cabinets[idx] = {
          ...cabinets[idx],
          'isSubscriptionActive': !currentlyActive,
        };
      }
      showThemedSnackbar(
        !currentlyActive ? 'Licence activée' : 'Licence suspendue',
        'La souscription de ${cabinet['nomCabinet']} a été mise à jour.',
        type: SnackbarType.success,
      );
    } catch (_) {
    } finally {
      processing.remove(id);
    }
  }
}
