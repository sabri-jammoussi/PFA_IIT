import 'package:dentiflow/core/services/api_service.dart';
import '../models/medical_act_model.dart';

class MedicalActsService {
  /// GET /actes-medicaux — the API returns a paged result
  /// ({ items, totalCount, page, pageSize }); a large pageSize is requested
  /// so the mobile catalog stays a single scrollable list.
  static Future<List<MedicalAct>> getActs({String? search}) async {
    final String q = (search != null && search.trim().isNotEmpty)
        ? '&search=${Uri.encodeQueryComponent(search.trim())}'
        : '';
    final dynamic data =
        await ApiService.get('/actes-medicaux?page=1&pageSize=500$q');
    final List<dynamic> rows = data is Map<String, dynamic>
        ? (data['items'] as List<dynamic>? ?? const [])
        : (data is List ? data : const []);
    return rows
        .cast<Map<String, dynamic>>()
        .map(MedicalAct.fromJson)
        .toList();
  }

  /// POST returns only the new id (201 CreatedAtAction). We echo back the
  /// submitted act with that id rather than re-fetching.
  static Future<MedicalAct> addAct(MedicalAct a) async {
    final dynamic data =
        await ApiService.post('/actes-medicaux', body: a.toJson());
    int newId = a.id;
    if (data is int) {
      newId = data;
    } else if (data is Map<String, dynamic> && data['id'] is int) {
      newId = data['id'] as int;
    }
    return MedicalAct(
      id: newId,
      libelle: a.libelle,
      tarifDeBase: a.tarifDeBase,
      codeNomenclature: a.codeNomenclature,
      description: a.description,
    );
  }

  /// PUT returns 204 No Content — the request body must include the id.
  static Future<MedicalAct> updateAct(MedicalAct a) async {
    await ApiService.put('/actes-medicaux/${a.id}',
        body: {'id': a.id, ...a.toJson()});
    return a;
  }

  static Future<void> deleteAct(int id) async {
    await ApiService.delete('/actes-medicaux/$id');
  }
}
