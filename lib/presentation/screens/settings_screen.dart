import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/animated_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ctrl = context.watch<ThemeController>();

    return AnimatedBackground(
      blobCount: 4,
      intensity: 0.5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            physics: const BouncingScrollPhysics(),
            children: [
              Text(
                'تنظیمات',
                style: GoogleFonts.vazirmatn(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ظاهر اپلیکیشن را شخصی‌سازی کنید',
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  color: scheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),

              // ==================== حالت نمایش ====================
              _sectionTitle(scheme, 'حالت نمایش', Icons.brightness_6),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.08),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _modeTile(context, ctrl, ThemeMode.light, 'روشن',
                        Icons.light_mode_rounded),
                    _modeTile(context, ctrl, ThemeMode.system, 'خودکار',
                        Icons.brightness_auto_rounded),
                    _modeTile(context, ctrl, ThemeMode.dark, 'تاریک',
                        Icons.dark_mode_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================== پالت رنگی ====================
              _sectionTitle(scheme, 'پالت رنگی', Icons.palette_rounded),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: AppThemes.palettes.length,
                itemBuilder: (_, i) => _paletteTile(context, ctrl, i),
              ),

              const SizedBox(height: 24),

              // ==================== پیش‌نمایش زنده ====================
              _sectionTitle(scheme, 'پیش‌نمایش زنده', Icons.visibility_rounded),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      scheme.primary,
                      scheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppThemes.palettes[ctrl.palette].name,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'این یک پیش‌نمایش زنده از تم انتخابی شماست. '
                      'رنگ‌ها، متن‌ها و عناصر رابط کاربری به این شکل نمایش داده می‌شوند.',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        height: 1.6,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: scheme.primary,
                          ),
                          child: Text(
                            'دکمه نمونه',
                            style: GoogleFonts.vazirmatn(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                                color: Colors.white, width: 2),
                          ),
                          child: Text(
                            'دکمه دیگر',
                            style: GoogleFonts.vazirmatn(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================== درباره ====================
              _sectionTitle(scheme, 'درباره', Icons.info_outline_rounded),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Icons.menu_book_rounded,
                        size: 48, color: scheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'کتابخانه مدرسه استعداد های درخشان شهید بهشتی ناحیه دو شهرری متوسطه اول',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'نسخه 2.0.0',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        color: scheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'راهِ شهید، راهِ دانایی',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(ColorScheme scheme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.vazirmatn(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _modeTile(BuildContext context, ThemeController ctrl,
      ThemeMode mode, String label, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    final active = ctrl.mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => ctrl.setMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: active
                    ? scheme.onPrimary
                    : scheme.onSurface.withOpacity(0.6),
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  color: active
                      ? scheme.onPrimary
                      : scheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paletteTile(BuildContext context, ThemeController ctrl, int i) {
    final scheme = Theme.of(context).colorScheme;
    final p = AppThemes.palettes[i];
    final active = ctrl.palette == i;

    return GestureDetector(
      onTap: () => ctrl.setPalette(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? p.primary : scheme.onSurface.withOpacity(0.08),
            width: active ? 2.5 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: p.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [p.primary, p.secondary],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: p.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.surface, width: 2),
                    ),
                  ),
                ),
                if (active)
                  Positioned(
                    top: -2,
                    left: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: p.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              p.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}