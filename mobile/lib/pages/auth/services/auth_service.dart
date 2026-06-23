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

  /// Sends a password-reset request. Mirrors the Vue `/auth/forget-password`
  /// call (POST { matriculeOrEmail, host }).
  static Future<void> forgetPassword(String matriculeOrEmail) async {
    await ApiService.post(
      '/auth/forget-password',
      body: {
        'matriculeOrEmail': matriculeOrEmail,
        'host': 'mobile-app',
      },
    );
  }

  /// Registers a new clinic + owner dentist account.
  /// Mirrors the Vue `/saas/register` call.
  static Future<void> registerClinic({
    required String nomCabinet,
    String? adresse,
    required String doctorNom,
    required String doctorPrenom,
    required String doctorEmail,
    required String doctorPassword,
  }) async {
    await ApiService.post(
      '/saas/register',
      body: {
        'nomCabinet': nomCabinet,
        'adresse': (adresse != null && adresse.trim().isNotEmpty)
            ? adresse.trim()
            : null,
        'doctorEmail': doctorEmail,
        'doctorPassword': doctorPassword,
        'doctorNom': doctorNom,
        'doctorPrenom': doctorPrenom,
      },
    );
  }
}
