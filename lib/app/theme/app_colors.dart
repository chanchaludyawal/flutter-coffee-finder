import 'package:flutter/material.dart';

/// Cuproute brand color palette.
///
/// Every color used anywhere in the app should reference a constant from here.
/// Never hard-code a [Color] value outside this file.
///
/// Usage:
///   ```dart
///   import 'app_colors.dart';
///
///   Container(color: AppColors.background)
///   Text('Hello', style: TextStyle(color: AppColors.textPrimary))
///   ```
abstract final class AppColors {
  // ── Base ────────────────────────────────────────────────────────────────────

  /// Rich coffee-brown. Primary buttons, active icons, key UI chrome.
  static const Color primary = Color(0xFF6F4E37);

  /// Darker roast. Pressed states, elevated surfaces on [primary].
  static const Color primaryDark = Color(0xFF4A3425);

  /// Warm tan. Secondary actions, highlights, tags, progress indicators.
  static const Color accent = Color(0xFFD2B48C);

  // ── Surfaces ─────────────────────────────────────────────────────────────

  /// Off-white parchment. App scaffold background.
  static const Color background = Color(0xFFFDFBF7);

  /// Pure white. Cards, sheets, dialogs, input fills.
  static const Color surface = Colors.white;

  // ── Text ──────────────────────────────────────────────────────────────────

  /// Near-black espresso. Headlines, body copy.
  static const Color textPrimary = Color(0xFF2C221E);

  /// Muted warm-grey. Captions, placeholders, secondary labels.
  static const Color textSecondary = Color(0xFF756A63);

  // ── Semantic ──────────────────────────────────────────────────────────────

  /// Error red. Destructive actions, validation failures.
  static const Color error = Color(0xFFD32F2F);

  /// Success green. Confirmations, availability indicators.
  static const Color success = Color(0xFF388E3C);

  // ── Splash-specific aliases ───────────────────────────────────────────────
  // These are not new values — just named aliases so the splash (and any
  // future dark-background screen) reads clearly without magic color literals.

  /// Dark splash/onboarding background: [primaryDark] at full opacity.
  static const Color splashBackground = primaryDark;

  /// Text on dark surfaces: inverted, warm white derived from [background].
  static const Color onDark = background;

  /// Subtle stroke/steam on dark surfaces: [primary] lightened via opacity.
  /// Use with an [Opacity] widget or [Color.withValues] as needed.
  static const Color onDarkMuted = primary; // apply .withValues(alpha: 0.5)
}
