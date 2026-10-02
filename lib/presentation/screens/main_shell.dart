import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_books_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';
import '../widgets/animated_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    MyBooksScreen(),
    AchievementsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _index,
        onChanged: (i) => setState(() => _index = i),
        items: const [
          NavItem(Icons.home_outlined, Icons.home_rounded, 'خانه'),
          NavItem(Icons.library_books_outlined, Icons.library_books_rounded,
              'کتاب‌های من'),
          NavItem(Icons.emoji_events_outlined, Icons.emoji_events_rounded,
              'دستاوردها'),
          NavItem(Icons.person_outline_rounded, Icons.person_rounded,
              'پروفایل'),
        ],
      ),
    );
  }
}