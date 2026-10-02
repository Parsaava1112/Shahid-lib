import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItem(this.icon, this.activeIcon, this.label);
}

class AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<NavItem> items;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 72,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: scheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? scheme.primary.withOpacity(0.12) : null,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: active ? 1.15 : 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      child: Icon(
                        active ? items[i].activeIcon : items[i].icon,
                        color: active
                            ? scheme.primary
                            : scheme.onSurface.withOpacity(0.5),
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: GoogleFonts.vazirmatn(
                        fontSize: active ? 11 : 10,
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: active
                            ? scheme.primary
                            : scheme.onSurface.withOpacity(0.5),
                      ),
                      child: Text(items[i].label),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}