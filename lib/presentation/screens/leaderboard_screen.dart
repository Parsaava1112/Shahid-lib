import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api_service.dart';
import '../widgets/avatar_widget.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _leaderboard = [];
  bool _loading = true;
  String _error = '';

  final List<String> _periods = ['weekly', 'monthly', 'all'];
  final List<String> _periodLabels = ['هفتگی', 'ماهانه', 'کل'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaderboard(_periods[0]);
  }

  Future<void> _loadLeaderboard(String period) async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final data = await ApiService.fetchLeaderboard(period: period);
      if (!mounted) return;
      setState(() {
        _leaderboard = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'خطا در دریافت اطلاعات: $e';
        _loading = false;
        _leaderboard = [];
      });
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جدول امتیازات',
          style: GoogleFonts.vazirmatn(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: _periodLabels
              .map((label) => Tab(
                    text: label,
                  ))
              .toList(),
          onTap: (index) {
            _loadLeaderboard(_periods[index]);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadLeaderboard(_periods[_tabController.index]);
            },
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error,
                style: GoogleFonts.vazirmatn(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _loadLeaderboard(_periods[_tabController.index]);
                },
                icon: const Icon(Icons.refresh),
                label: Text(
                  'تلاش دوباره',
                  style: GoogleFonts.vazirmatn(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_leaderboard.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 100,
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'هنوز امتیازی ثبت نشده',
                style: GoogleFonts.vazirmatn(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'با مطالعه کتاب، اولین نفر در جدول باشید!',
                style: GoogleFonts.vazirmatn(
                  fontSize: 14,
                  color:
                      theme.colorScheme.onBackground.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ).animate().fadeIn(duration: 500.ms),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          _loadLeaderboard(_periods[_tabController.index]),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _leaderboard.length + 1,
        itemBuilder: (context, index) {
          // هدر - سه نفر برتر
          if (index == 0 && _leaderboard.length >= 3) {
            return _buildTopThree(theme);
          }

          final actualIndex = index == 0 ? 0 : index - 1;
          if (actualIndex >= _leaderboard.length) {
            return const SizedBox.shrink();
          }

          // اگر سه نفر برتر جدا نمایش داده شدند، از رتبه ۴ شروع کن
          if (_leaderboard.length >= 3 && actualIndex < 3) {
            return const SizedBox.shrink();
          }

          final item = _leaderboard[actualIndex];
          return _buildLeaderboardItem(theme, item, actualIndex);
        },
      ),
    );
  }

  Widget _buildTopThree(ThemeData theme) {
    final top1 = _leaderboard[0];
    final top2 = _leaderboard.length > 1 ? _leaderboard[1] : null;
    final top3 = _leaderboard.length > 2 ? _leaderboard[2] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // نفر دوم
              if (top2 != null)
                _buildPodiumItem(
                  theme,
                  top2,
                  2,
                  height: 100,
                  color: const Color(0xFFC0C0C0),
                ),
              // نفر اول
              _buildPodiumItem(
                theme,
                top1,
                1,
                height: 130,
                color: const Color(0xFFFFD700),
              ),
              // نفر سوم
              if (top3 != null)
                _buildPodiumItem(
                  theme,
                  top3,
                  3,
                  height: 80,
                  color: const Color(0xFFCD7F32),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildPodiumItem(
    ThemeData theme,
    Map<String, dynamic> item,
    int rank, {
    required double height,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // مدال
        Icon(
          Icons.emoji_events,
          color: color,
          size: rank == 1 ? 32 : 24,
        ),
        const SizedBox(height: 4),
        // آواتار
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: AvatarWidget(
            seed: item['avatar_seed']?.toString() ?? '',
            size: rank == 1 ? 60 : 48,
          ),
        ),
        const SizedBox(height: 6),
        // نام
        SizedBox(
          width: 80,
          child: Text(
            item['name']?.toString() ?? 'ناشناس',
            style: GoogleFonts.vazirmatn(
              color: Colors.white,
              fontSize: rank == 1 ? 13 : 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // امتیاز
        Text(
          '${item['total_minutes'] ?? 0} د',
          style: GoogleFonts.vazirmatn(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 6),
        // سکو
        Container(
          width: rank == 1 ? 70 : 60,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: GoogleFonts.vazirmatn(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: (rank * 150).ms).scale();
  }

  Widget _buildLeaderboardItem(
    ThemeData theme,
    Map<String, dynamic> item,
    int index,
  ) {
    final rank = (item['rank'] as num?)?.toInt() ?? (index + 1);
    final name = item['name']?.toString() ?? 'ناشناس';
    final avatarSeed = item['avatar_seed']?.toString() ?? '';
    final minutes = (item['total_minutes'] as num?)?.toInt() ?? 0;
    final booksCount = (item['books_count'] as num?)?.toInt() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شماره رتبه
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: GoogleFonts.vazirmatn(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // آواتار
            AvatarWidget(
              seed: avatarSeed,
              size: 40,
            ),
          ],
        ),
        title: Text(
          name,
          style: GoogleFonts.vazirmatn(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                Icons.timer,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '$minutes دقیقه',
                style: GoogleFonts.vazirmatn(fontSize: 12),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.menu_book,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '$booksCount کتاب',
                style: GoogleFonts.vazirmatn(fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.arrow_back_ios,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (50 * (index + 3)).ms, duration: 400.ms)
        .slideX(begin: 0.15, end: 0);
  }
}