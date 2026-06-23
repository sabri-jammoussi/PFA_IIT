import 'package:dentiflow/core/services/api_service.dart';

class SecretaryDashboardService {
  static String _day(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Unwraps either a raw list or a PagedResult ({ items: [...] }).
  static List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
  }

  static Future<List<Map<String, dynamic>>> getTodayAppointments() async {
    final DateTime now = DateTime.now();
    final String day = _day(now);
    return _asList(await ApiService.get(
        '/rendezvous?startDate=${day}T00:00:00Z&endDate=${day}T23:59:59Z&pageSize=100'));
  }

  /// Pending appointment requests (statut == EnAttenteValidation).
  /// This endpoint returns a raw list (not paged).
  static Future<List<Map<String, dynamic>>> getPendingRequests() async {
    return _asList(await ApiService.get('/rendezvous/pending'));
  }

  static Future<List<Map<String, dynamic>>> getInvoices() async {
    return _asList(await ApiService.get('/factures?pageSize=200'));
  }
}
