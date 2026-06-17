import 'package:dentiflow/core/services/api_service.dart';
import '../models/billing_model.dart';

class BillingService {
  static Future<List<Invoice>> getInvoices({String? search}) async {
    String endpoint = '/factures';
    if (search != null && search.isNotEmpty) {
      endpoint += '?search=${Uri.encodeQueryComponent(search)}';
    }
    final dynamic data = await ApiService.get(endpoint);
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(Invoice.fromJson).toList();
    }
    return [];
  }

  static Future<void> recordPayment(Payment p) async {
    await ApiService.post('/paiements', body: p.toJson());
  }
}
