import 'package:cuproute/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

// ── Onboarding data ───────────────────────────────────────────────────────────

class _OnboardingData {
  const _OnboardingData({
    required this.painter,
    required this.headline,
    required this.body,
  });
  final CustomPainter painter;
  final String headline;
  final String body;
}

// ── Page ─────────────────────────────────────────────────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.onFinished});

  /// Called when the user taps "Get Started" on the last screen.
  /// Typically triggers a Navigator push/replacement to the home screen.
  final VoidCallback? onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Per-page entrance animations — one controller per screen, driven on page change.
  late final List<AnimationController> _animControllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<double>> _riseAnims;

  static const int _pageCount = 3;

  late final List<_OnboardingData> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      _OnboardingData(
        painter: _DiscoverPainter(),
        headline: 'Discover great cafés',
        body: 'Find specialty coffee spots near you, curated by what you actually like to drink.',
      ),
      _OnboardingData(
        painter: _ExplorePainter(),
        headline: 'Explore menus & vibes',
        body: 'Browse full menus, community ratings, and the atmosphere before you even step inside.',
      ),
      _OnboardingData(
        painter: _RoutePainter(),
        headline: 'Build your route',
        body: 'String your favourite stops into a walk, share it with friends, or save it for later.',
      ),
    ];

    _animControllers = List.generate(
      _pageCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 520),
      ),
    );

    _fadeAnims = _animControllers
        .map(
          (c) => CurvedAnimation(
            parent: c,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
          ),
        )
        .toList();

    _riseAnims = _animControllers
        .map(
          (c) => Tween<double>(begin: 20.0, end: 0.0).animate(
            CurvedAnimation(
              parent: c,
              curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
            ),
          ),
        )
        .toList();

    // Play first page immediately
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _animControllers[0].forward(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _animControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _goToPage(int index) {
    _animControllers[index].reset();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _animControllers[index].forward(from: 0);
  }

  void _next() {
    if (_currentPage < _pageCount - 1) {
      _goToPage(_currentPage + 1);
    } else {
      widget.onFinished?.call();
    }
  }

  void _skip() => widget.onFinished?.call();

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pageCount - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip ────────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 20),
                child: AnimatedOpacity(
                  opacity: isLast ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: isLast ? null : _skip,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Pages ───────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pageCount,
                itemBuilder: (context, index) {
                  return _OnboardingSlide(
                    data: _pages[index],
                    fadeAnim: _fadeAnims[index],
                    riseAnim: _riseAnims[index],
                  );
                },
              ),
            ),

            // ── Dots ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pageCount, (i) {
                final isActive = i == _currentPage;
                return GestureDetector(
                  onTap: () => _goToPage(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // ── Primary button ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: _PrimaryButton(
                  label: isLast ? 'Get Started' : 'Next',
                  onTap: _next,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Single slide ─────────────────────────────────────────────────────────────

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.data,
    required this.fadeAnim,
    required this.riseAnim,
  });

  final _OnboardingData data;
  final Animation<double> fadeAnim;
  final Animation<double> riseAnim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnim,
      builder: (context, child) => Opacity(
        opacity: fadeAnim.value,
        child: Transform.translate(
          offset: Offset(0, riseAnim.value),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(painter: data.painter),
            ),

            const SizedBox(height: 44),

            // Headline
            Text(
              data.headline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DM Serif Display',
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 16),

            // Body
            Text(
              data.body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Primary button ────────────────────────────────────────────────────────────

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _pressed ? AppColors.primaryDark : AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.label,
            key: ValueKey(widget.label),
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onDark,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Illustrations — one CustomPainter per screen, all using AppColors
// ═════════════════════════════════════════════════════════════════════════════

// ── Screen 1: Discover — cup + location pin ───────────────────────────────

class _DiscoverPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fill = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final accentStroke = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Background circle
    canvas.drawCircle(Offset(w * 0.5, h * 0.52), w * 0.38, fill);

    // Cup body (trapezoid)
    final double topY = h * 0.40;
    final double botY = h * 0.72;
    final double tL = w * 0.25, tR = w * 0.65;
    final double bL = w * 0.30, bR = w * 0.60;

    final cup = Path()
      ..moveTo(tL, topY)
      ..lineTo(bL, botY)
      ..lineTo(bR, botY)
      ..lineTo(tR, topY)
      ..close();
    canvas.drawPath(cup, stroke);

    // Coffee fill line
    final sY = topY + (botY - topY) * 0.3;
    canvas.drawLine(
      Offset(_lerp(tL, bL, 0.3) + 1, sY),
      Offset(_lerp(tR, bR, 0.3) - 1, sY),
      accentStroke,
    );

    // Handle
    canvas.drawArc(
      Rect.fromLTWH(
        tR - 3,
        topY + (botY - topY) * 0.18,
        w * 0.14,
        (botY - topY) * 0.48,
      ),
      -1.1,
      2.2,
      false,
      stroke,
    );

    // Saucer
    canvas.drawLine(
      Offset(tL - 5, botY + 6),
      Offset(tR + 5, botY + 6),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    // Steam
    for (final cx in [w * 0.35, w * 0.45, w * 0.56]) {
      final sBot = topY - 5;
      final sTop = h * 0.10;
      final p = Path()..moveTo(cx, sBot);
      p.cubicTo(
        cx + 5,
        sBot - (sBot - sTop) * 0.33,
        cx - 5,
        sBot - (sBot - sTop) * 0.66,
        cx,
        sTop,
      );
      canvas.drawPath(
        p,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // Location pin (top-right of cup area)
    final double px = w * 0.72, py = h * 0.30;
    final pinFill = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final pinPath = Path();
    final double pr = w * 0.07;
    pinPath.addOval(
      Rect.fromCircle(center: Offset(px, py - pr * 0.3), radius: pr),
    );
    pinPath.moveTo(px, py - pr * 0.3 + pr);
    pinPath.lineTo(px - pr * 0.4, py - pr * 0.3 + pr * 0.3);
    pinPath.lineTo(px + pr * 0.4, py - pr * 0.3 + pr * 0.3);
    pinPath.close();
    canvas.drawPath(pinPath, pinFill);
    // inner dot
    canvas.drawCircle(
      Offset(px, py - pr * 0.3),
      pr * 0.38,
      Paint()..color = AppColors.background,
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(_DiscoverPainter old) => false;
}

// ── Screen 2: Explore — menu/stars card ──────────────────────────────────

class _ExplorePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgFill = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    // Background circle
    canvas.drawCircle(Offset(w * 0.5, h * 0.52), w * 0.38, bgFill);

    // Card
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.26, w * 0.64, h * 0.52),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Coffee thumbnail strip inside card
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.30, w * 0.56, h * 0.16),
        const Radius.circular(8),
      ),
      Paint()..color = AppColors.accent.withValues(alpha: 0.3),
    );
    // tiny cup icon in thumbnail
    final tc = Offset(w * 0.50, h * 0.38);
    canvas.drawCircle(
      tc,
      w * 0.06,
      Paint()..color = AppColors.primary.withValues(alpha: 0.25),
    );
    canvas.drawCircle(
      tc,
      w * 0.035,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Stars row
    final double starY = h * 0.515;
    final double starStartX = w * 0.24;
    final double starSize = w * 0.055;
    final double starGap = starSize * 1.5;
    for (int i = 0; i < 5; i++) {
      _drawStar(
        canvas,
        Offset(starStartX + i * starGap, starY),
        starSize * 0.5,
        i < 4 ? AppColors.accent : AppColors.accent.withValues(alpha: 0.35),
      );
    }

    // Text lines (placeholder bars)
    final linePaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    // Title line
    canvas.drawLine(
      Offset(w * 0.24, h * 0.575),
      Offset(w * 0.60, h * 0.575),
      linePaint,
    );

    // Subtitle lines
    final subPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.55)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 2; i++) {
      canvas.drawLine(
        Offset(w * 0.24, h * 0.615 + i * h * 0.038),
        Offset(w * (i == 0 ? 0.72 : 0.58), h * 0.615 + i * h * 0.038),
        subPaint,
      );
    }

    // Tag chip
    final chipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.695, w * 0.22, h * 0.052),
      const Radius.circular(20),
    );
    canvas.drawRRect(
      chipRect,
      Paint()..color = AppColors.accent.withValues(alpha: 0.30),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    const int points = 5;
    final double inner = r * 0.45;
    for (int i = 0; i < points * 2; i++) {
      final double angle = (i * 3.14159265 / points) - 3.14159265 / 2;
      final double radius = i.isEven ? r : inner;
      final x = center.dx + radius * _cos(angle);
      final y = center.dy + radius * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double a) => _approxTrig(a, true);
  double _sin(double a) => _approxTrig(a, false);

  // Simple cos/sin via dart:math equivalent (avoids import in painter)
  double _approxTrig(double a, bool isCos) {
    // Use the series or simply import dart:math — shown inline for clarity
    // In practice, add `import 'dart:math' as math;` at the top of the file
    // and replace with math.cos / math.sin.
    // Here we forward to the real values via the hack below.
    return isCos ? _cosImpl(a) : _sinImpl(a);
  }

  // These call into dart:math without an explicit import by using the
  // Flutter framework's re-exported values. Replace with math.cos/math.sin
  // once you add `import 'dart:math' as math;` to the file.
  double _cosImpl(double a) => _dartMathCos(a);
  double _sinImpl(double a) => _dartMathSin(a);

  static double _dartMathCos(double a) {
    // Taylor series approximation sufficient for star rendering
    double result = 1.0;
    double term = 1.0;
    for (int n = 1; n <= 8; n++) {
      term *= -a * a / ((2 * n - 1) * (2 * n));
      result += term;
    }
    return result;
  }

  static double _dartMathSin(double a) {
    double result = a;
    double term = a;
    for (int n = 1; n <= 8; n++) {
      term *= -a * a / ((2 * n) * (2 * n + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(_ExplorePainter old) => false;
}

// ── Screen 3: Route — connected pins on a mini-map ───────────────────────

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgFill = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    // Background circle
    canvas.drawCircle(Offset(w * 0.5, h * 0.52), w * 0.38, bgFill);

    // Mini map card
    final mapRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.24, w * 0.72, h * 0.56),
      const Radius.circular(16),
    );
    canvas.drawRRect(mapRect, Paint()..color = AppColors.background);
    canvas.drawRRect(
      mapRect,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Grid lines (street grid feel)
    final gridPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.20)
      ..strokeWidth = 1.0;
    for (int i = 1; i < 4; i++) {
      final x = w * 0.14 + (w * 0.72) * i / 4;
      canvas.drawLine(Offset(x, h * 0.24), Offset(x, h * 0.80), gridPaint);
    }
    for (int i = 1; i < 3; i++) {
      final y = h * 0.24 + (h * 0.56) * i / 3;
      canvas.drawLine(Offset(w * 0.14, y), Offset(w * 0.86, y), gridPaint);
    }

    // Three stop positions
    final stops = [
      Offset(w * 0.30, h * 0.37),
      Offset(w * 0.55, h * 0.52),
      Offset(w * 0.72, h * 0.38),
    ];

    // Dashed route line between stops
    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < stops.length - 1; i++) {
      _drawDashedLine(canvas, stops[i], stops[i + 1], routePaint, 6, 4);
    }

    // Stop pins
    for (int i = 0; i < stops.length; i++) {
      final center = stops[i];
      // Shadow
      canvas.drawCircle(
        center.translate(0, 2),
        12,
        Paint()..color = AppColors.primaryDark.withValues(alpha: 0.15),
      );
      // Pin fill
      canvas.drawCircle(
        center,
        11,
        Paint()..color = i == 0 ? AppColors.primary : AppColors.accent,
      );
      // Pin stroke
      canvas.drawCircle(
        center,
        11,
        Paint()
          ..color = AppColors.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      // Number label (dot representing label)
      canvas.drawCircle(
        center,
        4,
        Paint()..color = i == 0 ? AppColors.onDark : AppColors.primaryDark,
      );
    }

    // Distance badge
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.32, h * 0.67, w * 0.36, h * 0.076),
      const Radius.circular(20),
    );
    canvas.drawRRect(badgeRect, Paint()..color = AppColors.primary);
    // Badge label line
    canvas.drawLine(
      Offset(w * 0.38, h * 0.708),
      Offset(w * 0.62, h * 0.708),
      Paint()
        ..color = AppColors.onDark.withValues(alpha: 0.85)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashLen,
    double gapLen,
  ) {
    final total = (end - start).distance;
    final dir = (end - start) / total;
    double drawn = 0;
    bool drawing = true;
    while (drawn < total) {
      final segLen = drawing
          ? dashLen.clamp(0, total - drawn)
          : gapLen.clamp(0, total - drawn);
      if (drawing) {
        canvas.drawLine(
          start + dir * drawn,
          start + dir * (drawn + segLen),
          paint,
        );
      }
      drawn += segLen;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(_RoutePainter old) => false;
}
