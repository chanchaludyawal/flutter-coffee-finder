// lib/app/services/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyFirebaseUid    = 'firebase_uid';
  static const _keyIdToken        = 'firebase_id_token';
  static const _keyRefreshToken   = 'firebase_refresh_token';

  // ── SAVE ───────────────────────────────────────────
  static Future<void> saveAuthTokens({
    required String uid,
    required String idToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyFirebaseUid,  value: uid),
      _storage.write(key: _keyIdToken,      value: idToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  // ── GET ────────────────────────────────────────────
  static Future<String?> getUid()          => _storage.read(key: _keyFirebaseUid);
  static Future<String?> getIdToken()      => _storage.read(key: _keyIdToken);
  static Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  /// true only if a UID actually exists in the keychain
  static Future<bool> hasSession() async =>
      (await _storage.read(key: _keyFirebaseUid)) != null;

  // ── DELETE (on logout) ─────────────────────────────
  static Future<void> clearAuth() async {
    await Future.wait([
      _storage.delete(key: _keyFirebaseUid),
      _storage.delete(key: _keyIdToken),
      _storage.delete(key: _keyRefreshToken),
    ]);
  }
}