import 'package:dentiflow/core/services/api_service.dart';
import '../models/stock_model.dart';

class StockService {
  static Future<List<StockItem>> getItems() async {
    final dynamic data = await ApiService.get('/articles');
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(StockItem.fromJson).toList();
    }
    return [];
  }

  static Future<StockItem> addItem(StockItem i) async {
    final dynamic data = await ApiService.post('/articles', body: i.toJson());
    return StockItem.fromJson(data as Map<String, dynamic>);
  }

  static Future<StockItem> updateItem(StockItem i) async {
    final dynamic data =
        await ApiService.put('/articles/${i.id}', body: i.toJson());
    return StockItem.fromJson(data as Map<String, dynamic>);
  }
}
