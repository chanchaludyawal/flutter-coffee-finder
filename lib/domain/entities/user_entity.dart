// lib/domain/entities/user_entity.dart

class UserEntity {
  // ── Identity ──────────────────────────────────────────
  final String? id; // UUID from PostgreSQL (matches Firebase UID)
  final String? firebaseUid; // Firebase Auth UID
  final String? email;
  final String? name;
  final String? avatarUrl; // Google profile photo or uploaded avatar

  // ── Preferences (persisted in shared_preferences) ────
  final double searchRadiusMetres; // default 2000.0
  final double minRating; // default 0.0 (no filter)
  final bool filterWifi;
  final bool filterParking;
  final bool filterOutdoor;
  final SortOrder sortOrder; // distance | rating | newest

  // ── Session state ─────────────────────────────────────
  final bool isLoggedIn;
  final bool locationPermissionGranted;
  final DateTime? lastActiveAt;

  // ── Timestamps ────────────────────────────────────────
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    this.id,
    this.firebaseUid,
    this.email,
    this.name,
    this.avatarUrl,
    this.searchRadiusMetres = 2000.0,
    this.minRating = 0.0,
    this.filterWifi = false,
    this.filterParking = false,
    this.filterOutdoor = false,
    this.sortOrder = SortOrder.distance,
    this.isLoggedIn = false,
    this.locationPermissionGranted = false,
    this.lastActiveAt,
    this.createdAt,
    this.updatedAt,
  });

  // ── copyWith (for state updates without mutation) ─────
  UserEntity copyWith({
    String? id,
    String? firebaseUid,
    String? email,
    String? name,
    String? avatarUrl,
    double? searchRadiusMetres,
    double? minRating,
    bool? filterWifi,
    bool? filterParking,
    bool? filterOutdoor,
    SortOrder? sortOrder,
    bool? isLoggedIn,
    bool? locationPermissionGranted,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      searchRadiusMetres: searchRadiusMetres ?? this.searchRadiusMetres,
      minRating: minRating ?? this.minRating,
      filterWifi: filterWifi ?? this.filterWifi,
      filterParking: filterParking ?? this.filterParking,
      filterOutdoor: filterOutdoor ?? this.filterOutdoor,
      sortOrder: sortOrder ?? this.sortOrder,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      locationPermissionGranted:
          locationPermissionGranted ?? this.locationPermissionGranted,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Equality (needed for Riverpod state comparison) ───
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          filterWifi == other.filterWifi &&
          filterParking == other.filterParking &&
          filterOutdoor == other.filterOutdoor &&
          searchRadiusMetres == other.searchRadiusMetres &&
          minRating == other.minRating &&
          sortOrder == other.sortOrder &&
          isLoggedIn == other.isLoggedIn;

  @override
  int get hashCode => Object.hash(
    id,
    email,
    filterWifi,
    filterParking,
    filterOutdoor,
    searchRadiusMetres,
    minRating,
    sortOrder,
    isLoggedIn,
  );
}

// ── Supporting enum ───────────────────────────────────────
enum SortOrder { distance, rating, newest }
