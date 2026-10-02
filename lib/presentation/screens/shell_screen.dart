import 'package:flutter/material.dart';
import '../widgets/animated_bottom_nav.dart';
import 'home_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    AchievementsScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: _pages[_index],
        ),
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _index,
        onChanged: (i) => setState(() => _index = i),
        items: const [
          NavItem(Icons.home_outlined, Icons.home_rounded, 'خانه'),
          NavItem(Icons.emoji_events_outlined, Icons.emoji_events_rounded,
              'دستاوردها'),
          NavItem(Icons.person_outline, Icons.person_rounded, 'پروفایل'),
          NavItem(Icons.settings_outlined, Icons.settings_rounded, 'تنظیمات'),
        ],
      ),
    );
  }
}