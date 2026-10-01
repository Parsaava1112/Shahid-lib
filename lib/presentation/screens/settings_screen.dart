// lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // حالت تاریک/روشن
          Card(
            child: SwitchListTile(
              title: const Text('حالت تاریک'),
              subtitle: const Text('تغییر بین تم روشن و تاریک'),
              value: themeController.isDarkMode,
              onChanged: (_) => themeController.toggleTheme(),
              secondary: Icon(
                themeController.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // انتخاب رنگ اصلی
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      const Text(
                        'رنگ اصلی اپلیکیشن',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      AppThemeColors.colorSchemes.length,
                      (index) {
                        final scheme =
                            AppThemeColors.colorSchemes[index];
                        final isSelected =
                            themeController.colorIndex == index;
                        return GestureDetector(
                          onTap: () =>
                              themeController.setColorIndex(index),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: scheme['primary'],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.secondary
                                        : Colors.transparent,
                                    width: 4,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: scheme['primary']!
                                                .withOpacity(0.5),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 30,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                scheme['name']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}