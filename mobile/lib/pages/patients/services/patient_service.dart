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

  static Future<Patient> addPatient(Patient p) async {
    final dynamic data = await ApiService.post('/patients', body: p.toJson());
    return Patient.fromJson(data as Map<String, dynamic>);
  }

  static Future<Patient> updatePatient(Patient p) async {
    final dynamic data =
        await ApiService.put('/patients/${p.id}', body: p.toJson());
    return Patient.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> invitePatient(Patient p) async {
    await ApiService.post('/patients/invite', body: p.toJson());
  }

  static Future<void> archivePatient(int id) async {
    await ApiService.post('/patients/$id/archive');
  }
}
