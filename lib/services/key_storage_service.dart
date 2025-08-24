import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyStorageService {
  final _storage = const FlutterSecureStorage();
  static const String _keyName = 'gemini_api_key';

  // Kulcs mentése a secure storage-ba
  Future<void> writeKey(String key) async {
    await _storage.write(key: _keyName, value: key);
  }

  // Kulcs beolvasása a secure storage-ból
  Future<String?> readKey() async {
    return await _storage.read(key: _keyName);
  }

  // Kulcs törlése a secure storage-ból
  Future<void> deleteKey() async {
    await _storage.delete(key: _keyName);
  }
}
