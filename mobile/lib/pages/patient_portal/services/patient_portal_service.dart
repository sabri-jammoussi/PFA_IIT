import 'package:dentiflow/core/services/api_service.dart';
import '../models/patient_portal_model.dart';

class PatientPortalService {
  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<List<MyAppointment>> getMyAppointments() async {
    final dynamic data = await ApiService.get('/my/appointments');
    if (data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map(MyAppointment.fromJson)
          .toList();
    }
    return [];
  }

  static Future<MedicalRecordSummary?> getMedicalRecord() async {
    try {
      final dynamic data =
          await ApiService.get('/my/appointments/medical-record');
      if (data is Map<String, dynamic>) {
        return MedicalRecordSummary.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  static Future<Availability?> getAvailability(
      DateTime date, int dentisteId) async {
    final String dateStr = _fmt(date);
    final dynamic data = await ApiService.get(
        '/my/appointments/availability?date=$dateStr&dentistId=$dentisteId');
    if (data is Map<String, dynamic>) {
      return Availability.fromJson(data);
    }
    if (data is List) {
      return Availability(date: dateStr, slots: data.cast<String>());
    }
    return null;
  }

  static Future<void> requestAppointment({
    required int dentisteId,
    required String dateHeure,
    required String motif,
  }) async {
    await ApiService.post('/my/appointments/request', body: {
      'dentisteId': dentisteId,
      'dateHeure': dateHeure,
      'motif': motif,
    });
  }

  static Future<List<Map<String, dynamic>>> getDentists() async {
    final dynamic data = await ApiService.get('/users/dentists');
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }
}
