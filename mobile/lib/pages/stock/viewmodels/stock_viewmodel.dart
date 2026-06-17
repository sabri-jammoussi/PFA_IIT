import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/stock_model.dart';
import '../services/stock_service.dart';

class StockViewModel extends GetxController {
  final RxList<StockItem> items = <StockItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    isLoading.value = true;
    try {
      items.assignAll(await StockService.getItems());
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addItem(StockItem i) async {
    try {
      final StockItem created = await StockService.addItem(i);
      items.insert(0, created);
      showThemedSnackbar('Article ajouté', i.libelle, type: SnackbarType.success);
    } catch (_) {}
  }

  Future<void> updateItem(StockItem i) async {
    try {
      final StockItem updated = await StockService.updateItem(i);
      final int idx = items.indexWhere((x) => x.id == i.id);
      if (idx != -1) items[idx] = updated;
      showThemedSnackbar('Article mis à jour', i.libelle,
          type: SnackbarType.success);
    } catch (_) {}
  }
}
