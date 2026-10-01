import 'package:flutter/material.dart';
// ✅ ایمپورت‌های صحیح
import 'package:dicebear_core/dicebear_core.dart';
import 'package:dicebear_styles/adventurer.dart';
import 'package:dicebear_styles/fun_emoji.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AvatarWidget extends StatelessWidget {
  final String seed;
  final String style;
  final double size;

  const AvatarWidget({
    super.key,
    required this.seed,
    this.style = 'adventurer',
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 3,
        ),
      ),
      child: ClipOval(
        child: _buildAvatar(),
      ),
    );
  }

  Widget _buildAvatar() {
    switch (style) {
      case 'fun-emoji':
        return DiceBearWidget(
          style: FunEmojiStyle(
            options: FunEmojiOptions(seed: seed),
          ),
          width: size,
          height: size,
        );
      case 'bottts':
        return DiceBearWidget(
          style: BotttsStyle(
            options: BotttsOptions(seed: seed),
          ),
          width: size,
          height: size,
        );
      case 'adventurer':
      default:
        return DiceBearWidget(
          style: AdventurerStyle(
            options: AdventurerOptions(seed: seed),
          ),
          width: size,
          height: size,
        );
    }
  }
}