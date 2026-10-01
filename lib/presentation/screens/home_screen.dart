import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_controller.dart';
import '../../core/database/db_helper.dart';
import '../../data/models/book_model.dart';
import '../../data/models/user_model.dart';
import '../widgets/avatar_widget.dart';
import 'book_detail_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // داده‌ها
  List<BookModel> _books = [];
  List<BookModel> _filteredBooks = [];
  UserModel? _currentUser;
  String _aiMessage = '';

  // دسته‌بندی
  final List<String> _categories = [
    'همه',
    'کتاب',
    'کتاب صوتی',
    'پادکست تصویری',
  ];
  String _selectedCategory = 'همه';

  // Tab
  late TabController _tabController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // بارگذاری کتاب‌ها
      var books = await DBHelper.getAllBooks();
      if (books.isEmpty) {
        await _seedSampleData();
        books = await DBHelper.getAllBooks();
      }

      // بارگذاری کاربر جاری (اولین کاربر در دیتابیس)
      final users = await DBHelper.getAllUsers();
      UserModel? user = users.isNotEmpty ? users.first : null;

      // پیام انگیزشی محلی
      final message = _generateLocalMotivationalMessage(user);

      if (!mounted) return;
      setState(() {
        _books = books;
        _filteredBooks = books;
        _currentUser = user;
        _aiMessage = message;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  /// تولید پیام انگیزشی محلی (بدون نیاز به بک‌اند)
  String _generateLocalMotivationalMessage(UserModel? user) {
    final name = user?.name ?? 'کاربر عزیز';
    final messages = [
      '$name جان، امروز یه کتاب خوب بخون. حتی ۱۰ دقیقه کافیه.',
      'شهید سلیمانی می‌فرمود: «هرچه داریم از کتاب و مطالعه است.» $name جان.',
      '$name عزیز، کتاب بهترین دوستیه که هیچ‌وقت تنهات نمی‌ذاره.',
      'با هر صفحه‌ای که می‌خونی، یه پله بالاتر می‌ری $name جان.',
      '$name جان، دانش سلاح امروزه. با کتاب مسلح شو.',
    ];
    messages.shuffle();
    return messages.first;
  }

  /// داده‌های نمونه برای تست اولیه
  Future<void> _seedSampleData() async {
    final samples = [
      BookModel(
        title: 'خاطرات شهید سلیمانی',
        author: 'موسسه شهید',
        description:
            'مجموعه‌ای از خاطرات، زندگی‌نامه و درس‌های شهید حاج قاسم سلیمانی',
        coverUrl: '',
        fileUrl: 'https://example.com/book1.pdf',
        filePath: '',
        type: 'pdf',
        category: 'کتاب',
        rating: 4.8,
        ratingCount: 120,
      ),
      BookModel(
        title: 'کتاب صوتی مالک اشتر',
        author: 'راوی: علی محمدی',
        description: 'روایت زندگی مالک اشتر، یار باوفای امیرالمؤمنین',
        coverUrl: '',
        fileUrl: 'https://example.com/audio1.mp3',
        filePath: '',
        type: 'audio',
        category: 'کتاب صوتی',
        rating: 4.5,
        ratingCount: 85,
      ),
      BookModel(
        title: 'پادکست تصویری سردار دل‌ها',
        author: 'گروه رسانه',
        description: 'مستند تصویری از زندگی و مجاهدت شهید سلیمانی',
        coverUrl: '',
        fileUrl: 'https://example.com/video1.mp4',
        filePath: '',
        type: 'video',
        category: 'پادکست تصویری',
        rating: 4.9,
        ratingCount: 200,
      ),
      BookModel(
        title: 'از چیزی نمی‌ترسم',
        author: 'محمود فروتن',
        description: 'روایت‌های کمتر شنیده شده از شهید حاج قاسم سلیمانی',
        coverUrl: '',
        fileUrl: 'https://example.com/book2.pdf',
        filePath: '',
        type: 'pdf',
        category: 'کتاب',
        rating: 4.7,
        ratingCount: 95,
      ),
      BookModel(
        title: 'کتاب صوتی مکتب سلیمانی',
        author: 'راوی: حسن رضایی',
        description: 'بررسی ابعاد مختلف مکتب شهید سلیمانی',
        coverUrl: '',
        fileUrl: 'https://example.com/audio2.mp3',
        filePath: '',
        type: 'audio',
        category: 'کتاب صوتی',
        rating: 4.6,
        ratingCount: 60,
      ),
      BookModel(
        title: 'پادکست تصویری روایت فتح',
        author: 'گروه مستند',
        description: 'مجموعه مستندهای روایت فتح با روایت سردار سلیمانی',
        coverUrl: '',
        fileUrl: 'https://example.com/video2.mp4',
        filePath: '',
        type: 'video',
        category: 'پادکست تصویری',
        rating: 4.4,
        ratingCount: 45,
      ),
    ];
    for (final book in samples) {
      await DBHelper.insertBook(book);
    }
  }

  /// فیلتر کتاب‌ها
  void _filterBooks(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'همه') {
        _filteredBooks = _books;
      } else {
        final type = _getTypeFromCategory(category);
        _filteredBooks = _books.where((b) => b.type == type).toList();
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            tooltip: 'تنظیمات',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'پروفایل',
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
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
            final categories = ['کتاب', 'کتاب صوتی', 'پادکست تصویری'];
            _filterBooks(categories[index]);
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // پیام انگیزشی AI
                  SliverToBoxAdapter(
                    child: _buildAiMessageBanner(theme),
                  ),

                  // لیدربورد (کارت کوچک)
                  SliverToBoxAdapter(
                    child: _buildLeaderboardShortcut(theme),
                  ),

                  // دسته‌بندی‌ها
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              top: 8,
                              bottom: 8,
                            ),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (_) => _filterBooks(category),
                              selectedColor: theme.colorScheme.primary,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // لیست کتاب‌ها
                  _filteredBooks.isEmpty
                      ? SliverFillRemaining(
                          child: _buildEmptyState(theme),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final book = _filteredBooks[index];
                                return OpenContainer(
                                  transitionType:
                                      ContainerTransitionType.fadeThrough,
                                  transitionDuration:
                                      const Duration(milliseconds: 500),
                                  closedElevation: 0,
                                  closedColor: Colors.transparent,
                                  openColor: theme.colorScheme.background,
                                  middleColor: theme.colorScheme.background,
                                  openBuilder: (context, _) =>
                                      BookDetailScreen(book: book),
                                  closedBuilder:
                                      (context, openContainer) =>
                                          _AnimatedBookCard(
                                    book: book,
                                    index: index,
                                    onTap: openContainer,
                                  ),
                                );
                              },
                              childCount: _filteredBooks.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadData,
        icon: const Icon(Icons.refresh),
        label: const Text('بروزرسانی'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// بنر پیام انگیزشی AI
  Widget _buildAiMessageBanner(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'پیام امروز',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _aiMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.2, end: 0, curve: Curves.easeOut);
  }

  /// کارت میانبر لیدربورد
  Widget _buildLeaderboardShortcut(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                theme.colorScheme.secondary.withOpacity(0.2),
            child: Icon(
              Icons.emoji_events,
              color: theme.colorScheme.secondary,
            ),
          ),
          title: const Text(
            'جدول امتیازات',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('رتبه خود را در بین کتاب‌خوان‌ها ببینید'),
          trailing: const Icon(Icons.arrow_back_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LeaderboardScreen(),
              ),
            );
          },
        ),
      )
          .animate()
          .fadeIn(delay: 200.ms, duration: 500.ms)
          .slideX(begin: 0.1, end: 0),
    );
  }

  /// حالت خالی
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 100,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'کتابی یافت نشد',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'برای بروزرسانی دکمه پایین را بزنید',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.4),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}

