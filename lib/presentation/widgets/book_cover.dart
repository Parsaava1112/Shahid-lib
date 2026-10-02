import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';

class BookCover extends StatelessWidget {
  final BookModel book;
  final double width;
  final double height;
  final double radius;
  final String? baseUrl;

  const BookCover({
    super.key,
    required this.book,
    this.width = 80,
    this.height = 110,
    this.radius = 14,
    this.baseUrl,
  });

  Color _typeColor(BuildContext context) {
    switch (book.type) {
      case 'pdf':
        return Theme.of(context).colorScheme.primary;
      case 'audio':
        return Colors.orange;
      case 'video':
        return Colors.redAccent;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _typeIcon() {
    switch (book.type) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'audio':
        return Icons.headphones_rounded;
      case 'video':
        return Icons.videocam_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(context);
    final theme = Theme.of(context);

    final String? fullCoverUrl = book.coverUrl.isEmpty
        ? null
        : (book.coverUrl.startsWith('http')
            ? book.coverUrl
            : (baseUrl != null ? '$baseUrl${book.coverUrl}' : null));

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: fullCoverUrl != null
            ? Image.network(
                fullCoverUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(theme, color),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return _placeholder(theme, color, loading: true);
                },
              )
            : _placeholder(theme, color),
      ),
    );
  }

  Widget _placeholder(ThemeData theme, Color color, {bool loading = false}) {
    return Center(
      child: loading
          ? SizedBox(
              width: width * 0.3,
              height: width * 0.3,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          : Icon(
              _typeIcon(),
              size: width * 0.4,
              color: color,
            ),
    );
  }
}