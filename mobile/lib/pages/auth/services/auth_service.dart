import 'package:dentiflow/core/services/api_service.dart';

class AuthService {
  static Future<String> login(String username, String password) async {
    final dynamic response = await ApiService.post(
      '/auth/login',
      body: {'username': username, 'password': password},
    );
    if (response is Map<String, dynamic> && response.containsKey('token')) {
      return response['token'] as String;
    }
    throw Exception('Token manquant dans la réponse');
  }

  static Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout');
    } catch (_) {}
  }
}
