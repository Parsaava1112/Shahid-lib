import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/achievement_service.dart';
import '../../core/widgets/animated_background.dart';
import '../../data/models/achievement_model.dart';
import '../../services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await AchievementService.initialize();
    final user = await ApiService.getCurrentUser();
    if (user?.id != null) {
      await AchievementService.checkAndUnlock(user!.id!);
      _stats = await DBHelper.getUserStats(user.id!);
    }
    final list = await DBHelper.getAchievements();
    list.sort((a, b) {
      if (a.isUnlocked != b.isUnlocked) return a.isUnlocked ? -1 : 1;
      return a.tier.index.compareTo(b.tier.index);
    });
    if (!mounted) return;
    setState(() {
      _all = list;
      _loading = false;
    });
  }

  List<AchievementModel> get _filtered {
    if (_tab.index == 0) return _all;
    final tiers = [
      AchievementTier.bronze,
      AchievementTier.silver,
      AchievementTier.gold,
      AchievementTier.platinum,
      AchievementTier.legendary,
    ];
    return _all.where((a) => a.tier == tiers[_tab.index - 1]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final xp = _stats['total_xp'] as int? ?? 0;
    final level = _stats['level'] as int? ?? 1;
    final xpInLevel = AchievementService.xpInCurrentLevel(xp);
    final xpNeeded = AchievementService.xpForNextLevel(level);

    return AnimatedBackground(
      blobCount: 4,
      intensity: 0.5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildHeader(scheme, xp, level, xpInLevel, xpNeeded),
                    _buildTabs(scheme),
                    Expanded(
                      child: _filtered.isEmpty
                          ? _buildEmpty(scheme)
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 16, 16, 120),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.82,
                              ),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _AchievementCard(
                                achievement: _filtered[i],
                                index: i,
                              ),
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme scheme, int xp, int level, int inLevel,
      int needed) {
    final progress = needed == 0 ? 0.0 : (inLevel / needed).clamp(0, 1);
    final unlockedCount = _all.where((a) => a.isUnlocked).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.secondary, scheme.primary],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'سطح\n$level',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دستاوردهای شما',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$unlockedCount از ${_all.length} دستاورد باز شده',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        color: scheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.bolt, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  '$xp XP',
                  style: GoogleFonts.vazirmatn(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor:
                          scheme.primary.withOpacity(0.1),
                      valueColor:
                          AlwaysStoppedAnimation(scheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$inLevel/$needed',
                  style: GoogleFonts.vazirmatn(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(ColorScheme scheme) {
    return TabBar(
      controller: _tab,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      dividerColor: Colors.transparent,
      indicatorColor: scheme.primary,
      indicatorWeight: 3,
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurface.withOpacity(0.5),
      labelStyle: GoogleFonts.vazirmatn(
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      onTap: (_) => setState(() {}),
      tabs: const [
        Tab(text: 'همه'),
        Tab(text: 'برنز'),
        Tab(text: 'نقره'),
        Tab(text: 'طلایی'),
        Tab(text: 'پلاتینیوم'),
        Tab(text: 'افسانه‌ای'),
      ],
    );
  }

  Widget _buildEmpty(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined,
              size: 100, color: scheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'در این دسته دستاوردی نیست',
            style: GoogleFonts.vazirmatn(
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final int index;

  const _AchievementCard({
    required this.achievement,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tierColor = AchievementService.colorForTier(achievement.tier);
    final unlocked = achievement.isUnlocked;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + index * 50),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0, end: 1),
      builder: (context, v, child) => Transform.scale(
        scale: 0.85 + 0.15 * v,
        child: Opacity(opacity: v.clamp(0, 1), child: child),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: unlocked
                ? tierColor.withOpacity(0.5)
                : scheme.onSurface.withOpacity(0.08),
            width: unlocked ? 2 : 1,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: tierColor.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: unlocked
                    ? LinearGradient(
                        colors: [
                          tierColor.withOpacity(0.3),
                          tierColor.withOpacity(0.1),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          scheme.onSurface.withOpacity(0.1),
                          scheme.onSurface.withOpacity(0.05),
                        ],
                      ),
                border: Border.all(
                  color: unlocked ? tierColor : scheme.onSurface.withOpacity(0.15),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 30,
                    color: unlocked ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: unlocked
                    ? scheme.onSurface
                    : scheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.vazirmatn(
                fontSize: 10,
                color: scheme.onSurface.withOpacity(0.5),
              ),
            ),
            const Spacer(),
            if (!unlocked) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: achievement.progressPercent,
                  minHeight: 6,
                  backgroundColor: scheme.onSurface.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation(tierColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${achievement.progress}/${achievement.requirementValue}',
                style: GoogleFonts.vazirmatn(
                  fontSize: 10,
                  color: scheme.onSurface.withOpacity(0.5),
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: tierColor),
                    const SizedBox(width: 4),
                    Text(
                      '+${achievement.xpReward} XP',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: tierColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}