import 'package:flutter/material.dart';
import 'package:flutter_dice_bear/flutter_dice_bear.dart';
import 'package:animate_do/animate_do.dart';

class AnimatedAvatar extends StatelessWidget {
  final String seed;
  final String style;
  final double size;
  final VoidCallback? onTap;

  const AnimatedAvatar({
    super.key,
    required this.seed,
    this.style = 'adventurer',
    this.size = 100,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      duration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatar(),
          ),
        ),
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