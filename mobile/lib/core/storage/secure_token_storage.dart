import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: _androidOptions,
  );

  static const String _tokenKey = 'denti_token';

  static Future<void> writeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> readToken() => _readSafe(key: _tokenKey);

  static Future<bool> hasToken() async {
    final String? token = await readToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<String?> _readSafe({required String key}) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException {
      await _clearCorruptedStorage();
      return null;
    } catch (_) {
      await _clearCorruptedStorage();
      return null;
    }
  }

  static Future<void> _clearCorruptedStorage() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
