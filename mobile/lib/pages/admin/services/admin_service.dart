import 'package:dentiflow/core/services/api_service.dart';

class AdminService {
  static Future<List<Map<String, dynamic>>> getCabinets() async {
    final dynamic data = await ApiService.get('/cabinet');
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  static Future<void> toggleSubscription(int id, bool isActive) async {
    await ApiService.put('/cabinet/$id/subscription', body: {
      'isActive': isActive,
    });
  }
}
