// lib/app/constants/hive_keys.dart

class HiveKeys {
  HiveKeys._();

  // ── Box names ─────────────────────────────────────────
  static const String settingsBox     = 'settings_box';
  static const String userBox         = 'user_box';
  static const String cafesBox        = 'cafes_box';
  static const String favsBox         = 'favs_box';
  static const String recentSearchBox = 'recent_search_box';
  static const String pendingReviews  = 'pending_reviews_box';

  // ── userBox field keys ────────────────────────────────
  static const String userId          = 'user_id';
  static const String userEmail       = 'user_email';
  static const String userName        = 'user_name';
  static const String userAvatar      = 'user_avatar';
  static const String userFirebaseUid = 'user_firebase_uid';
  static const String userCreatedAt   = 'user_created_at';

  // ── settingsBox field keys ────────────────────────────
  static const String searchRadius    = 'search_radius';
  static const String minRating       = 'min_rating';
  static const String filterWifi      = 'filter_wifi';
  static const String filterParking   = 'filter_parking';
  static const String filterOutdoor   = 'filter_outdoor';
  static const String sortOrder       = 'sort_order';
  static const String onboardingSeen  = 'onboarding_seen';
  static const String lastSearchLat   = 'last_search_lat';
  static const String lastSearchLng   = 'last_search_lng';
}