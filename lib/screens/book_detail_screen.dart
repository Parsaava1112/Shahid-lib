import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';
import '../providers/user_provider.dart';
import 'pdf_viewer_screen.dart';
import 'audio_player_screen.dart';

class BookDetailScreen extends ConsumerWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final isFavorite = user?.favoriteBookIds.contains(book.id) ?? false;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // AppBar با تصویر جلد
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'book_cover_${book.id}',
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        book.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.book, size: 100),
                        ),
                      ),
                      // گرادینت روی تصویر
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // دکمه علاقه‌مندی
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    ref.read(userProfileProvider.notifier).toggleFavorite(book.id);
                  },
                ),
              ],
            ),
            
            // اطلاعات کتاب
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInUp(
                      child: Text(
                        book.title,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        'نویسنده: ${book.author}',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // امتیاز و دسته‌بندی
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.star,
                            label: book.rating.toStringAsFixed(1),
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            icon: Icons.category,
                            label: book.category,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // دکمه‌های عملیات
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Row(
                        children: [
                          if (book.pdfUrl != null)
                            Expanded(
                              child: _buildActionButton(
                                context,
                                icon: Icons.menu_book,
                                label: 'خواندن کتاب',
                                color: Theme.of(context).primaryColor,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PdfViewerScreen(book: book),
                                    ),
                                  );
                                },
                              ),
                            ),
                          if (book.pdfUrl != null && book.audioUrl != null)
                            const SizedBox(width: 12),
                          if (book.audioUrl != null)
                            Expanded(
                              child: _buildActionButton(
                                context,
                                icon: Icons.headphones,
                                label: 'کتاب صوتی',
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AudioPlayerScreen(book: book),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // توضیحات
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        'درباره کتاب',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: Text(
                        book.description,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 15,
                          height: 1.8,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(
        label,
        style: GoogleFonts.vazirmatn(),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}