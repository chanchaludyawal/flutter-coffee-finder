// lib/data/models/user_model.dart

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firebaseUid,
    required super.email,
    required super.name,
    super.avatarUrl,
    super.searchRadiusMetres,
    super.minRating,
    super.filterWifi,
    super.filterParking,
    super.filterOutdoor,
    super.sortOrder,
    super.isLoggedIn,
    super.locationPermissionGranted,
    super.lastActiveAt,
    required super.createdAt,
    super.updatedAt,
  });

  // ── From PostgreSQL / Node.js API response ─────────────
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firebaseUid: json['firebase_uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // ── To JSON (for PATCH /api/users/:id) ─────────────────
  Map<String, dynamic> toJson() => {
    'id': id,
    'firebase_uid': firebaseUid,
    'email': email,
    'name': name,
    'avatar_url': avatarUrl,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  // ── From shared_preferences (prefs store flat key-values) ──
  factory UserModel.fromPrefs(Map<String, dynamic> prefs, UserModel base) {
    return UserModel(
      id: base.id,
      firebaseUid: base.firebaseUid,
      email: base.email,
      name: base.name,
      avatarUrl: base.avatarUrl,
      createdAt: base.createdAt,
      searchRadiusMetres: (prefs['search_radius'] as double?) ?? 2000.0,
      minRating: (prefs['min_rating'] as double?) ?? 0.0,
      filterWifi: (prefs['filter_wifi'] as bool?) ?? false,
      filterParking: (prefs['filter_parking'] as bool?) ?? false,
      filterOutdoor: (prefs['filter_outdoor'] as bool?) ?? false,
      sortOrder: SortOrder.values.firstWhere(
        (e) => e.name == (prefs['sort_order'] as String? ?? 'distance'),
        orElse: () => SortOrder.distance,
      ),
    );
  }

  // ── To shared_preferences map ───────────────────────────
  Map<String, dynamic> toPrefs() => {
    'search_radius': searchRadiusMetres,
    'min_rating': minRating,
    'filter_wifi': filterWifi,
    'filter_parking': filterParking,
    'filter_outdoor': filterOutdoor,
    'sort_order': sortOrder.name,
  };

  // ── From Firebase user (on login) ──────────────────────
  factory UserModel.fromFirebase(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      firebaseUid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? 'Coffee lover',
      avatarUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
    );
  }
}
