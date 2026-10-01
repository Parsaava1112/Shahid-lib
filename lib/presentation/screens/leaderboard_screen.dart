// lib/presentation/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/avatar_widget.dart';
import '../../services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaderboard('weekly');
  }

  Future<void> _loadLeaderboard(String period) async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getLeaderboard(period);
      setState(() { _leaderboard = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول امتیازات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'هفتگی'), Tab(text: 'ماهانه'), Tab(text: 'کل')],
          onTap: (i) {
            final periods = ['weekly', 'monthly', 'all'];
            _loadLeaderboard(periods[i]);
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _leaderboard.isEmpty
              ? Center(child: Text('هنوز امتیازی ثبت نشده'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _leaderboard.length,
                  itemBuilder: (context, index) {
                    final item = _leaderboard[index];
                    final isTop3 = index < 3;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isTop3
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : null,
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item['rank']}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isTop3
                                    ? theme.colorScheme.secondary
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            AvatarWidget(
                              seed: item['avatar_seed'] ?? '',
                              size: 40,
                            ),
                          ],
                        ),
                        title: Text(item['name'] ?? 'ناشناس'),
                        subtitle: Text(
                          '${item['books_count']} کتاب | '
                          '${item['total_minutes']} دقیقه',
                        ),
                        trailing: isTop3
                            ? Icon(
                                index == 0
                                    ? Icons.emoji_events
                                    : Icons.star,
                                color: theme.colorScheme.secondary,
                                size: 32,
                              )
                            : null,
                      ),
                    ).animate().fadeIn(
                          delay: (80 * index).ms,
                        ).slideX(begin: 0.2, end: 0);
                  },
                ),
    );
  }
}