/// کارت کتاب با Hero Animation
class _AnimatedBookCard extends StatelessWidget {
  final BookModel book;
  final int index;
  final VoidCallback onTap;

  const _AnimatedBookCard({
    required this.book,
    required this.index,
    required this.onTap,
  });

  IconData _getBookIcon() {
    switch (book.type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'audio':
        return Icons.headphones;
      case 'video':
        return Icons.videocam;
      default:
        return Icons.book;
    }
  }

  Color _getTypeColor(ThemeData theme) {
    switch (book.type) {
      case 'pdf':
        return theme.colorScheme.primary;
      case 'audio':
        return Colors.orange;
      case 'video':
        return Colors.redAccent;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getTypeLabel() {
    switch (book.type) {
      case 'pdf':
        return 'کتاب';
      case 'audio':
        return 'صوتی';
      case 'video':
        return 'تصویری';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _getTypeColor(theme);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // کاور کتاب با Hero
              Hero(
                tag: 'book_cover_${book.id}',
                child: Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        typeColor.withOpacity(0.2),
                        typeColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: typeColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          _getBookIcon(),
                          size: 40,
                          color: typeColor,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getTypeLabel(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${book.ratingCount})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                        const Spacer(),
                        if (book.isDownloaded)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.download_done,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // فلش
              Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: (80 * index).ms,
          duration: 400.ms,
        )
        .slideX(
          begin: 0.15,
          end: 0,
          curve: Curves.easeOut,
          delay: (80 * index).ms,
        );
  }
}