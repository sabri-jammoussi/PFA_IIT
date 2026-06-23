import 'package:dentiflow/core/services/api_service.dart';
import '../models/billing_model.dart';

class BillingService {
  static List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<List<Invoice>> getInvoices({String? search}) async {
    String endpoint = '/factures?pageSize=200';
    if (search != null && search.isNotEmpty) {
      endpoint += '&search=${Uri.encodeQueryComponent(search)}';
    }
    final dynamic data = await ApiService.get(endpoint);
    return _asList(data).map(Invoice.fromJson).toList();
  }

  static Future<void> recordPayment(Payment p) async {
    await ApiService.post('/paiements', body: p.toJson());
  }
}
