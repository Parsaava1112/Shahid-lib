import 'package:flutter/material.dart';
import 'package:dicebear_offline/dicebear_offline.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdvancedAvatar extends StatelessWidget {
  final String seed;
  final AvatarStyle style;
  final double size;

  const AdvancedAvatar({
    super.key,
    required this.seed,
    this.style = AvatarStyle.personas,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    final svgString = SvgEngine.generateSvg(
      style: style,
      seed: seed,
      // سایر پارامترها قابل تنظیم است
    );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.string(
          svgString,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}