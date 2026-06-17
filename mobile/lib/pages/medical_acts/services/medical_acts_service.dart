import 'package:dentiflow/core/services/api_service.dart';
import '../models/medical_act_model.dart';

class MedicalActsService {
  static Future<List<MedicalAct>> getActs() async {
    final dynamic data = await ApiService.get('/actes-medicaux');
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(MedicalAct.fromJson).toList();
    }
    return [];
  }

  static Future<MedicalAct> addAct(MedicalAct a) async {
    final dynamic data =
        await ApiService.post('/actes-medicaux', body: a.toJson());
    return MedicalAct.fromJson(data as Map<String, dynamic>);
  }

  static Future<MedicalAct> updateAct(MedicalAct a) async {
    final dynamic data =
        await ApiService.put('/actes-medicaux/${a.id}', body: a.toJson());
    return MedicalAct.fromJson(data as Map<String, dynamic>);
  }
}
