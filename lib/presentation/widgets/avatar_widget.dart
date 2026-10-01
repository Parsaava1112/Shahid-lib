import 'package:flutter/material.dart';

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
    final cleanSeed = Uri.encodeComponent(
      seed.isEmpty ? 'default' : seed,
    );
    final url =
        'https://api.dicebear.com/7.x/$style/svg?seed=$cleanSeed';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 3,
        ),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.person,
            size: size * 0.6,
            color: Theme.of(context).colorScheme.primary,
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}