import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dentiflow/config/app_config.dart';
import 'package:dentiflow/core/df_ui.dart';

import '../storage/secure_token_storage.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders() async {
    final String? token = await SecureStorage.readToken();
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<void> _logout() async {
    await SecureStorage.deleteToken();
    Get.offAllNamed('/login');
  }

  static Future<dynamic> _sendRequest({
    required String method,
    required String endpoint,
    dynamic body,
  }) async {
    final headers = await _getHeaders();
    final String baseUrl = AppConfig.getBaseUrl();
    final Uri url = Uri.parse('$baseUrl$endpoint');

    late http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'POST':
        response = await http.post(url, headers: headers,
            body: body != null ? json.encode(body) : null);
        break;
      case 'PUT':
        response = await http.put(url, headers: headers,
            body: body != null ? json.encode(body) : null);
        break;
      case 'PATCH':
        response = await http.patch(url, headers: headers,
            body: body != null ? json.encode(body) : null);
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method');
    }

    return _handleResponse(response);
  }

  static Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          return json.decode(response.body);
        } catch (_) {
          return response.body;
        }
      }
      return null;
    }

    if (response.statusCode == 401) {
      await _logout();
      throw Exception('Session expirée');
    }

    if (response.statusCode == 402) {
      Get.offAllNamed('/subscription-expired');
      throw Exception('Abonnement expiré');
    }

    dynamic data;
    try {
      data = json.decode(response.body);
    } catch (_) {}

    final String message = data != null
        ? (data['message'] ?? data['title'] ?? data['description'] ?? 'Erreur système')
        : 'Erreur système (${response.statusCode})';

    if (Get.isSnackbarOpen != true) {
      showThemedSnackbar('Erreur', message, type: SnackbarType.error);
    }
    throw Exception(message);
  }

  static Future<dynamic> get(String endpoint) =>
      _sendRequest(method: 'GET', endpoint: endpoint);

  static Future<dynamic> post(String endpoint, {dynamic body}) =>
      _sendRequest(method: 'POST', endpoint: endpoint, body: body);

  static Future<dynamic> put(String endpoint, {dynamic body}) =>
      _sendRequest(method: 'PUT', endpoint: endpoint, body: body);

  static Future<dynamic> patch(String endpoint, {dynamic body}) =>
      _sendRequest(method: 'PATCH', endpoint: endpoint, body: body);

  static Future<dynamic> delete(String endpoint) =>
      _sendRequest(method: 'DELETE', endpoint: endpoint);

  static Future<dynamic> multipartPost(
    String endpoint, {
    required Map<String, String> fields,
    required String fileField,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final String? token = await SecureStorage.readToken();
    final String baseUrl = AppConfig.getBaseUrl();
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);
    request.files.add(http.MultipartFile.fromBytes(fileField, fileBytes, filename: fileName));
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    return _handleResponse(http.Response(body, streamed.statusCode, headers: streamed.headers));
  }
}
