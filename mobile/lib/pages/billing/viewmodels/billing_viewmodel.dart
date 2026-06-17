import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/billing_model.dart';
import '../services/billing_service.dart';

class BillingViewModel extends GetxController {
  final RxList<Invoice> invoices = <Invoice>[].obs;
  final RxBool isLoading = false.obs;
  final RxString search = ''.obs;
  final RxString filter = 'all'.obs; // all, paid, unpaid

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
  }

  List<Invoice> get filtered {
    final List<Invoice> base = invoices.toList();
    if (filter.value == 'paid') {
      return base.where((i) => i.balance <= 0).toList();
    }
    if (filter.value == 'unpaid') {
      return base.where((i) => i.balance > 0).toList();
    }
    return base;
  }

  Future<void> loadInvoices() async {
    isLoading.value = true;
    try {
      invoices.assignAll(await BillingService.getInvoices(
          search: search.value.isEmpty ? null : search.value));
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recordPayment(Payment p) async {
    try {
      await BillingService.recordPayment(p);
      await loadInvoices();
      showThemedSnackbar('Paiement enregistré', '', type: SnackbarType.success);
    } catch (_) {}
  }
}
