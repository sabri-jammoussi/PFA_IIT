import 'package:dentiflow/core/services/api_service.dart';

class SecretaryDashboardService {
  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<List<Map<String, dynamic>>> getTodayAppointments() async {
    final now = DateTime.now();
    final String today = _fmt(now);
    final dynamic data =
        await ApiService.get('/rendezvous?startDate=$today&endDate=$today');
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  static Future<int> getPendingCount() async {
    final dynamic data = await ApiService.get('/rendezvous/pending');
    if (data is List) return data.length;
    return 0;
  }
}
