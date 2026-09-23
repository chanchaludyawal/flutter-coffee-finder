import 'package:cuproute/app/theme/app_colors.dart';
import 'package:flutter/widgets.dart';

// Cuproute – Splash Screen
// All colors come from AppColors. No hard-coded Color() values here.

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _riseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _riseAnim = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.splashBackground, // ← AppColors
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnim.value,
            child: Transform.translate(
              offset: Offset(0, _riseAnim.value),
              child: child,
            ),
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Coffee cup icon ──────────────────────────────
              SizedBox(
                width: 80,
                height: 80,
                child: CustomPaint(
                  painter: _CupPainter(
                    cupColor: AppColors.onDark, // ← AppColors
                    accentColor: AppColors.accent, // ← AppColors
                    steamColor: AppColors.onDarkMuted.withValues(
                      alpha: 0.5,
                    ), // ← AppColors
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Wordmark ─────────────────────────────────────
              Text(
                'Cuproute',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 38,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onDark, // ← AppColors
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),

              const SizedBox(height: 10),

              // ── Tagline ───────────────────────────────────────
              Text(
                'Find your next great cup',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.accent, // ← AppColors
                  letterSpacing: 0.2,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Custom cup painter ────────────────────────────────────────────────────────
class _CupPainter extends CustomPainter {
  const _CupPainter({
    required this.cupColor,
    required this.accentColor,
    required this.steamColor,
  });

  final Color cupColor;
  final Color accentColor;
  final Color steamColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = cupColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final steamPaint = Paint()
      ..color = steamColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final double topY = h * 0.38;
    final double botY = h * 0.76;
    final double topLeft = w * 0.18;
    final double topRight = w * 0.75;
    final double botLeft = w * 0.24;
    final double botRight = w * 0.69;

    // Cup body
    final cupPath = Path()
      ..moveTo(topLeft, topY)
      ..lineTo(botLeft, botY)
      ..lineTo(botRight, botY)
      ..lineTo(topRight, topY)
      ..close();
    canvas.drawPath(cupPath, strokePaint);

    // Coffee surface line
    final double surfaceY = topY + (botY - topY) * 0.28;
    final double surfaceLeft = _lerp(topLeft, botLeft, 0.28) + 1;
    final double surfaceRight = _lerp(topRight, botRight, 0.28) - 1;
    canvas.drawLine(
      Offset(surfaceLeft, surfaceY),
      Offset(surfaceRight, surfaceY),
      accentPaint,
    );

    // Handle
    final handleRect = Rect.fromLTWH(
      topRight - 3,
      topY + (botY - topY) * 0.15,
      w * 0.18,
      (botY - topY) * 0.54,
    );
    canvas.drawArc(handleRect, -1.1, 2.2, false, strokePaint);

    // Saucer
    final saucerY = botY + 5;
    canvas.drawLine(
      Offset(topLeft - 4, saucerY),
      Offset(topRight + 4, saucerY),
      Paint()
        ..color = cupColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Steam
    final double steamBot = topY - 4;
    final double steamTop = h * 0.06;
    for (final cx in [w * 0.33, w * 0.465, w * 0.60]) {
      final steamPath = Path()..moveTo(cx, steamBot);
      steamPath.cubicTo(
        cx + 6,
        steamBot - (steamBot - steamTop) * 0.3,
        cx - 6,
        steamBot - (steamBot - steamTop) * 0.6,
        cx,
        steamTop,
      );
      canvas.drawPath(steamPath, steamPaint);
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(_CupPainter old) =>
      old.cupColor != cupColor ||
      old.accentColor != accentColor ||
      old.steamColor != steamColor;
}
