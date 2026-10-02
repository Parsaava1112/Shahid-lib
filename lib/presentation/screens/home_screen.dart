import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/achievement_service.dart';
import '../../core/widgets/animated_background.dart';
import '../../data/models/book_model.dart';
import '../../data/models/user_model.dart';
import '../../services/api_service.dart';
import '../widgets/dicebear_avatar.dart';
import 'book_detail_screen.dart';
import 'pdf_reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BookModel> _books = [];
  List<BookModel> _filtered = [];
  UserModel? _user;
  Map<String, dynamic> _stats = {};
  bool _loading = true;
  String _category = 'همه';
  final _categories = ['همه', 'کتاب', 'کتاب صوتی', 'پادکست تصویری'];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await AchievementService.initialize();

    var books = await DBHelper.getAllBooks();
    if (books.isEmpty) {
      await _seed();
      books = await DBHelper.getAllBooks();
    }

    final user = await ApiService.getCurrentUser();
    Map<String, dynamic> stats = {};
    if (user?.id != null) {
      stats = await DBHelper.getUserStats(user!.id!);
    }

    if (!mounted) return;
    setState(() {
      _books = books;
      _filtered = books;
      _user = user;
      _stats = stats;
      _loading = false;
    });
  }

  Future<void> _seed() async {
    final samples = [
      BookModel(
        title: 'خاطرات شهید سلیمانی',
        author: 'موسسه شهید',
        description:
            'مجموعه‌ای از خاطرات، زندگی‌نامه و درس‌های شهید حاج قاسم سلیمانی',
        coverUrl: '',
        fileUrl: 'https://www.africau.edu/images/default/sample.pdf',
        filePath: '',
        type: 'pdf',
        category: 'کتاب',
        rating: 4.8,
        ratingCount: 120,
      ),
      BookModel(
        title: 'مالک اشتر',
        author: 'راوی: علی محمدی',
        description: 'روایت زندگی مالک اشتر، یار باوفای امیرالمؤمنین',
        coverUrl: '',
        fileUrl: 'https://www.africau.edu/images/default/sample.pdf',
        filePath: '',
        type: 'pdf',
        category: 'کتاب',
        rating: 4.5,
        ratingCount: 85,
      ),
      BookModel(
        title: 'از چیزی نمی‌ترسم',
        author: 'محمود فروتن',
        description: 'روایت‌های کمتر شنیده شده از شهید سلیمانی',
        coverUrl: '',
        fileUrl: 'https://www.africau.edu/images/default/sample.pdf',
        filePath: '',
        type: 'pdf',
        category: 'کتاب',
        rating: 4.7,
        ratingCount: 95,
      ),
    ];
    for (final b in samples) {
      await DBHelper.insertBook(b);
    }
  }

  void _filter(String cat) {
    setState(() {
      _category = cat;
      final q = _searchCtrl.text.trim().toLowerCase();
      _filtered = _books.where((b) {
        final matchCat = cat == 'همه' ||
            (cat == 'کتاب' && b.type == 'pdf') ||
            (cat == 'کتاب صوتی' && b.type == 'audio') ||
            (cat == 'پادکست تصویری' && b.type == 'video');
        final matchQ = q.isEmpty ||
            b.title.toLowerCase().contains(q) ||
            b.author.toLowerCase().contains(q);
        return matchCat && matchQ;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBackground(
      blobCount: 5,
      intensity: 0.6,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(scheme)),
                    SliverToBoxAdapter(child: _buildStatsRow(scheme)),
                    SliverToBoxAdapter(child: _buildSearch(scheme)),
                    SliverToBoxAdapter(child: _buildCategories(scheme)),
                    SliverToBoxAdapter(child: _buildSectionTitle(scheme)),
                    _filtered.isEmpty
                        ? SliverFillRemaining(child: _buildEmpty(scheme))
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.62,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => _BookCard(
                                  book: _filtered[i],
                                  index: i,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookDetailScreen(
                                        book: _filtered[i],
                                      ),
                                    ),
                                  ),
                                  onRead: () => _openBook(_filtered[i]),
                                ),
                                childCount: _filtered.length,
                              ),
                            ),
                          ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme scheme) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'صبح بخیر'
        : hour < 18
            ? 'ظهر بخیر'
            : 'شب بخیر';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14,
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.name ?? 'کاربر عزیز',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (_user != null)
            DiceBearAvatar(
              seed: _user!.avatarSeed ?? _user!.nationalCode,
              style: _user!.avatarStyle ?? 'adventurer',
              size: 54,
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ColorScheme scheme) {
    final xp = _stats['total_xp'] as int? ?? 0;
    final level = _stats['level'] as int? ?? 1;
    final streak = _stats['current_streak'] as int? ?? 0;
    final minutes = _stats['total_minutes'] as int? ?? 0;
    final xpInLevel = AchievementService.xpInCurrentLevel(xp);
    final xpNeeded = AchievementService.xpForNextLevel(level);
    final progress = xpNeeded == 0 ? 0.0 : (xpInLevel / xpNeeded).clamp(0, 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary,
              scheme.primary.withOpacity(0.75),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _statChip('سطح $level', Icons.military_tech, Colors.white),
                const SizedBox(width: 8),
                _statChip('$xp XP', Icons.bolt, Colors.amber),
                const Spacer(),
                _statChip('$streak روز', Icons.local_fire_department,
                    Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress.toDouble(),
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$xpInLevel/$xpNeeded',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$minutes دقیقه مطالعه',
              style: GoogleFonts.vazirmatn(
                fontSize: 12,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => _filter(_category),
        decoration: InputDecoration(
          hintText: 'جستجو در کتاب‌ها...',
          prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchCtrl.clear();
                    _filter(_category);
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCategories(ColorScheme scheme) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = _categories[i];
          final active = c == _category;
          return GestureDetector(
            onTap: () => _filter(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: active
                    ? scheme.primary
                    : scheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(30),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: scheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                c,
                style: GoogleFonts.vazirmatn(
                  color: active ? scheme.onPrimary : scheme.primary,
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'کتاب‌های موجود',
            style: GoogleFonts.vazirmatn(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            '${_filtered.length} کتاب',
            style: GoogleFonts.vazirmatn(
              fontSize: 13,
              color: scheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined,
              size: 100, color: scheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'کتابی پیدا نشد',
            style: GoogleFonts.vazirmatn(
              fontSize: 16,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _openBook(BookModel book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfReaderScreen(book: book)),
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookModel book;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRead;

  const _BookCard({
    required this.book,
    required this.index,
    required this.onTap,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + index * 60),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, v, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - v)),
          child: Opacity(opacity: v, child: child),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: scheme.surface,
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary.withOpacity(0.85),
                          scheme.primary.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            book.type == 'pdf'
                                ? Icons.picture_as_pdf_rounded
                                : book.type == 'audio'
                                    ? Icons.headphones_rounded
                                    : Icons.videocam_rounded,
                            size: 60,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 12, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  book.rating.toStringAsFixed(1),
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
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
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 11,
                        color: scheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onRead,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: scheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                size: 16, color: scheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'مطالعه',
                              style: GoogleFonts.vazirmatn(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}