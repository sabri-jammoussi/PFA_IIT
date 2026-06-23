import 'package:dentiflow/core/services/api_service.dart';
import '../models/secretaire_model.dart';

class SecretairesService {
  // Secretary role id (UserRole.Secretaire) as used by the Vue web app.
  static const int secretaryRoleId = 3;

  static Future<List<Secretaire>> getSecretaires({String? search}) async {
    final String q = (search != null && search.trim().isNotEmpty)
        ? '&search=${Uri.encodeQueryComponent(search.trim())}'
        : '';
    final dynamic data = await ApiService.get(
      '/users?page=1&pageSize=100&roleId=$secretaryRoleId$q',
    );
    // Paged result: { items: [...], totalCount: n }
    final List<dynamic> items = data is Map<String, dynamic>
        ? (data['items'] as List<dynamic>? ?? [])
        : (data is List ? data : []);
    return items
        .cast<Map<String, dynamic>>()
        .map(Secretaire.fromJson)
        .toList();
  }

  static Future<void> createSecretaire({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    String? username,
  }) async {
    await ApiService.post('/users', body: {
      'username': (username != null && username.trim().isNotEmpty)
          ? username.trim()
          : email,
      'email': email,
      'password': password,
      'nom': nom,
      'prenom': prenom,
      'roleId': secretaryRoleId,
    });
  }

  static Future<void> updateSecretaire({
    required int id,
    required String nom,
    required String prenom,
    required String email,
    required bool isActive,
    String? username,
    String? password,
  }) async {
    final Map<String, dynamic> body = {
      'id': id,
      'username': (username != null && username.trim().isNotEmpty)
          ? username.trim()
          : email,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'isActive': isActive,
      'roleId': secretaryRoleId,
    };
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    await ApiService.put('/users/$id', body: body);
  }

  static Future<void> deleteSecretaire(int id) async {
    await ApiService.delete('/users/$id');
  }
}
