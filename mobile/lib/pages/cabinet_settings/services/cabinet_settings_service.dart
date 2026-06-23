import 'package:dentiflow/core/services/api_service.dart';
import '../models/cabinet_settings_model.dart';

class CabinetSettingsService {
  static Future<CabinetSettings> getSettings() async {
    final dynamic data = await ApiService.get('/cabinet/settings/smtp');
    if (data is Map<String, dynamic>) {
      return CabinetSettings.fromJson(data);
    }
    return CabinetSettings();
  }

  /// The web page saves via POST (not PUT) on the same endpoint.
  static Future<void> saveSettings(CabinetSettings s) async {
    await ApiService.post('/cabinet/settings/smtp', body: s.toJson());
  }
}
