import 'package:dentiflow/core/services/api_service.dart';
import '../models/stock_model.dart';

class StockService {
  static List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<List<StockItem>> getItems() async {
    final dynamic data = await ApiService.get('/articles?pageSize=200');
    return _asList(data).map(StockItem.fromJson).toList();
  }

  static Future<StockItem> addItem(StockItem i) async {
    // API returns the new id (CreatedAtAction value). Re-fetch a clean model
    // from the submitted data plus the returned id when possible.
    final dynamic data = await ApiService.post('/articles', body: i.toJson());
    if (data is Map<String, dynamic>) {
      return StockItem.fromJson(data);
    }
    final int newId = data is int ? data : (data is num ? data.toInt() : i.id);
    return StockItem(
      id: newId,
      nom: i.nom,
      description: i.description,
      quantiteEnStock: i.quantiteEnStock,
      seuilAlerte: i.seuilAlerte,
      unite: i.unite,
    );
  }

  static Future<StockItem> updateItem(StockItem i) async {
    // PUT returns 204 No Content; echo back the submitted model.
    await ApiService.put('/articles/${i.id}', body: {'id': i.id, ...i.toJson()});
    return i;
  }

  static Future<void> restock(int id, int quantiteAjoutee) async {
    await ApiService.patch('/articles/$id/restock',
        body: {'id': id, 'quantiteAjoutee': quantiteAjoutee});
  }

  static Future<void> deleteItem(int id) async {
    await ApiService.delete('/articles/$id');
  }
}
