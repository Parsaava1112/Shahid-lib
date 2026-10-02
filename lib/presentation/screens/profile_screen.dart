import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/database/db_helper.dart';
import '../../core/services/achievement_service.dart';
import '../../core/widgets/animated_background.dart';
import '../../data/models/user_model.dart';
import '../../services/api_service.dart';
import '../widgets/dicebear_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  Map<String, dynamic> _stats = {};
  int _completed = 0;
  int _reading = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final user = await ApiService.getCurrentUser();
    Map<String, dynamic> stats = {};
    int completed = 0;
    int reading = 0;

    if (user?.id != null) {
      stats = await DBHelper.getUserStats(user!.id!);
      final db = await DBHelper.database;
      final doneRows = await db.rawQuery(
        'SELECT COUNT(*) as c FROM reading_progress WHERE user_id = ? AND is_completed = 1',
        [user.id],
      );
      final readRows = await db.rawQuery(
        'SELECT COUNT(*) as c FROM reading_progress WHERE user_id = ? AND is_completed = 0',
        [user.id],
      );
      completed = (doneRows.first['c'] as num?)?.toInt() ?? 0;
      reading = (readRows.first['c'] as num?)?.toInt() ?? 0;
    }

    if (!mounted) return;
    setState(() {
      _user = user;
      _stats = stats;
      _completed = completed;
      _reading = reading;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBackground(
      blobCount: 5,
      intensity: 0.5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildAvatarCard(scheme),
                      const SizedBox(height: 20),
                      _buildStatsGrid(scheme),
                      const SizedBox(height: 20),
                      _buildActionButtons(scheme),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAvatarCard(ColorScheme scheme) {
    final xp = _stats['total_xp'] as int? ?? 0;
    final level = _stats['level'] as int? ?? 1;
    final xpInLevel = AchievementService.xpInCurrentLevel(xp);
    final xpNeeded = AchievementService.xpForNextLevel(level);
    final progress = xpNeeded == 0 ? 0.0 : (xpInLevel / xpNeeded).clamp(0, 1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            scheme.primary.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          DiceBearAvatar(
            seed: _user?.avatarSeed ?? _user?.nationalCode ?? 'shahid',
            style: _user?.avatarStyle ?? 'adventurer',
            size: 110,
            withBorder: false,
            onTap: _showAvatarPicker,
          ),
          const SizedBox(height: 12),
          Text(
            _user?.name ?? 'کاربر',
            style: GoogleFonts.vazirmatn(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.nationalCode ?? '',
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.military_tech,
                        color: Colors.amber.shade300, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'سطح $level',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$xp XP',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.toDouble(),
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$xpInLevel از $xpNeeded XP تا سطح بعدی',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ColorScheme scheme) {
    final stats = [
      _StatData(
        'کتاب‌های کامل‌شده',
        '$_completed',
        Icons.check_circle_rounded,
        const Color(0xFF43A047),
      ),
      _StatData(
        'در حال مطالعه',
        '$_reading',
        Icons.menu_book_rounded,
        const Color(0xFF1E88E5),
      ),
      _StatData(
        'دقیقه مطالعه',
        '${_stats['total_minutes'] ?? 0}',
        Icons.timer_rounded,
        const Color(0xFFFB8C00),
      ),
      _StatData(
        'روز متوالی',
        '${_stats['current_streak'] ?? 0}',
        Icons.local_fire_department_rounded,
        const Color(0xFFE53935),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: stats.map((s) => _StatCard(data: s)).toList(),
    );
  }

  Widget _buildActionButtons(ColorScheme scheme) {
    return Column(
      children: [
        _actionTile(
          scheme,
          Icons.edit_rounded,
          'ویرایش نام',
          'نام نمایشی خود را تغییر دهید',
          _editName,
        ),
        _actionTile(
          scheme,
          Icons.face_rounded,
          'تغییر آواتار',
          'آواتار خفن بسازید',
          _showAvatarPicker,
        ),
        _actionTile(
          scheme,
          Icons.emoji_events_rounded,
          'دستاوردهای من',
          'ببینید چه دستاوردهایی کسب کرده‌اید',
          () {},
        ),
      ],
    );
  }

  Widget _actionTile(ColorScheme scheme, IconData icon, String title,
      String sub, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: scheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          color: scheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_back_ios,
                    size: 16,
                    color: scheme.onSurface.withOpacity(0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== انتخاب آواتار ====================
  void _showAvatarPicker() {
    final scheme = Theme.of(context).colorScheme;
    String selectedStyle = _user?.avatarStyle ?? 'adventurer';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: scheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'آواتار خفن خود را انتخاب کنید',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: DiceBearAvatar.availableStyles.length,
                  itemBuilder: (_, i) {
                    final style = DiceBearAvatar.availableStyles[i];
                    final active = style == selectedStyle;
                    return GestureDetector(
                      onTap: () => setSt(() => selectedStyle = style),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: active
                                ? scheme.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: DiceBearAvatar(
                          seed: _user?.nationalCode ?? 'shahid',
                          style: style,
                          size: 60,
                          withBorder: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, MediaQuery.of(ctx).padding.bottom + 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_user?.id != null) {
                        final updated = UserModel(
                          id: _user!.id,
                          name: _user!.name,
                          nationalCode: _user!.nationalCode,
                          avatarSeed: _user!.avatarSeed,
                          avatarStyle: selectedStyle,
                          bio: _user!.bio,
                          themePreference: _user!.themePreference,
                        );
                        await DBHelper.updateUser(updated);
                        await ApiService.setCurrentUser(updated);
                        if (mounted) {
                          setState(() => _user = updated);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'آواتار تغییر کرد',
                                style: GoogleFonts.vazirmatn(),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      'ذخیره',
                      style: GoogleFonts.vazirmatn(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editName() {
    final ctrl = TextEditingController(text: _user?.name ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ویرایش نام',
            style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'نام جدید',
            hintStyle: GoogleFonts.vazirmatn(),
          ),
          style: GoogleFonts.vazirmatn(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('انصراف',
                style: GoogleFonts.vazirmatn()),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty || _user?.id == null) return;
              final updated = UserModel(
                id: _user!.id,
                name: name,
                nationalCode: _user!.nationalCode,
                avatarSeed: _user!.avatarSeed,
                avatarStyle: _user!.avatarStyle,
                bio: _user!.bio,
                themePreference: _user!.themePreference,
              );
              await DBHelper.updateUser(updated);
              await ApiService.setCurrentUser(updated);
              if (mounted) {
                setState(() => _user = updated);
                Navigator.pop(ctx);
              }
            },
            child: Text('ذخیره',
                style: GoogleFonts.vazirmatn()),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  _StatData(this.label, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.15),
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
              color: data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const Spacer(),
          Text(
            data.value,
            style: GoogleFonts.vazirmatn(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
          ),
          Text(
            data.label,
            style: GoogleFonts.vazirmatn(
              fontSize: 11,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}