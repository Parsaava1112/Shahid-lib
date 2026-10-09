import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/book_model.dart';
import '../../services/api_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/book_cover.dart';
import 'book_detail_screen.dart';

class EnglishBooksScreen extends StatefulWidget {
  const EnglishBooksScreen({super.key});

  @override
  State<EnglishBooksScreen> createState() => _EnglishBooksScreenState();
}

class _EnglishBooksScreenState extends State<EnglishBooksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<BookModel> _allBooks = [];
  List<BookModel> _filteredBooks = [];
  List<Map<String, dynamic>> _levels = [];
  String _selectedLevel = 'all';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 1, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final levels = await ApiService.fetchEnglishLevels();
      final books = await ApiService.fetchEnglishBooks();

      if (!mounted) return;
      setState(() {
        _levels = levels;
        _allBooks = books;
        _filteredBooks = books;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filterByLevel(String levelKey) {
    setState(() {
      _selectedLevel = levelKey;
      if (levelKey == 'all') {
        _filteredBooks = _allBooks;
      } else {
        _filteredBooks =
            _allBooks.where((b) => b.level == levelKey).toList();
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'کتاب‌های انگلیسی',
          style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: AnimatedBackground(
        blobCount: 4,
        intensity: 0.6,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                color: theme.colorScheme.primary,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(theme)),
                    SliverToBoxAdapter(child: _buildLevelFilter(theme)),
                    if (_filteredBooks.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmpty(theme),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.6,
                          ),
                          itemCount: _filteredBooks.length,
                          itemBuilder: (context, i) {
                            return _buildBookCard(theme, _filteredBooks[i], i);
                          },
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 60)),
                  ],
                ),
              ),
      ),
    );
  }

  // ==================== Header ====================

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.language_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'کتاب‌های انگلیسی',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_allBooks.length} کتاب در سطوح مختلف',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
    );
  }

  // ==================== Level Filter ====================

  Widget _buildLevelFilter(ThemeData theme) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _levels.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            // دکمه "همه"
            final active = _selectedLevel == 'all';
            return Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
              child: _buildLevelChip(
                theme,
                label: 'همه',
                count: _allBooks.length,
                active: active,
                color: theme.colorScheme.primary,
                onTap: () => _filterByLevel('all'),
              ),
            );
          }

          final level = _levels[i - 1];
          final key = level['key'] as String;
          final label = level['label'] as String;
          final count = (level['count'] as num?)?.toInt() ?? 0;
          final active = _selectedLevel == key;
          final color = _levelColor(key);

          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
            child: _buildLevelChip(
              theme,
              label: label,
              count: count,
              active: active,
              color: color,
              onTap: () => _filterByLevel(key),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelChip(
    ThemeData theme, {
    required String label,
    required int count,
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? color : color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withOpacity(0.3)
                    : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.vazirmatn(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Book Card ====================

  Widget _buildBookCard(ThemeData theme, BookModel book, int index) {
    final levelColor = Color(book.levelColorValue);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailScreen(book: book),
          ),
        );
        _load();
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: levelColor.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: levelColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // کاور
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: BookCover(
                        book: book,
                        width: 110,
                        height: 150,
                        radius: 12,
                        baseUrl: ApiService.fileBaseUrl,
                      ),
                    ),
                  ),
                  // بج سطح
                  if (book.level != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: levelColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: levelColor.withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          book.levelLabelFa,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // اطلاعات کتاب
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: theme.colorScheme.secondary, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        book.rating.toStringAsFixed(1),
                        style: GoogleFonts.vazirmatn(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (book.isDownloaded)
                        Icon(
                          Icons.download_done_rounded,
                          size: 14,
                          color: Colors.green.shade600,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (50 * index).ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  // ==================== Empty State ====================

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.translate_rounded,
              size: 90,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'کتابی در این سطح یافت نشد',
              style: GoogleFonts.vazirmatn(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سطح دیگری را امتحان کنید',
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Helpers ====================

  Color _levelColor(String level) {
    switch (level) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'elementary':
        return const Color(0xFF8BC34A);
      case 'intermediate':
        return const Color(0xFFFF9800);
      case 'upper':
        return const Color(0xFFFF5722);
      case 'advanced':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}