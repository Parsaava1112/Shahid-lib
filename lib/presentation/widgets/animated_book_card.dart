// lib/presentation/widgets/animated_book_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedBookCard extends StatelessWidget {
  final dynamic book;
  final int index;
  final VoidCallback onTap;

  const AnimatedBookCard({
    super.key,
    required this.book,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Hero(
      tag: 'book_cover_${book.id}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    book.type == 'pdf' ? Icons.picture_as_pdf
                        : book.type == 'audio' ? Icons.headphones
                        : Icons.videocam,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(book.author, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${book.rating.toStringAsFixed(1)}'),
                          const Spacer(),
                          if (book.isDownloaded)
                            Icon(Icons.download_done, size: 18,
                                color: theme.colorScheme.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
          delay: (100 * index).ms,
          duration: 400.ms,
        ).slideX(begin: 0.2, end: 0);
  }
}