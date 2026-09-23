import 'dart:async';

import 'package:cuproute/app/constants/route_names.dart';
import 'package:cuproute/app/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/auth/pages/splash_page.dart';
import '../features/auth/pages/onboarding_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/explore/pages/explore_page.dart';
import '../features/favourites/pages/favourites_page.dart';
import '../features/settings/pages/settings_page.dart';

class AppRouter {
  final AuthBloc _authBloc;

  AppRouter(this._authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash, // ← RouteNames
    // Subscribes to AuthBloc's stream — when emit() fires,
    // GoRouter re-runs redirect() automatically.
    refreshListenable: _GoRouterBlocBridge(_authBloc),

    redirect: (context, state) {
      final auth = _authBloc.state;
      final loc = state.matchedLocation;

      // ── Use the helper instead of checking string literals ──
      final isOnAuthScreen = RouteNames.isAuthPath(loc);

      if (auth is AuthLoading || auth is AuthInitial) {
        return RouteNames.splash; // ← RouteNames
      }
      if (auth is Unauthenticated) {
        // Already on an auth screen — stay put; otherwise send to onboarding
        return isOnAuthScreen ? null : RouteNames.onboarding; // ← RouteNames
      }
      if (auth is Authenticated) {
        // Logged in — bounce off auth screens into the app
        return isOnAuthScreen ? RouteNames.home : null; // ← RouteNames
      }
      if (auth is AuthFailure) {
        return RouteNames.onboarding; // ← RouteNames (kick to auth on error)
      }

      return null; // no redirect needed
    },

    routes: [
      // ── Auth flow ──────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash, // ← RouteNames
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding, // ← RouteNames
        builder: (context, __) =>
            OnboardingPage(onFinished: () => context.go(RouteNames.login)),
      ),
      GoRoute(
        path: RouteNames.login, // ← RouteNames
        builder: (_, __) => const LoginPage(),
      ),

      // ── Main shell (bottom-nav tabs) ───────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home, // ← RouteNames
                builder: (_, __) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.explore, // ← RouteNames
                builder: (_, __) => const ExplorePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.favourites, // ← RouteNames
                builder: (_, __) => const FavouritesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.settings, // ← RouteNames
                builder: (_, __) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// ── Bridge: converts Bloc stream → ChangeNotifier ─────────────────────────────
//
// GoRouter needs a Listenable. Bloc emits a Stream.
// This translates between them: every emit() in AuthBloc triggers
// notifyListeners() here, which tells GoRouter to re-evaluate redirect().

class _GoRouterBlocBridge extends ChangeNotifier {
  _GoRouterBlocBridge(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
