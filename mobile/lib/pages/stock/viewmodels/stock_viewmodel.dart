import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/stock_model.dart';
import '../services/stock_service.dart';

class StockViewModel extends GetxController {
  final RxList<StockItem> items = <StockItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString search = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  /// Articles at or under the alert threshold (critical / out-of-stock).
  int get lowStockCount => items.where((a) => a.isLowStock).length;

  List<StockItem> get filtered {
    final String term = search.value.trim().toLowerCase();
    if (term.isEmpty) return items.toList();
    return items.where((a) {
      return a.nom.toLowerCase().contains(term) ||
          (a.description?.toLowerCase().contains(term) ?? false) ||
          a.unite.toLowerCase().contains(term);
    }).toList();
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
      showThemedSnackbar('Article créé', i.nom, type: SnackbarType.success);
    } catch (_) {}
  }

  Future<void> updateItem(StockItem i) async {
    try {
      final StockItem updated = await StockService.updateItem(i);
      final int idx = items.indexWhere((x) => x.id == i.id);
      if (idx != -1) items[idx] = updated;
      items.refresh();
      showThemedSnackbar('Article mis à jour', i.nom,
          type: SnackbarType.success);
    } catch (_) {}
  }

  Future<void> restock(int id, int quantiteAjoutee) async {
    try {
      await StockService.restock(id, quantiteAjoutee);
      final int idx = items.indexWhere((x) => x.id == id);
      if (idx != -1) {
        items[idx].quantiteEnStock += quantiteAjoutee;
        items.refresh();
      }
      showThemedSnackbar(
          'Stock mis à jour', '+$quantiteAjoutee unités ajoutées',
          type: SnackbarType.success);
    } catch (_) {}
  }

  Future<void> deleteItem(int id) async {
    try {
      await StockService.deleteItem(id);
      items.removeWhere((x) => x.id == id);
      showThemedSnackbar('Article supprimé', '', type: SnackbarType.success);
    } catch (_) {}
  }
}
