import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/database/db_helper.dart';
import '../../core/services/achievement_service.dart';
import '../../data/models/achievement_model.dart';
import '../../services/api_service.dart';
import '../widgets/animated_background.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<AchievementModel> _all = [];
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  static const _tiers = [
    AchievementTier.bronze,
    AchievementTier.silver,
    AchievementTier.gold,
    AchievementTier.legendary,
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tiers.length, vsync: this);
    _tab.addListener(() => setState(() {}));
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await AchievementService.initialize();
    final user = await ApiService.getCurrentUser();

    if (user?.id != null) {
      await AchievementService.checkAndUnlock(user!.id!);
      final stats = await DBHelper.getUserStats(user.id!);
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _all = AchievementService.allAchievements;
        _loading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _all = AchievementService.allAchievements;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<AchievementModel> _forTier(AchievementTier tier) {
    return _all.where((AchievementModel a) => a.tier == tier).toList();
  }

  int get _xp => (_stats['xp'] as num?)?.toInt() ?? 0;
  int get _level => AchievementService.levelForXp(_xp);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'دستاوردها',
          style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          tabs: _tiers
              .map((t) => Tab(text: AchievementService.labelForTier(t)))
              .toList(),
        ),
      ),
      body: AnimatedBackground(
        blobCount: 4,
        intensity: 0.7,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(theme),
                  Expanded(
                    child: TabBarView(
                      controller: _tab,
                      children:
                          _tiers.map((t) => _buildTierList(theme, t)).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final unlockedCount =
        _all.where((AchievementModel a) => a.isUnlocked).length;
    final total = _all.length;
    final progress = total > 0 ? unlockedCount / total : 0.0;

    final xpInLevel =
        AchievementService.xpInCurrentLevel(_xp).toDouble();
    final xpNeeded =
        AchievementService.xpForLevel(_level).toDouble();
    final levelProgress = xpNeeded > 0
        ? (xpInLevel / xpNeeded).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
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
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سطح $_level',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$_xp XP',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '$unlockedCount / $total',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: levelProgress.toDouble(),
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'پیشرفت به سطح بعدی',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.toDouble(),
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(
                      Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildTierList(ThemeData theme, AchievementTier tier) {
    final list = _forTier(tier);
    if (list.isEmpty) {
      return Center(
        child: Text(
          'دستاوردی در این سطح وجود ندارد',
          style: GoogleFonts.vazirmatn(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _buildAchievementCard(theme, list[i], i),
    );
  }

  Widget _buildAchievementCard(
    ThemeData theme,
    AchievementModel a,
    int index,
  ) {
    final color = AchievementService.colorForTier(a.tier);
    final unlocked = a.isUnlocked;

    // محاسبه پیشرفت
    double progress = 0;
    int current = 0;
    if (unlocked) {
      progress = 1.0;
      current = a.target;
    } else {
      switch (a.type) {
        case 'books':
          current = (_stats['total_books_read'] as num?)?.toInt() ?? 0;
          break;
        case 'minutes':
          current = (_stats['total_minutes_read'] as num?)?.toInt() ?? 0;
          break;
        case 'streak':
          current = (_stats['current_streak'] as num?)?.toInt() ?? 0;
          break;
        case 'rating':
          current = (_stats['total_ratings'] as num?)?.toInt() ?? 0;
          break;
      }
      progress = a.target > 0 ? (current / a.target).clamp(0.0, 1.0) : 0.0;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked
              ? color.withOpacity(0.5)
              : theme.colorScheme.onSurface.withOpacity(0.08),
          width: unlocked ? 2 : 1,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // آیکون
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: unlocked
                    ? [color.withOpacity(0.3), color.withOpacity(0.1)]
                    : [
                        theme.colorScheme.onSurface.withOpacity(0.05),
                        theme.colorScheme.onSurface.withOpacity(0.02),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: unlocked
                    ? color.withOpacity(0.5)
                    : theme.colorScheme.onSurface.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                a.icon,
                style: TextStyle(
                  fontSize: 32,
                  color: unlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // اطلاعات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        a.title,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: unlocked
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                        ),
                      ),
                    ),
                    if (unlocked)
                      Icon(Icons.verified_rounded, color: color, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  a.description,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
                if (!unlocked && a.type != 'special') ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.toDouble(),
                            minHeight: 6,
                            backgroundColor:
                                theme.colorScheme.onSurface.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$current / ${a.target}',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (50 * index).ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}