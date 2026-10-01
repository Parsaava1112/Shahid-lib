import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_controller.dart';
import '../../data/models/book_model.dart';
import '../../core/database/db_helper.dart';
import '../widgets/avatar_widget.dart';
import 'book_detail_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<BookModel> _books = [];
  List<BookModel> _filteredBooks = [];
  String _selectedCategory = 'همه';
  final _categories = ['همه', 'کتاب', 'کتاب صوتی', 'پادکست تصویری'];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await DBHelper.getAllBooks();
    if (books.isEmpty) {
      // داده‌های نمونه برای تست
      await _seedSampleData();
      _books = await DBHelper.getAllBooks();
    } else {
      _books = books;
    }
    setState(() {
      _filteredBooks = _books;
    });
  }

  Future<void> _seedSampleData() async {
    final samples = [
      BookModel(
        title: 'خاطرات شهید سلیمانی',
        author: 'موسسه شهید',
        description: 'مجموعه‌ای از خاطرات و زندگی‌نامه شهید حاج قاسم سلیمانی',
        coverUrl: 'https://example.com/cover1.jpg',
        fileUrl: 'https://example.com/book1.pdf',
        filePath: '',
        type: 'pdf',
        category: 'کتاب',
      ),
      BookModel(
        title: 'کتاب صوتی مالک اشتر',
        author: 'راوی: علی محمدی',
        description: 'کتاب صوتی درباره زندگی مالک اشتر',
        coverUrl: 'https://example.com/cover2.jpg',
        fileUrl: 'https://example.com/audio1.mp3',
        filePath: '',
        type: 'audio',
        category: 'کتاب صوتی',
      ),
      BookModel(
        title: 'پادکست تصویری سردار دل‌ها',
        author: 'گروه رسانه',
        description: 'مستند تصویری از زندگی شهید سلیمانی',
        coverUrl: 'https://example.com/cover3.jpg',
        fileUrl: 'https://example.com/video1.mp4',
        filePath: '',
        type: 'video',
        category: 'پادکست تصویری',
      ),
    ];
    for (final book in samples) {
      await DBHelper.insertBook(book);
    }
  }

  void _filterBooks(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'همه') {
        _filteredBooks = _books;
      } else {
        _filteredBooks = _books.where((b) => b.type == _getTypeFromCategory(category)).toList();
      }
    });
  }

  String _getTypeFromCategory(String category) {
    switch (category) {
      case 'کتاب':
        return 'pdf';
      case 'کتاب صوتی':
        return 'audio';
      case 'پادکست تصویری':
        return 'video';
      default:
        return 'pdf';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('کتابخانه شهید سلیمانی'),
        actions: [
          IconButton(
            icon: Icon(themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeController.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'کتاب‌ها'),
            Tab(text: 'صوتی'),
            Tab(text: 'تصویری'),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                _filterBooks('کتاب');
                break;
              case 1:
                _filterBooks('کتاب صوتی');
                break;
              case 2:
                _filterBooks('پادکست تصویری');
                break;
            }
          },
        ),
      ),
      body: Column(
        children: [
          // دسته‌بندی‌ها
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _filterBooks(category),
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                );
              },
            ),
          ),
          // لیست کتاب‌ها
          Expanded(
            child: _filteredBooks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 80, color: theme.colorScheme.primary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text('کتابی یافت نشد'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = _filteredBooks[index];
                      return _AnimatedBookCard(
                        book: book,
                        index: index,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailScreen(book: book),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBookCard extends StatelessWidget {
  final BookModel book;
  final int index;
  final VoidCallback onTap;

  const _AnimatedBookCard({
    required this.book,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // کاور کتاب
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(
                  book.type == 'pdf'
                      ? Icons.picture_as_pdf
                      : book.type == 'audio'
                          ? Icons.headphones
                          : Icons.videocam,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              // اطلاعات کتاب
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
                    Text(
                      book.author,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${book.rating.toStringAsFixed(1)} (${book.ratingCount})',
                          style: theme.textTheme.bodySmall,
                        ),
                        const Spacer(),
                        if (book.isDownloaded)
                          Icon(
                            Icons.download_done,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (100 * index).ms, duration: 400.ms)
        .slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}