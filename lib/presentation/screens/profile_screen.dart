import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/database/db_helper.dart';
import '../../core/services/achievement_service.dart';
import '../../core/theme/theme_controller.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/user_model.dart';
import '../../services/api_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/dicebear_avatar.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await ApiService.getCurrentUser();
    Map<String, dynamic> stats = {
      'total_books_read': 0,
      'total_minutes_read': 0,
      'current_streak': 0,
      'xp': 0,
    };
    if (user?.id != null) {
      stats = await DBHelper.getUserStats(user!.id!);
    }
    if (!mounted) return;
    setState(() {
      _user = user;
      _stats = stats;
      _loading = false;
    });
  }

  int get _xp => (_stats['xp'] as num?)?.toInt() ?? 0;
  int get _level => AchievementService.levelForXp(_xp);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('پروفایل من',
            style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(controller.isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: () => controller.toggle(),
          ),
        ],
      ),
      body: AnimatedBackground(
        blobCount: 4,
        intensity: 0.7,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                color: theme.colorScheme.primary,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildAvatarHeader(theme),
                    const SizedBox(height: 24),
                    _buildLevelCard(theme),
                    const SizedBox(height: 16),
                    _buildStatsGrid(theme),
                    const SizedBox(height: 24),
                    _buildBadgesSection(theme),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  // ==================== Avatar Header ====================

  Widget _buildAvatarHeader(ThemeData theme) {
    return Column(
      children: [
        DiceBearAvatar(
          seed: _user?.avatarSeed ?? _user?.nationalCode ?? 'shahid',
          style: _user?.avatarStyle ?? 'adventurer',
          size: 130,
          onTap: _showAvatarPicker,
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        Text(
          _user?.name ?? 'کاربر',
          style: GoogleFonts.vazirmatn(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 4),
        Text(
          'کد ملی: ${_user?.nationalCode ?? '---'}',
          style: GoogleFonts.vazirmatn(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  // ==================== Level Card ====================

  Widget _buildLevelCard(ThemeData theme) {
    final xpInLevel =
        AchievementService.xpInCurrentLevel(_xp).toDouble();
    final xpNeeded =
        AchievementService.xpForLevel(_level).toDouble();
    final progress = xpNeeded > 0
        ? (xpInLevel / xpNeeded).clamp(0.0, 1.0)
        : 0.0;

    return Container(
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
                  color: Colors.white, size: 32),
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
                      '$_xp XP کل',
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
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${xpInLevel.toInt()} / ${xpNeeded.toInt()} XP تا سطح ${_level + 1}',
              style: GoogleFonts.vazirmatn(
                fontSize: 11,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.15, end: 0);
  }

  // ==================== Stats Grid ====================

  Widget _buildStatsGrid(ThemeData theme) {
    final books = (_stats['total_books_read'] as num?)?.toInt() ?? 0;
    final minutes = (_stats['total_minutes_read'] as num?)?.toInt() ?? 0;
    final streak = (_stats['current_streak'] as num?)?.toInt() ?? 0;
    final ratings = (_stats['total_ratings'] as num?)?.toInt() ?? 0;

    return Column(
      children: [
        Row(
          children: [
            _statCard(
              theme,
              Icons.menu_book_rounded,
              'کتاب‌های خوانده',
              '$books',
              theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            _statCard(
              theme,
              Icons.timer_rounded,
              'دقیقه مطالعه',
              '$minutes',
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard(
              theme,
              Icons.local_fire_department_rounded,
              'استریک روزانه',
              '$streak',
              Colors.redAccent,
            ),
            const SizedBox(width: 12),
            _statCard(
              theme,
              Icons.star_rounded,
              'امتیازها',
              '$ratings',
              Colors.amber,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _statCard(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.vazirmatn(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Badges ====================

  Widget _buildBadgesSection(ThemeData theme) {
    final unlocked =
        AchievementService.allAchievements.where((a) => a.isUnlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.workspace_premium_rounded,
                color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'نشان‌های شما',
              style: GoogleFonts.vazirmatn(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${unlocked.length} / ${AchievementService.allAchievements.length}',
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (unlocked.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.15),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 50,
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'هنوز نشانی کسب نکرده‌اید',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'با مطالعه کتاب، نشان‌های خود را باز کنید!',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: unlocked.map((a) => _badgeChip(theme, a)).toList(),
          ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _badgeChip(ThemeData theme, AchievementModel a) {
    final color = AchievementService.colorForTier(a.tier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(a.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                a.title,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                AchievementService.labelForTier(a.tier),
                style: GoogleFonts.vazirmatn(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== Avatar Picker ====================

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AvatarPickerSheet(
        currentSeed: _user?.avatarSeed ?? _user?.nationalCode ?? 'shahid',
        currentStyle: _user?.avatarStyle ?? 'adventurer',
        onSave: (seed, style) async {
          if (_user == null) return;
          final updated = UserModel(
            id: _user!.id,
            name: _user!.name,
            nationalCode: _user!.nationalCode,
            avatarSeed: seed,
            avatarStyle: style,
            bio: _user!.bio,
            themePreference: _user!.themePreference,
          );
          await DBHelper.updateUser(updated);
          await ApiService.setCurrentUser(updated);
          if (mounted) setState(() => _user = updated);
        },
      ),
    );
  }
}

// ==================== Avatar Picker Sheet ====================

class _AvatarPickerSheet extends StatefulWidget {
  final String currentSeed;
  final String currentStyle;
  final Function(String seed, String style) onSave;

  const _AvatarPickerSheet({
    required this.currentSeed,
    required this.currentStyle,
    required this.onSave,
  });

  @override
  State<_AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<_AvatarPickerSheet> {
  late String _style;
  late String _seed;

  @override
  void initState() {
    super.initState();
    _style = widget.currentStyle;
    _seed = widget.currentSeed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'انتخاب آواتار',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.onSave(_seed, _style);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'ذخیره',
                    style: GoogleFonts.vazirmatn(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Preview
          DiceBearAvatar(seed: _seed, style: _style, size: 100),
          const SizedBox(height: 20),
          // Style selector
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: DiceBearAvatar.availableStyles.length,
              itemBuilder: (context, i) {
                final s = DiceBearAvatar.availableStyles[i];
                final active = s == _style;
                return GestureDetector(
                  onTap: () => setState(() {
                    _style = s;
                    _seed = DateTime.now().millisecondsSinceEpoch.toString();
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: active
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface
                                .withOpacity(0.1),
                        width: active ? 2.5 : 1,
                      ),
                      color: active
                          ? theme.colorScheme.primary.withOpacity(0.08)
                          : null,
                    ),
                    child: DiceBearAvatar(
                      seed: _seed,
                      style: s,
                      size: 60,
                      withBorder: false,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}