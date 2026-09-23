# cuproute

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# Project Structure Overview (Flutter Feature-First)


coffee_finder/
├── android/                         # Play Store config
│   └── app/
│       ├── build.gradle             # signingConfigs, minSdk 21
│       └── google-services.json
├── ios/                             # App Store Connect config
│   └── Runner/
│       ├── Info.plist               # NSLocationWhenInUse, camera perms
│       └── GoogleService-Info.plist
├── assets/
│   ├── images/                      # app splash, placeholders
│   ├── icons/                       # custom SVG icons
│   └── fonts/                       # Poppins or Inter
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── app/                         ← APP-WIDE CONSTANTS & THEME
│   │   ├── constants/
│   │   │   ├── app_constants.dart   # API base URL, keys, timeouts
│   │   │   ├── hive_keys.dart       # all Hive box names + field keys
│   │   │   └── route_names.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_text_styles.dart
│   │   └── app_router.dart          # GoRouter with guards
│   │
│   ├── core/                        ← SHARED INFRASTRUCTURE
│   │   ├── network/
│   │   │   ├── api_client.dart      # Dio singleton
│   │   │   ├── auth_interceptor.dart
│   │   │   └── network_info.dart
│   │   ├── storage/
│   │   │   ├── hive_service.dart    # registerAdapters, openBoxes
│   │   │   ├── secure_storage.dart  # JWT token store
│   │   │   └── cache_manager.dart   # TTL-based cache
│   │   ├── location/
│   │   │   ├── location_service.dart
│   │   │   ├── location_bloc.dart
│   │   │   └── geocoding_service.dart
│   │   ├── error/
│   │   │   ├── failures.dart        # ServerFailure, CacheFailure, etc.
│   │   │   ├── either_ext.dart
│   │   │   └── global_bloc_observer.dart
│   │   └── di/
│   │       └── injection_container.dart  # get_it setup
│   │
│   ├── domain/                      ← PURE DART — no Flutter deps
│   │   ├── entities/
│   │   │   ├── cafe_entity.dart
│   │   │   ├── review_entity.dart
│   │   │   └── user_entity.dart
│   │   ├── repositories/            # abstract interfaces
│   │   │   ├── cafe_repository.dart
│   │   │   ├── user_repository.dart
│   │   │   └── review_repository.dart
│   │   └── usecases/
│   │       ├── get_nearby_cafes.dart
│   │       ├── search_cafes.dart
│   │       ├── get_cafe_detail.dart
│   │       ├── toggle_favourite.dart
│   │       └── submit_review.dart
│   │
│   ├── data/                        ← IMPLEMENTATION
│   │   ├── models/
│   │   │   ├── cafe_model.dart      # fromJson/toJson + toEntity()
│   │   │   ├── review_model.dart
│   │   │   └── hive/
│   │   │       ├── hive_cafe.dart   # @HiveType(typeId: 0)
│   │   │       └── hive_cafe.g.dart # generated
│   │   ├── datasources/
│   │   │   ├── cafe_remote_datasource.dart
│   │   │   ├── cafe_local_datasource.dart   # Hive box
│   │   │   └── places_api_datasource.dart   # Google Places
│   │   └── repositories/
│   │       ├── cafe_repository_impl.dart
│   │       ├── user_repository_impl.dart
│   │       └── review_repository_impl.dart
│   │
│   ├── features/                    ← MODULAR FEATURES
│   │   ├── home/
│   │   │   ├── bloc/
│   │   │   │   ├── home_bloc.dart
│   │   │   │   ├── home_event.dart
│   │   │   │   └── home_state.dart
│   │   │   ├── pages/
│   │   │   │   └── home_page.dart
│   │   │   └── widgets/
│   │   │       ├── nearby_cafe_card.dart
│   │   │       └── section_header.dart
│   │   │
│   │   ├── explore/
│   │   │   ├── bloc/
│   │   │   │   ├── search_bloc.dart
│   │   │   │   ├── search_event.dart
│   │   │   │   └── search_state.dart
│   │   │   ├── pages/
│   │   │   │   └── explore_page.dart
│   │   │   └── widgets/
│   │   │       ├── filter_bottom_sheet.dart
│   │   │       └── map_view.dart
│   │   │
│   │   ├── detail/
│   │   │   ├── bloc/
│   │   │   │   ├── detail_bloc.dart
│   │   │   │   ├── detail_event.dart
│   │   │   │   └── detail_state.dart
│   │   │   ├── pages/
│   │   │   │   └── cafe_detail_page.dart
│   │   │   └── widgets/
│   │   │       ├── gallery_hero.dart
│   │   │       └── opening_hours_tile.dart
│   │   │
│   │   ├── favourites/
│   │   │   ├── bloc/
│   │   │   │   ├── favourites_bloc.dart
│   │   │   │   ├── favourites_event.dart
│   │   │   │   └── favourites_state.dart
│   │   │   └── pages/
│   │   │       └── favourites_page.dart
│   │   │
│   │   ├── auth/
│   │   │   ├── bloc/
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   └── auth_state.dart
│   │   │   └── pages/
│   │   │       ├── splash_page.dart
│   │   │       └── onboarding_page.dart
│   │   │
│   │   └── settings/
│   │       ├── cubit/
│   │       │   ├── settings_cubit.dart   # Cubit (simpler than Bloc)
│   │       │   └── settings_state.dart
│   │       └── pages/
│   │           └── settings_page.dart
│   │
│   └── shared/                      ← REUSABLE WIDGETS
│       ├── widgets/
│       │   ├── coffee_card.dart
│       │   ├── rating_stars.dart
│       │   ├── loading_shimmer.dart
│       │   └── error_display_widget.dart
│       └── extensions/
│           ├── context_ext.dart
│           └── bloc_listener_ext.dart
│
├── test/
│   ├── unit/
│   │   ├── blocs/
│   │   └── usecases/
│   ├── widget/
│   └── integration/
└── pubspec.yaml
