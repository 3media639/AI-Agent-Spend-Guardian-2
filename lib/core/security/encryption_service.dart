import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as enc;
import '../constants/app_constants.dart';

class EncryptionService {
  final FlutterSecureStorage _storage;
  enc.Encrypter? _encrypter;
  enc.IV? _iv;

  EncryptionService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  Future<void> _initKeys() async {
    if (_encrypter != null && _iv != null) return;
    
    // Retrieve or generate device-specific master key
    String? masterKeyStr = await _storage.read(key: '${AppConstants.keySecuredPrefix}master_key');
    if (masterKeyStr == null) {
      final key = enc.Key.fromSecureRandom(32);
      masterKeyStr = base64UrlEncode(key.bytes);
      await _storage.write(
        key: '${AppConstants.keySecuredPrefix}master_key',
        value: masterKeyStr,
      );
    }
    
    final masterKey = enc.Key(base64Url.decode(masterKeyStr));
    _iv = enc.IV.fromLength(16);
    _encrypter = enc.Encrypter(enc.AES(masterKey, mode: enc.AESMode.cbc));
  }

  /// Encrypts an API key and saves it to secure storage
  Future<void> storeApiKey(String providerKey, String plainApiKey) async {
    await _initKeys();
    final encrypted = _encrypter!.encrypt(plainApiKey, iv: _iv);
    await _storage.write(
      key: '${AppConstants.keySecuredPrefix}key_$providerKey',
      value: encrypted.base64,
    );
  }

  /// Retrieves and decrypts the API key
  Future<String?> getApiKey(String providerKey) async {
    await _initKeys();
    final cipherBase64 = await _storage.read(key: '${AppConstants.keySecuredPrefix}key_$providerKey');
    if (cipherBase64 == null) return null;
    try {
      final decrypted = _encrypter!.decrypt64(cipherBase64, iv: _iv);
      return decrypted;
    } catch (e) {
      return null;
    }
  }

  /// Deletes a stored key
  Future<void> deleteApiKey(String providerKey) async {
    await _storage.delete(key: '${AppConstants.keySecuredPrefix}key_$providerKey');
  }

  /// Clears all keys on sign out / emergency purge
  Future<void> purgeAllKeys() async {
    await _storage.deleteAll();
    _encrypter = null;
    _iv = null;
  }
}
