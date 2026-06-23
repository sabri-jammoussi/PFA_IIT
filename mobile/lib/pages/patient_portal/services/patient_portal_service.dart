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

  static Future<FullMedicalRecord?> getFullMedicalRecord() async {
    try {
      final dynamic data =
          await ApiService.get('/my/appointments/medical-record');
      if (data is Map<String, dynamic>) {
        return FullMedicalRecord.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  /// Returns the bookable slots for [date] / [dentisteId].
  /// Backend shape: List of { time, dateTime, isAvailable }.
  static Future<List<AppointmentSlot>> getAvailability(
      DateTime date, int dentisteId) async {
    final String dateStr = _fmt(date);
    final dynamic data = await ApiService.get(
        '/my/appointments/availability?date=$dateStr&dentistId=$dentisteId');
    if (data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map(AppointmentSlot.fromJson)
          .toList();
    }
    // Defensive: some envs may wrap the list in a `slots` field.
    if (data is Map<String, dynamic> && data['slots'] is List) {
      return (data['slots'] as List)
          .cast<Map<String, dynamic>>()
          .map(AppointmentSlot.fromJson)
          .toList();
    }
    return [];
  }

  static Future<void> requestAppointment({
    required int dentisteId,
    required String dateHeure,
    required String motif,
    String note = '',
  }) async {
    await ApiService.post('/my/appointments/request', body: {
      'dentisteId': dentisteId,
      'dateHeure': dateHeure,
      'motif': motif,
      'note': note,
    });
  }

  static Future<List<Map<String, dynamic>>> getDentists() async {
    final dynamic data = await ApiService.get('/users/dentists');
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }
}
