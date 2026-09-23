// lib/app/services/hive_service.dart

import 'package:cuproute/app/constants/hive_keys.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  HiveService._();

  // ── Box accessors ─────────────────────────────────────
  static Box get _settings => Hive.box(HiveKeys.settingsBox);
  static Box get _user => Hive.box(HiveKeys.userBox);

  static Future<void> init() async {
    await Hive.initFlutter();
    // Register all adapters
    // Hive.registerAdapter(HiveCafeAdapter());
    // Hive.registerAdapter(HiveSettingsAdapter());
    // Hive.registerAdapter(HiveUserAdapter());
    // Open boxes
    await Future.wait([
      // Hive.openBox<HiveCafe>(HiveKeys.cafesBox),
      // Hive.openBox<HiveCafe>(HiveKeys.favsBox),
      Hive.openBox(HiveKeys.settingsBox),
      Hive.openBox(HiveKeys.userBox),
    ]);
  }

  // ════════════════════════════════════════════════════════
  //  SETTINGS BOX  — filter prefs, radius, sort order
  // ════════════════════════════════════════════════════════

  // ── SAVE ─────────────────────────────────────────────
  static Future<void> saveSearchRadius(double radius) =>
      _settings.put(HiveKeys.searchRadius, radius);

  static Future<void> saveMinRating(double rating) =>
      _settings.put(HiveKeys.minRating, rating);

  static Future<void> saveFilterWifi(bool value) =>
      _settings.put(HiveKeys.filterWifi, value);

  static Future<void> saveFilterParking(bool value) =>
      _settings.put(HiveKeys.filterParking, value);

  static Future<void> saveFilterOutdoor(bool value) =>
      _settings.put(HiveKeys.filterOutdoor, value);

  static Future<void> saveSortOrder(String value) =>
      _settings.put(HiveKeys.sortOrder, value); // 'distance' | 'rating'

  static Future<void> saveOnboardingSeen() =>
      _settings.put(HiveKeys.onboardingSeen, true);

  static Future<void> saveLastLocation(double lat, double lng) async {
    await _settings.put(HiveKeys.lastSearchLat, lat);
    await _settings.put(HiveKeys.lastSearchLng, lng);
  }

  // ── GET ──────────────────────────────────────────────
  static double getSearchRadius() =>
      _settings.get(HiveKeys.searchRadius, defaultValue: 2000.0) as double;
  static double getMinRating() =>
      _settings.get(HiveKeys.minRating, defaultValue: 0.0) as double;
  static bool getFilterWifi() =>
      _settings.get(HiveKeys.filterWifi, defaultValue: false) as bool;
  static bool getFilterParking() =>
      _settings.get(HiveKeys.filterParking, defaultValue: false) as bool;
  static bool getFilterOutdoor() =>
      _settings.get(HiveKeys.filterOutdoor, defaultValue: false) as bool;
  static String getSortOrder() =>
      _settings.get(HiveKeys.sortOrder, defaultValue: 'distance') as String;
  static bool getOnboardingSeen() =>
      _settings.get(HiveKeys.onboardingSeen, defaultValue: false) as bool;
  static double? getLastLat() =>
      _settings.get(HiveKeys.lastSearchLat) as double?;
  static double? getLastLng() =>
      _settings.get(HiveKeys.lastSearchLng) as double?;

  // ── DELETE ───────────────────────────────────────────
  static Future<void> deleteSearchRadius() =>
      _settings.delete(HiveKeys.searchRadius);
  static Future<void> deleteMinRating() => _settings.delete(HiveKeys.minRating);
  static Future<void> deleteFilterWifi() =>
      _settings.delete(HiveKeys.filterWifi);
  static Future<void> deleteFilterParking() =>
      _settings.delete(HiveKeys.filterParking);
  static Future<void> deleteFilterOutdoor() =>
      _settings.delete(HiveKeys.filterOutdoor);
  static Future<void> deleteSortOrder() => _settings.delete(HiveKeys.sortOrder);
  static Future<void> deleteLastLocation() async {
    await _settings.delete(HiveKeys.lastSearchLat);
    await _settings.delete(HiveKeys.lastSearchLng);
  }

  /// Wipe ALL settings — e.g. "Reset to defaults" button
  static Future<void> clearSettings() => _settings.clear();

  // ════════════════════════════════════════════════════════
  //  USER BOX  — profile cache (name, email, avatar)
  // ════════════════════════════════════════════════════════

  // ── SAVE ─────────────────────────────────────────────
  static Future<void> saveUser({
    required String id,
    required String firebaseUid,
    required String email,
    required String name,
    String? avatarUrl,
  }) async {
    await Future.wait([
      _user.put(HiveKeys.userId, id),
      _user.put(HiveKeys.userFirebaseUid, firebaseUid),
      _user.put(HiveKeys.userEmail, email),
      _user.put(HiveKeys.userName, name),
      if (avatarUrl != null) _user.put(HiveKeys.userAvatar, avatarUrl),
      _user.put(HiveKeys.userCreatedAt, DateTime.now().toIso8601String()),
    ]);
  }

  // ── GET (individual fields) ───────────────────────────
  static String? getUserId() => _user.get(HiveKeys.userId) as String?;
  static String? getUserFirebaseUid() =>
      _user.get(HiveKeys.userFirebaseUid) as String?;
  static String? getUserEmail() => _user.get(HiveKeys.userEmail) as String?;
  static String? getUserName() => _user.get(HiveKeys.userName) as String?;
  static String? getUserAvatar() => _user.get(HiveKeys.userAvatar) as String?;
  static String? getUserCreatedAt() =>
      _user.get(HiveKeys.userCreatedAt) as String?;

  /// Get all user fields as a single map — handy for building UserEntity
  static Map<String, dynamic> getUser() => {
    'id': getUserId(),
    'firebase_uid': getUserFirebaseUid(),
    'email': getUserEmail(),
    'name': getUserName(),
    'avatar_url': getUserAvatar(),
    'created_at': getUserCreatedAt(),
  };

  /// true if a user has ever been saved to the box
  static bool hasUser() => _user.containsKey(HiveKeys.userId);

  // ── UPDATE (individual fields) ────────────────────────
  static Future<void> updateUserName(String name) =>
      _user.put(HiveKeys.userName, name);
  static Future<void> updateUserEmail(String email) =>
      _user.put(HiveKeys.userEmail, email);
  static Future<void> updateUserAvatar(String url) =>
      _user.put(HiveKeys.userAvatar, url);

  // ── DELETE ───────────────────────────────────────────
  static Future<void> deleteUserAvatar() => _user.delete(HiveKeys.userAvatar);

  /// Full logout — wipe the entire user box
  static Future<void> clearUser() => _user.clear();

  // ════════════════════════════════════════════════════════
  //  GLOBAL
  // ════════════════════════════════════════════════════════

  /// Call on logout — clears both boxes
  static Future<void> clearAll() async {
    await Future.wait([_settings.clear(), _user.clear()]);
  }
}
