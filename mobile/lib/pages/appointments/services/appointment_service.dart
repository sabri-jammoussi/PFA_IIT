import 'package:dentiflow/core/services/api_service.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<List<Appointment>> getAppointments({
    required DateTime start,
    required DateTime end,
    int? dentisteId,
  }) async {
    String endpoint =
        '/rendezvous?startDate=${_fmt(start)}&endDate=${_fmt(end)}';
    if (dentisteId != null) endpoint += '&dentisteId=$dentisteId';
    final dynamic data = await ApiService.get(endpoint);
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(Appointment.fromJson).toList();
    }
    return [];
  }

  static Future<List<Appointment>> getPendingRequests() async {
    final dynamic data = await ApiService.get('/rendezvous/pending');
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(Appointment.fromJson).toList();
    }
    return [];
  }

  static Future<Appointment> addAppointment(Appointment a) async {
    final dynamic data =
        await ApiService.post('/rendezvous', body: a.toJson());
    return Appointment.fromJson(data as Map<String, dynamic>);
  }

  static Future<Appointment> updateAppointment(Appointment a) async {
    final dynamic data =
        await ApiService.put('/rendezvous/${a.id}', body: a.toJson());
    return Appointment.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> cancelAppointment(int id) async {
    await ApiService.delete('/rendezvous/$id');
  }

  static Future<List<Dentist>> getDentists() async {
    final dynamic data = await ApiService.get('/users/dentists');
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(Dentist.fromJson).toList();
    }
    return [];
  }

  static Future<void> approveRequest(int id) async {
    await ApiService.put('/rendezvous/$id',
        body: {'statut': 'CONFIRMED'});
  }
}
