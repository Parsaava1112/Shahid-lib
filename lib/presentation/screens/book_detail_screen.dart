import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/book_model.dart';
import '../../core/database/db_helper.dart';
import '../widgets/rating_widget.dart';
import 'pdf_viewer_screen.dart';
import 'audio_player_screen.dart';
import 'video_player_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final BookModel book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = widget.book;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ==================== AppBar با Hero ====================
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                book.title,
                style: GoogleFonts.vazirmatn(
                  fontSize: 14,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Hero(
                tag: 'book_cover_${book.id}',
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      book.type == 'pdf'
                          ? Icons.picture_as_pdf
                          : book.type == 'audio'
                              ? Icons.headphones
                              : Icons.videocam,
                      size: 100,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ==================== بدنه ====================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان
                  Text(
                    book.title,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 8),

                  // نویسنده
                  Text(
                    book.author,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 16),

                  // امتیاز و دسته
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${book.rating.toStringAsFixed(1)} '
                        '(${book.ratingCount} امتیاز)',
                        style: GoogleFonts.vazirmatn(),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          book.category,
                          style: GoogleFonts.vazirmatn(fontSize: 11),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // توضیحات
                  Text(
                    'درباره این کتاب',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description.isEmpty
                        ? 'توضیحی موجود نیست.'
                        : book.description,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 14,
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // دکمه‌های اقدام
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _openBook(context, book),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        _getButtonLabel(book.type),
                        style: GoogleFonts.vazirmatn(fontSize: 16),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).scale(),

                  const SizedBox(height: 16),

                  // Rating Widget
                  RatingWidget(
                    bookId: book.id ?? 0,
                    initialRating: book.rating,
                    onRatingChanged: (value) {
                      // ثبت امتیاز جدید
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonLabel(String type) {
    switch (type) {
      case 'pdf':
        return 'شروع مطالعه';
      case 'audio':
        return 'پخش کتاب صوتی';
      case 'video':
        return 'پخش ویدیو';
      default:
        return 'باز کردن';
    }
  }

  void _openBook(BuildContext context, BookModel book) {
    Widget screen;
    switch (book.type) {
      case 'pdf':
        screen = PdfViewerScreen(book: book);
        break;
      case 'audio':
        screen = AudioPlayerScreen(book: book);
        break;
      case 'video':
        screen = VideoPlayerScreen(book: book);
        break;
      default:
        screen = PdfViewerScreen(book: book);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}