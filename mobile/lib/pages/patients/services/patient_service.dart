import 'package:dentiflow/core/services/api_service.dart';
import '../models/patient_model.dart';

class PatientService {
  static Future<List<Patient>> getPatients({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    String endpoint = '/patients?page=$page&pageSize=$pageSize';
    if (search != null && search.isNotEmpty) {
      endpoint += '&search=${Uri.encodeQueryComponent(search)}';
    }
    final dynamic data = await ApiService.get(endpoint);
    return _parseList(data);
  }

  static Future<Patient> getPatient(int id) async {
    final dynamic data = await ApiService.get('/patients/$id');
    return Patient.fromJson(data as Map<String, dynamic>);
  }

  static Future<Patient> addPatient(Patient p) async {
    final dynamic data = await ApiService.post('/patients', body: p.toJson());
    // Create endpoint returns the new id (int) -> re-fetch full record.
    if (data is int) return getPatient(data);
    if (data is Map<String, dynamic>) {
      final id = data['id'];
      if (id is int && (data['nom'] == null)) return getPatient(id);
      return Patient.fromJson(data);
    }
    return p;
  }

  static Future<Patient> updatePatient(Patient p) async {
    // Backend returns 204 NoContent -> return the locally edited record.
    await ApiService.put('/patients/${p.id}', body: {
      'id': p.id,
      ...p.toJson(),
    });
    return p;
  }

  /// Creates the patient AND sends a portal invitation by email.
  static Future<void> invitePatient(Patient p) async {
    await ApiService.post('/patients/invite', body: p.toJson());
  }

  /// Soft-delete (archive) — backend DELETE /patients/{id}.
  static Future<void> archivePatient(int id) async {
    await ApiService.delete('/patients/$id');
  }

  static List<Patient> _parseList(dynamic data) {
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(Patient.fromJson).toList();
    }
    if (data is Map<String, dynamic> && data.containsKey('items')) {
      return (data['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(Patient.fromJson)
          .toList();
    }
    return [];
  }
}
