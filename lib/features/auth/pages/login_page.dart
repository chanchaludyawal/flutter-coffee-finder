import 'package:cuproute/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'dart:math' as math;

// ── Callbacks ─────────────────────────────────────────────────────────────────
//
// Keep auth logic outside the UI layer. Pass these in from your router/BLoC.

typedef AuthEmailCallback = void Function(String email, String password);
typedef AuthProviderCallback = void Function();

// ── Page ──────────────────────────────────────────────────────────────────────

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onLoginWithGoogle,
    this.onLoginWithFacebook,
    this.onLoginWithEmailPassword,
    this.onNavigateToSignUp,
    this.onForgotPassword,
  });

  final AuthProviderCallback? onLoginWithGoogle;
  final AuthProviderCallback? onLoginWithFacebook;
  final AuthEmailCallback? onLoginWithEmailPassword;
  final VoidCallback? onNavigateToSignUp;
  final VoidCallback? onForgotPassword;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _riseAnim;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    );

    _riseAnim = Tween<double>(begin: 28.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _entranceController.forward(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  bool _validate() {
    String? emailErr;
    String? passErr;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      emailErr = 'Enter your email address';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      emailErr = 'That doesn\'t look like a valid email';
    }

    final pass = _passwordController.text;
    if (pass.isEmpty) {
      passErr = 'Enter your password';
    } else if (pass.length < 6) {
      passErr = 'Password must be at least 6 characters';
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return emailErr == null && passErr == null;
  }

  Future<void> _submitEmailPassword() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);
    widget.onLoginWithEmailPassword?.call(
      _emailController.text.trim(),
      _passwordController.text,
    );
    // Caller is responsible for clearing _isLoading via navigation or error state.
    // In a real app, await the auth future here and catch errors.
    if (mounted) setState(() => _isLoading = false);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) => Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _riseAnim.value),
            child: child,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // ── Brand header ───────────────────────────────
                _BrandHeader(),

                const SizedBox(height: 40),

                // ── Email field ────────────────────────────────
                _InputField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  hint: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  error: _emailError,
                  onChanged: (_) {
                    if (_emailError != null) {
                      setState(() => _emailError = null);
                    }
                  },
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                ),

                const SizedBox(height: 14),

                // ── Password field ─────────────────────────────
                _InputField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  hint: 'Password',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  error: _passwordError,
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                  onSubmitted: (_) => _submitEmailPassword(),
                  suffix: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        _obscurePassword ? 'Show' : 'Hide',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Forgot password ────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: widget.onForgotPassword,
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Sign in button ─────────────────────────────
                _PrimaryButton(
                  label: 'Sign in',
                  isLoading: _isLoading,
                  onTap: _submitEmailPassword,
                ),

                const SizedBox(height: 32),

                // ── Divider ────────────────────────────────────
                const _OrDivider(),

                const SizedBox(height: 28),

                // ── Social buttons ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        label: 'Google',
                        iconPainter: _GoogleIconPainter(),
                        onTap: widget.onLoginWithGoogle,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _SocialButton(
                        label: 'Facebook',
                        iconPainter: _FacebookIconPainter(),
                        onTap: widget.onLoginWithFacebook,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 44),

                // ── Sign up link ───────────────────────────────
                GestureDetector(
                  onTap: widget.onNavigateToSignUp,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(text: 'New to Cuproute? '),
                        TextSpan(
                          text: 'Create an account',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Brand header ──────────────────────────────────────────────────────────────

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Coffee ring motif
        SizedBox(
          width: 64,
          height: 64,
          child: CustomPaint(painter: _CoffeeRingPainter()),
        ),
        const SizedBox(height: 20),
        const Text(
          'Cuproute',
          style: TextStyle(
            fontFamily: 'DM Serif Display',
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign in to your account',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Input field ───────────────────────────────────────────────────────────────

class _InputField extends StatefulWidget {
  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.error,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? error;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _focused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : _focused
                  ? AppColors.primary
                  : AppColors.accent.withValues(alpha: 0.55),
              width: _focused || hasError ? 1.8 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              if (widget.suffix != null) widget.suffix!,
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.error!,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Primary button ────────────────────────────────────────────────────────────

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLoading;

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
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.primaryDark : AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.onDark),
                ),
              )
            : Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onDark,
                  letterSpacing: 0.1,
                ),
              ),
      ),
    );
  }
}

// ── Or divider ────────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.0),
                  AppColors.accent.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.55),
                  AppColors.accent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Social button ─────────────────────────────────────────────────────────────

class _SocialButton extends StatefulWidget {
  const _SocialButton({
    required this.label,
    required this.iconPainter,
    this.onTap,
  });

  final String label;
  final CustomPainter iconPainter;
  final VoidCallback? onTap;

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 50,
        decoration: BoxDecoration(
          color: _pressed
              ? AppColors.accent.withValues(alpha: 0.10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _pressed
                ? AppColors.primary
                : AppColors.accent.withValues(alpha: 0.55),
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(painter: widget.iconPainter),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Custom painters — no asset files needed
// ═════════════════════════════════════════════════════════════════════════════

// ── Coffee ring brand mark ────────────────────────────────────────────────────

class _CoffeeRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Outer ring
    canvas.drawCircle(
      c,
      r - 2,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Inner ring
    canvas.drawCircle(
      c,
      r * 0.55,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Center dot
    canvas.drawCircle(c, r * 0.14, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(_CoffeeRingPainter old) => false;
}

// ── Google "G" icon ───────────────────────────────────────────────────────────

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Four-color arc segments approximating the Google G
    final segments = [
      (AppColors.error, -math.pi / 6, math.pi * 2 / 3), // red
      (const Color(0xFFFBBC05), math.pi / 2, math.pi / 2), // yellow
      (const Color(0xFF34A853), math.pi, math.pi / 2), // green
      (const Color(0xFF4285F4), math.pi * 3 / 2, math.pi / 3), // blue
    ];

    for (final (color, start, sweep) in segments) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r - 1),
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.butt,
      );
    }

    // Horizontal bar of the G
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r - 1, cy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GoogleIconPainter old) => false;
}

// ── Facebook "f" icon ─────────────────────────────────────────────────────────

class _FacebookIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Circle background
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      w / 2,
      Paint()..color = const Color(0xFF1877F2),
    );

    // "f" letterform
    final fPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Vertical stem
    canvas.drawLine(
      Offset(w * 0.54, h * 0.30),
      Offset(w * 0.54, h * 0.85),
      fPaint,
    );

    // Top curve of f
    canvas.drawArc(
      Rect.fromLTWH(w * 0.34, h * 0.15, w * 0.40, h * 0.30),
      math.pi,
      -math.pi / 2,
      false,
      fPaint,
    );

    // Crossbar
    canvas.drawLine(
      Offset(w * 0.34, h * 0.52),
      Offset(w * 0.68, h * 0.52),
      fPaint,
    );
  }

  @override
  bool shouldRepaint(_FacebookIconPainter old) => false;
}
