import 'package:get/get.dart';
import '../services/admin_service.dart';

class AdminViewModel extends GetxController {
  final RxList<Map<String, dynamic>> cabinets = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  int get cabinetsCount => cabinets.length;
  List<Map<String, dynamic>> get recentCabinets =>
      cabinets.reversed.take(3).toList();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final List<Map<String, dynamic>> list = await AdminService.getCabinets();
      cabinets.assignAll(list);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
