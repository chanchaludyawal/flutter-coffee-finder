/// Cuproute — named route paths.
///
/// Every navigation call in the app must reference a constant from here.
/// Never hard-code a path string (e.g. '/home') outside this file.
///
/// Usage:
///   ```dart
///   import 'app_routes.dart';
///
///   context.go(AppRoutes.home);
///   context.push(AppRoutes.login);
///   GoRoute(path: AppRoutes.splash, builder: ...)
///   ```
abstract final class RouteNames {
  // ── Auth flow ─────────────────────────────────────────────────────────────

  /// Initial loading screen shown while auth state is resolving.
  static const String splash = '/splash';

  /// Three-page onboarding shown to first-time / unauthenticated users.
  static const String onboarding = '/onboarding';

  /// Email + social sign-in screen.
  static const String login = '/login';

  // ── Main shell tabs ───────────────────────────────────────────────────────
  // These are the four indexed branches of the StatefulShellRoute.

  /// Home feed — nearby cafés and recommendations.
  static const String home = '/home';

  /// Explore — search, filters, map view.
  static const String explore = '/explore';

  /// Favourites — saved cafés and routes.
  static const String favourites = '/favourites';

  /// Settings — account, preferences, about.
  static const String settings = '/settings';

  // ── Auth-screen guard helpers ─────────────────────────────────────────────
  //
  // Used in the redirect function to check whether the user is already on
  // an auth screen without spelling out every path inline.

  /// All paths that belong to the unauthenticated / pre-auth flow.
  static const List<String> authPaths = [splash, onboarding, login];

  /// Returns true if [location] is one of the auth-flow screens.
  static bool isAuthPath(String location) => authPaths.contains(location);
}
