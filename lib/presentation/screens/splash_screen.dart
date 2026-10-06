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
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _progressCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, a, __) => const LoginScreen(),
        transitionsBuilder: (_, a, __, child) {
          return FadeTransition(
            opacity: a,
            child: ScaleTransition(
              scale: Tween(begin: 1.05, end: 1.0).animate(a),
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
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: AnimatedBackground(
        intensity: 1.5,
        blobCount: 8,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.background.withOpacity(0.4),
                scheme.background,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildAnimatedLogo(scheme),
                const SizedBox(height: 40),
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

  // ==================== لوگوی متحرک با تصویر اصلی ====================

  Widget _buildAnimatedLogo(ColorScheme scheme) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // حلقه‌های چرخان پشت لوگو
          AnimatedBuilder(
            animation: _ringCtrl,
            builder: (_, __) {
              return CustomPaint(
                size: const Size(240, 240),
                painter: _RingsPainter(
                  t: _ringCtrl.value,
                  color: scheme.secondary,
                ),
              );
            },
          ),

          // ذرات چرخان دور لوگو
          ...List.generate(8, (i) {
            return AnimatedBuilder(
              animation: _ringCtrl,
              builder: (_, __) {
                final angle = (_ringCtrl.value * math.pi * 2) +
                    (i * math.pi * 2 / 8);
                final r = 105 +
                    math.sin(_ringCtrl.value * math.pi * 4 + i) * 8;
                return Transform.translate(
                  offset: Offset(math.cos(angle) * r, math.sin(angle) * r),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: scheme.secondary.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: scheme.secondary.withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          // هاله نورانی پشت لوگو
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) {
              return Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary
                          .withOpacity(0.3 + _glowCtrl.value * 0.3),
                      blurRadius: 40 + _glowCtrl.value * 20,
                      spreadRadius: 4 + _glowCtrl.value * 6,
                    ),
                  ],
                ),
              );
            },
          ),

          // 🌟 لوگوی اصلی اپلیکیشن
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _logoCtrl,
              curve: Curves.elasticOut,
            ),
            child: FadeTransition(
              opacity: _logoCtrl,
              child: Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.95),
                    ],
                  ),
                  border: Border.all(
                    color: scheme.primary.withOpacity(0.4),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.35),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.school_rounded,
                      size: 70,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== متن‌ها ====================

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // نام اصلی کتابخانه
              ShaderMask(
                shaderCallback: (r) => LinearGradient(
                  colors: [
                    scheme.primary,
                    scheme.secondary,
                    scheme.primary,
                  ],
                ).createShader(r),
                child: Text(
                  'کتابخانه شهید بهشتی',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 12),

              // نام کامل مدرسه
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.primary.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  'مدرسه استعداد های درخشان شهید بهشتی\nناحیه ۲ شهرری - متوسطه اول',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    color: scheme.onBackground.withOpacity(0.75),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // شعار
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 14,
                    color: scheme.primary.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'راهِ دانایی، راهِ آینده',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      color: scheme.onBackground.withOpacity(0.55),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            width: 180,
            height: 4,
            child: AnimatedBuilder(
              animation: _progressCtrl,
              builder: (_, __) {
                return CustomPaint(
                  painter: _ProgressPainter(
                    value: _progressCtrl.value,
                    color: scheme.primary,
                    bg: scheme.onBackground.withOpacity(0.1),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'در حال آماده‌سازی کتابخانه...',
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              color: scheme.onBackground.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Painters ====================

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
      final opacity = (1 - progress) * 0.6;
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
  final Color bg;

  _ProgressPainter({
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(r, Paint()..color = bg);
    final fill = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width * value, size.height),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(
      fill,
      Paint()
        ..shader = LinearGradient(
          colors: [color, color.withOpacity(0.6)],
        ).createShader(fill.outerRect),
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter old) => old.value != value;
}