import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String getBaseUrl() {
    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5094/api';
  }

  static String getSignalRHubUrl() {
    return dotenv.env['SIGNALR_HUB_URL'] ?? 'http://10.0.2.2:5555/notif';
  }
}
