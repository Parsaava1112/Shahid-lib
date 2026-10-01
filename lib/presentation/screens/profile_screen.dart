import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_controller.dart';
import '../../data/models/user_model.dart';
import '../../services/api_service.dart';
import '../widgets/avatar_widget.dart';

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
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await ApiService.getCurrentUser();
    Map<String, dynamic> stats = {
      'total_books_read': 0,
      'total_minutes_read': 0,
      'current_streak': 0,
      'badges': [],
    };
    if (user?.id != null) {
      stats = await ApiService.fetchUserStats(user!.id!);
    }
    if (!mounted) return;
    setState(() {
      _user = user;
      _stats = stats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = context.watch<ThemeController>();

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('پروفایل')),
        body: Center(
          child: Text(
            'لطفاً دوباره وارد شوید',
            style: GoogleFonts.vazirmatn(),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پروفایل',
          style: GoogleFonts.vazirmatn(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeController.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => themeController.toggleTheme(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ==================== آواتار و نام ====================
            Center(
              child: Column(
                children: [
                  AvatarWidget(
                    seed: _user!.avatarSeed ?? _user!.nationalCode,
                    style: _user!.avatarStyle ?? 'adventurer',
                    size: 110,
                  ).animate().scale(duration: 500.ms).fadeIn(),
                  const SizedBox(height: 12),
                  Text(
                    _user!.name,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'کد ملی: ${_user!.nationalCode}',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================== آمار ====================
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.menu_book,
                    label: 'کتاب خوانده‌شده',
                    value: '${_stats['total_books_read'] ?? 0}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.timer,
                    label: 'دقیقه مطالعه',
                    value: '${_stats['total_minutes_read'] ?? 0}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department,
                    label: 'استریک روزانه',
                    value: '${_stats['current_streak'] ?? 0}',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events,
                    label: 'تعداد نشان‌ها',
                    value:
                        '${(_stats['badges'] as List?)?.length ?? 0}',
                    color: Colors.amber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ==================== نشان‌ها ====================
            _buildBadgesSection(
              (_stats['badges'] as List?) ?? [],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection(List<dynamic> badges) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نشان‌های شما',
              style: GoogleFonts.vazirmatn(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            badges.isEmpty
                ? Text(
                    'هنوز نشانی کسب نکرده‌اید. شروع کنید!',
                    style: GoogleFonts.vazirmatn(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: badges.map<Widget>((badge) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              badge['icon'] ?? '🏅',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              badge['name'] ?? '',
                              style: GoogleFonts.vazirmatn(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: c, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.vazirmatn(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: c,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.vazirmatn(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}