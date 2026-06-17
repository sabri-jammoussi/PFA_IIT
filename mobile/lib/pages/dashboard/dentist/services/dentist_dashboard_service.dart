import 'package:dentiflow/core/services/api_service.dart';

class DentistDashboardService {
  static Future<List<Map<String, dynamic>>> getTodayAppointments() async {
    final now = DateTime.now();
    final String today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final dynamic data =
        await ApiService.get('/rendezvous?startDate=$today&endDate=$today');
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  static Future<List<Map<String, dynamic>>> getInvoices() async {
    final dynamic data = await ApiService.get('/factures');
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }
}
