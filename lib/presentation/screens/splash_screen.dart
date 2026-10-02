import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/widgets/animated_background.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _ringCtrl;
  late AnimationController _textCtrl;
  late AnimationController _progressCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _progressCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 1.06, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _ringCtrl.dispose();
    _textCtrl.dispose();
    _progressCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedBackground(
        intensity: 1.6,
        blobCount: 8,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.background.withOpacity(0.35),
                scheme.background,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildAnimatedLogo(scheme),
                const SizedBox(height: 44),
                _buildText(scheme),
                const Spacer(),
                _buildProgress(scheme),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== لوگوی متحرک ====================
  Widget _buildAnimatedLogo(ColorScheme scheme) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // حلقه‌های منتشر شونده
          AnimatedBuilder(
            animation: _ringCtrl,
            builder: (_, __) => CustomPaint(
              size: const Size(240, 240),
              painter: _RingsPainter(
                t: _ringCtrl.value,
                color: scheme.secondary,
              ),
            ),
          ),

          // ذرات چرخان
          ...List.generate(10, (i) {
            return AnimatedBuilder(
              animation: _ringCtrl,
              builder: (_, __) {
                final angle = (_ringCtrl.value * math.pi * 2) +
                    (i * math.pi * 2 / 10);
                final radius =
                    100 + math.sin(_ringCtrl.value * math.pi * 4 + i) * 10;
                final size = i.isEven ? 8.0 : 6.0;
                final opacity = i.isEven ? 0.85 : 0.55;
                return Transform.translate(
                  offset: Offset(
                    math.cos(angle) * radius,
                    math.sin(angle) * radius,
                  ),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: scheme.secondary.withOpacity(opacity),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: scheme.secondary.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          // هاله پالس‌دار
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 130 + _pulseCtrl.value * 20,
              height: 130 + _pulseCtrl.value * 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary
                        .withOpacity(0.35 - _pulseCtrl.value * 0.25),
                    blurRadius: 40 + _pulseCtrl.value * 20,
                    spreadRadius: 4 + _pulseCtrl.value * 8,
                  ),
                ],
              ),
            ),
          ),

          // لوگوی اصلی
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _logoCtrl,
              curve: Curves.elasticOut,
            ),
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    scheme.primary,
                    scheme.primary.withOpacity(0.7),
                  ],
                ),
                border: Border.all(
                  color: scheme.secondary.withOpacity(0.4),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: FadeTransition(
                opacity: _logoCtrl,
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 65,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== متن ====================
  Widget _buildText(ColorScheme scheme) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _textCtrl,
          curve: Curves.easeOutCubic,
        )),
        child: Column(
          children: [
            Text(
              'کتابخانه',
              style: GoogleFonts.vazirmatn(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: scheme.onBackground,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            ShaderMask(
              shaderCallback: (r) => LinearGradient(
                colors: [
                  scheme.primary,
                  scheme.secondary,
                  scheme.primary,
                ],
              ).createShader(r),
              child: Text(
                'شهید حاج قاسم سلیمانی',
                style: GoogleFonts.vazirmatn(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 1,
                  color: scheme.primary.withOpacity(0.4),
                ),
                const SizedBox(width: 12),
                Text(
                  'راهِ شهید، راهِ دانایی',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    color: scheme.onBackground.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 1,
                  color: scheme.primary.withOpacity(0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== نوار پیشرفت ====================
  Widget _buildProgress(ColorScheme scheme) {
    return FadeTransition(
      opacity: _progressCtrl,
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 5,
            child: AnimatedBuilder(
              animation: _progressCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ProgressPainter(
                  value: _progressCtrl.value,
                  color: scheme.primary,
                  secondary: scheme.secondary,
                  bg: scheme.onBackground.withOpacity(0.08),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: _progressCtrl,
            builder: (_, __) {
              final dots = (_progressCtrl.value * 10).floor().clamp(1, 3);
              return Text(
                'در حال آماده‌سازی${'.' * dots}',
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  color: scheme.onBackground.withOpacity(0.5),
                  letterSpacing: 0.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================== Painter ها ====================
class _RingsPainter extends CustomPainter {
  final double t;
  final Color color;

  _RingsPainter({required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (int i = 0; i < 3; i++) {
      final progress = (t + i / 3) % 1.0;
      final radius = 45 + progress * 75;
      final opacity = (1 - progress) * 0.55;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withOpacity(opacity);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.t != t;
}

class _ProgressPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color secondary;
  final Color bg;

  _ProgressPainter({
    required this.value,
    required this.color,
    required this.secondary,
    required this.bg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(r, Paint()..color = bg);

    final fillRect = Rect.fromLTWH(
      0,
      0,
      size.width * value,
      size.height,
    );
    final fill = RRect.fromRectAndRadius(
      fillRect,
      Radius.circular(size.height / 2),
    );

    canvas.drawRRect(
      fill,
      Paint()
        ..shader = LinearGradient(
          colors: [color, secondary],
        ).createShader(fillRect),
    );

    // دایره درخشان در نوک نوار
    if (value > 0.02) {
      final x = size.width * value;
      canvas.drawCircle(
        Offset(x, size.height / 2),
        size.height / 2 + 3,
        Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter old) => old.value != value;
}