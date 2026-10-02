import 'dart:math' as math;
import 'package:flutter/material.dart';

/// پس‌زمینه با شکل‌های هندسی متحرک که آرام شنا می‌کنند
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool showBlobs;
  final int blobCount;
  final double intensity;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.showBlobs = true,
    this.blobCount = 6,
    this.intensity = 1.0,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Blob> _blobs;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _blobs = List.generate(widget.blobCount, (i) {
      final r = math.Random(i * 42);
      return _Blob(
        baseX: r.nextDouble(),
        baseY: r.nextDouble(),
        radius: 60 + r.nextDouble() * 100,
        speed: 0.3 + r.nextDouble() * 0.7,
        phase: r.nextDouble() * math.pi * 2,
        colorIndex: i,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return CustomPaint(
                painter: _BlobPainter(
                  blobs: _blobs,
                  t: _ctrl.value,
                  colors: [
                    scheme.primary,
                    scheme.secondary,
                    scheme.tertiary,
                  ],
                  intensity: widget.intensity,
                ),
              );
            },
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _Blob {
  final double baseX;
  final double baseY;
  final double radius;
  final double speed;
  final double phase;
  final int colorIndex;

  _Blob({
    required this.baseX,
    required this.baseY,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.colorIndex,
  });
}

class _BlobPainter extends CustomPainter {
  final List<_Blob> blobs;
  final double t;
  final List<Color> colors;
  final double intensity;

  _BlobPainter({
    required this.blobs,
    required this.t,
    required this.colors,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in blobs) {
      final angle = t * math.pi * 2 * b.speed + b.phase;
      final cx = b.baseX * size.width + math.cos(angle) * 40;
      final cy = b.baseY * size.height + math.sin(angle) * 60;
      final r = b.radius * (1 + math.sin(angle * 1.3) * 0.15);

      final color = colors[b.colorIndex % colors.length]
          .withOpacity(0.08 * intensity);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color, color.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlobPainter old) => old.t != t;
}