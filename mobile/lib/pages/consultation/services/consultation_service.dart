import 'package:dentiflow/core/services/api_service.dart';
import '../models/consultation_model.dart';

class ConsultationService {
  /// Backend list endpoints return a PagedResult ({ items, totalCount, ... }).
  /// Older/seed routes may return a bare list, so we tolerate both.
  static List<Map<String, dynamic>> _items(dynamic data) {
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map<String, dynamic> && data['items'] is List) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
  }

  static Future<PatientClinical> getPatient(int patientId) async {
    final dynamic data = await ApiService.get('/patients/$patientId');
    return PatientClinical.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<Consultation>> getConsultations(int patientId) async {
    final dynamic data = await ApiService.get(
        '/consultations?patientId=$patientId&pageSize=50');
    return _items(data).map(Consultation.fromJson).toList();
  }

  static Future<int> addConsultation(Consultation c) async {
    final dynamic data =
        await ApiService.post('/consultations', body: c.toJson());
    if (data is int) return data;
    if (data is Map<String, dynamic>) return (data['id'] ?? 0) as int;
    return 0;
  }

  static Future<List<Treatment>> getTreatments(int patientId) async {
    final dynamic data = await ApiService.get(
        '/soins-effectues?patientId=$patientId&pageSize=200');
    return _items(data).map(Treatment.fromJson).toList();
  }

  static Future<void> addTreatment(Treatment t) async {
    await ApiService.post('/soins-effectues', body: t.toJson());
  }

  static Future<List<Prescription>> getPrescriptions(int patientId) async {
    final dynamic data = await ApiService.get(
        '/ordonnances?patientId=$patientId&pageSize=50');
    return _items(data).map(Prescription.fromJson).toList();
  }

  static Future<void> addPrescription(Prescription p) async {
    await ApiService.post('/ordonnances', body: p.toJson());
  }
}
