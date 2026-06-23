import 'package:dentiflow/core/services/api_service.dart';

class DentistDashboardService {
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

  /// Today's appointments for the logged-in dentist.
  /// Mirrors the Vue dashboard: full-day window + optional dentisteId filter.
  static Future<List<Map<String, dynamic>>> getTodayAppointments(
      {String? dentisteId}) async {
    final DateTime now = DateTime.now();
    final String day = _day(now);
    final StringBuffer url = StringBuffer(
        '/rendezvous?startDate=${day}T00:00:00Z&endDate=${day}T23:59:59Z&pageSize=100');
    if (dentisteId != null && dentisteId.isNotEmpty) {
      url.write('&dentisteId=$dentisteId');
    }
    return _asList(await ApiService.get(url.toString()));
  }

  static Future<List<Map<String, dynamic>>> getInvoices() async {
    return _asList(await ApiService.get('/factures?pageSize=200'));
  }
}
