import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/dicebear_avatar.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Map<String, dynamic>> _data = [];
  bool _loading = true;
  String _error = '';
  int? _currentUserId;

  final List<String> _periods = ['weekly', 'monthly', 'all'];
  final List<String> _periodLabels = ['هفتگی', 'ماهانه', 'کل'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        _load(_periods[_tab.index]);
      }
    });
    _initLoad();
  }

  Future<void> _initLoad() async {
    final user = await ApiService.getCurrentUser();
    _currentUserId = user?.id;
    await _load('weekly');
  }

  Future<void> _load(String period) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final data = await ApiService.fetchLeaderboard(period: period);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'خطا در دریافت اطلاعات: $e';
        _loading = false;
      });
    }
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
          'جدول امتیازات',
          style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor:
              theme.colorScheme.onSurface.withOpacity(0.5),
          labelStyle: GoogleFonts.vazirmatn(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: _periodLabels.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: AnimatedBackground(
        blobCount: 4,
        intensity: 0.7,
        child: _buildBody(theme),
      ),
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
              Icon(Icons.error_outline,
                  size: 80, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _load(_periods[_tab.index]),
                icon: const Icon(Icons.refresh_rounded),
                label: Text('تلاش دوباره',
                    style: GoogleFonts.vazirmatn()),
              ),
            ],
          ),
        ),
      );
    }

    if (_data.isEmpty) {
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
              const SizedBox(height: 20),
              Text(
                'هنوز امتیازی ثبت نشده',
                style: GoogleFonts.vazirmatn(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'با مطالعه کتاب، اولین نفر در جدول باشید!',
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms),
        ),
      );
    }

    // پیدا کردن جایگاه کاربر جاری
    int? myRank;
    if (_currentUserId != null) {
      for (final item in _data) {
        if (item['user_id'] == _currentUserId) {
          myRank = (item['rank'] as num?)?.toInt();
          break;
        }
      }
    }

    return RefreshIndicator(
      onRefresh: () => _load(_periods[_tab.index]),
      color: theme.colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // ============ کارت جایگاه کاربر جاری ============
          if (myRank != null)
            SliverToBoxAdapter(
              child: _buildMyRankCard(theme, myRank),
            ),

          // ============ Podium سه نفر اول ============
          if (_data.length >= 3)
            SliverToBoxAdapter(
              child: _buildPodium(theme),
            ),

          // ============ عنوان لیست ============
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.people_alt_rounded,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'سایر شرکت‌کننده‌ها',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_data.length} نفر',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ============ لیست کاربران ============
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            sliver: SliverList.builder(
              itemCount: _data.length,
              itemBuilder: (context, i) {
                // اگر سه نفر اول در Podium نمایش داده شده‌اند، از رتبه ۴ شروع کن
                if (_data.length >= 3 && i < 3) {
                  return const SizedBox.shrink();
                }
                return _buildUserCard(theme, _data[i], i);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== کارت جایگاه کاربر جاری ====================

  Widget _buildMyRankCard(ThemeData theme, int rank) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'جایگاه شما',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'رتبه $rank از ${_data.length} نفر',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.emoji_events_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 36,
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
    );
  }

  // ==================== Podium سه نفر اول ====================

  Widget _buildPodium(ThemeData theme) {
    final first = _data[0];
    final second = _data.length > 1 ? _data[1] : null;
    final third = _data.length > 2 ? _data[2] : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.08),
            theme.colorScheme.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: theme.colorScheme.secondary, size: 22),
              const SizedBox(width: 6),
              Text(
                'سه نفر برتر',
                style: GoogleFonts.vazirmatn(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (second != null)
                _buildPodiumItem(
                  theme,
                  second,
                  2,
                  height: 90,
                  color: const Color(0xFFC0C0C0),
                  delay: 150,
                ),
              _buildPodiumItem(
                theme,
                first,
                1,
                height: 125,
                color: const Color(0xFFFFD700),
                delay: 0,
              ),
              if (third != null)
                _buildPodiumItem(
                  theme,
                  third,
                  3,
                  height: 75,
                  color: const Color(0xFFCD7F32),
                  delay: 300,
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildPodiumItem(
    ThemeData theme,
    Map<String, dynamic> item,
    int rank, {
    required double height,
    required Color color,
    required int delay,
  }) {
    final name = item['name']?.toString() ?? 'ناشناس';
    final minutes = (item['total_minutes'] as num?)?.toInt() ?? 0;
    final isMe = item['user_id'] == _currentUserId;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // مدال
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.emoji_events_rounded,
            color: color,
            size: rank == 1 ? 28 : 22,
          ),
        ),
        const SizedBox(height: 8),

        // آواتار
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isMe ? theme.colorScheme.primary : color,
              width: isMe ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: DiceBearAvatar(
            seed: item['avatar_seed']?.toString() ?? '',
            style: item['avatar_style']?.toString() ?? 'adventurer',
            size: rank == 1 ? 70 : 58,
            withBorder: false,
          ),
        ),
        const SizedBox(height: 8),

        // نام
        SizedBox(
          width: 90,
          child: Column(
            children: [
              Text(
                isMe ? 'شما' : name,
                style: GoogleFonts.vazirmatn(
                  fontSize: rank == 1 ? 13 : 12,
                  fontWeight: FontWeight.bold,
                  color: isMe
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _readableMinutes(minutes),
                style: GoogleFonts.vazirmatn(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // سکو
        Container(
          width: rank == 1 ? 85 : 72,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.6),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$rank',
              style: GoogleFonts.vazirmatn(
                color: Colors.white,
                fontSize: rank == 1 ? 34 : 26,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 500.ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic);
  }

  // ==================== کارت کاربر عادی ====================

  Widget _buildUserCard(
    ThemeData theme,
    Map<String, dynamic> item,
    int index,
  ) {
    final rank = (item['rank'] as num?)?.toInt() ?? (index + 1);
    final name = item['name']?.toString() ?? 'ناشناس';
    final minutes = (item['total_minutes'] as num?)?.toInt() ?? 0;
    final books = (item['books_count'] as num?)?.toInt() ?? 0;
    final level = (item['level'] as num?)?.toInt() ?? 1;
    final isMe = item['user_id'] == _currentUserId;
    final badges = (item['badges'] as List?) ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isMe
                ? theme.colorScheme.primary.withOpacity(0.5)
                : theme.colorScheme.primary.withOpacity(0.1),
            width: isMe ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // رتبه
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isMe
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isMe
                        ? Colors.white
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // آواتار
            DiceBearAvatar(
              seed: item['avatar_seed']?.toString() ?? '',
              style: item['avatar_style']?.toString() ?? 'adventurer',
              size: 46,
              withBorder: false,
            ),
            const SizedBox(width: 12),

            // اطلاعات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isMe ? 'شما' : name,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isMe
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // سطح
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'سطح $level',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.timer_rounded,
                          size: 13,
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.5)),
                      const SizedBox(width: 3),
                      Text(
                        _readableMinutes(minutes),
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.menu_book_rounded,
                          size: 13,
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.5)),
                      const SizedBox(width: 3),
                      Text(
                        '$books کتاب',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  if (badges.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: badges.take(3).map<Widget>((badge) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                badge['icon']?.toString() ?? '🏅',
                                style: const TextStyle(fontSize: 11),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                badge['name']?.toString() ?? '',
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 9,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (40 * index).ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }

  // ==================== توابع کمکی ====================

  String _readableMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes دقیقه';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours ساعت';
    }
    return '$hours ساعت و $mins دقیقه';
  }
}