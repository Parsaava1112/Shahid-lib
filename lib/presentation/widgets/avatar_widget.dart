import 'package:flutter/material.dart';
import 'package:flutter_dice_bear/flutter_dice_bear.dart';

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