import 'package:flutter/material.dart';

class DiceBearAvatar extends StatelessWidget {
  final String seed;
  final String style;
  final double size;
  final bool withBorder;
  final VoidCallback? onTap;

  const DiceBearAvatar({
    super.key,
    required this.seed,
    this.style = 'adventurer',
    this.size = 80,
    this.withBorder = true,
    this.onTap,
  });

  static const List<String> availableStyles = [
    'adventurer',
    'avataaars',
    'big-ears',
    'bottts',
    'croodles',
    'fun-emoji',
    'lorelei',
    'micah',
    'miniavs',
    'notionists',
    'open-peeps',
    'personas',
    'pixel-art',
    'thumbs',
  ];

  String get _url {
    final s = seed.isEmpty ? 'shahid' : Uri.encodeComponent(seed);
    return 'https://api.dicebear.com/7.x/$style/png?seed=$s&size=256&backgroundType=gradientLinear';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withOpacity(0.15),
            scheme.secondary.withOpacity(0.15),
          ],
        ),
        border: withBorder
            ? Border.all(
                color: scheme.primary.withOpacity(0.4),
                width: 3,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          _url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox(
                width: size * 0.35,
                height: size * 0.35,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => Icon(
            Icons.person_rounded,
            size: size * 0.55,
            color: scheme.primary,
          ),
        ),
      ),
    );

    if (onTap == null) return avatar;
    return GestureDetector(onTap: onTap, child: avatar);
  }
}