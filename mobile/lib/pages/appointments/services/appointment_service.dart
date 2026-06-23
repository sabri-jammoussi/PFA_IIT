import 'package:dentiflow/core/services/api_service.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  static String _fmtStart(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}T00:00:00';

  static String _fmtEnd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}T23:59:59';

  static List<Appointment> _parseList(dynamic data) {
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(Appointment.fromJson).toList();
    }
    if (data is Map<String, dynamic> && data['items'] is List) {
      return (data['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(Appointment.fromJson)
          .toList();
    }
    return [];
  }

  static Future<List<Appointment>> getAppointments({
    required DateTime date,
    int? dentisteId,
  }) async {
    String endpoint =
        '/rendezvous?page=1&pageSize=100&startDate=${_fmtStart(date)}&endDate=${_fmtEnd(date)}';
    if (dentisteId != null) endpoint += '&dentisteId=$dentisteId';
    final dynamic data = await ApiService.get(endpoint);
    return _parseList(data);
  }

  static Future<List<Appointment>> getPendingRequests() async {
    final dynamic data = await ApiService.get('/rendezvous/pending');
    return _parseList(data);
  }

  static Future<void> addAppointment(Appointment a) async {
    await ApiService.post('/rendezvous', body: a.toJson());
  }

  /// PUT requires the full command (all fields). The DTO `toJson` already
  /// includes `id` when non-zero, which the backend validates against the URL.
  static Future<void> updateAppointment(Appointment a) async {
    await ApiService.put('/rendezvous/${a.id}', body: a.toJson());
  }

  static Future<void> cancelAppointment(int id) async {
    await ApiService.delete('/rendezvous/$id');
  }

  /// Confirm patient arrival -> POST /rendezvous/{id}/checkin (notifies dentist).
  static Future<void> confirmArrival(int id) async {
    await ApiService.post('/rendezvous/$id/checkin');
  }

  static Future<List<Dentist>> getDentists() async {
    final dynamic data = await ApiService.get('/users/dentists');
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(Dentist.fromJson).toList();
    }
    return [];
  }
}
