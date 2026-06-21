import 'package:dentiflow/core/services/api_service.dart';
import '../models/secretaire_model.dart';

class SecretairesService {
  static Future<List<Secretaire>> getSecretaires() async {
    final dynamic data = await ApiService.get('/secretaires');
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(Secretaire.fromJson).toList();
    }
    return [];
  }

  static Future<void> createSecretaire({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    await ApiService.post('/secretaires', body: {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
    });
  }

  static Future<void> toggleActive(int id, bool isActive) async {
    await ApiService.put('/secretaires/$id/toggle-active', body: {
      'isActive': isActive,
    });
  }

  static Future<void> deleteSecretaire(int id) async {
    await ApiService.delete('/secretaires/$id');
  }
}
