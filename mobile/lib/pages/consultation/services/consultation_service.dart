import 'package:dentiflow/core/services/api_service.dart';
import '../models/consultation_model.dart';

class ConsultationService {
  static Future<List<Consultation>> getConsultations(int patientId) async {
    final dynamic data =
        await ApiService.get('/consultations?patientId=$patientId');
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(Consultation.fromJson).toList();
    }
    return [];
  }

  static Future<Consultation> addConsultation(Consultation c) async {
    final dynamic data =
        await ApiService.post('/consultations', body: c.toJson());
    return Consultation.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<Treatment>> getTreatments(int patientId) async {
    final dynamic data =
        await ApiService.get('/soins-effectues?patientId=$patientId');
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(Treatment.fromJson).toList();
    }
    return [];
  }

  static Future<Treatment> addTreatment(Treatment t) async {
    final dynamic data =
        await ApiService.post('/soins-effectues', body: t.toJson());
    return Treatment.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<Prescription>> getPrescriptions(int patientId) async {
    final dynamic data =
        await ApiService.get('/ordonnances?patientId=$patientId');
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(Prescription.fromJson).toList();
    }
    return [];
  }

  static Future<Prescription> addPrescription(Prescription p) async {
    final dynamic data =
        await ApiService.post('/ordonnances', body: p.toJson());
    return Prescription.fromJson(data as Map<String, dynamic>);
  }
}
