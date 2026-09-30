import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dice_bear/flutter_dice_bear.dart';
import '../providers/user_provider.dart';
import '../widgets/animated_avatar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider);
    _nameController.text = user?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final isDark = user?.isDarkMode ?? false;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // آواتار
                      AnimatedAvatar(
                        seed: user?.diceBearSeed ?? 'default',
                        style: user?.avatarStyle ?? 'adventurer',
                        size: 100,
                      ),
                      const SizedBox(height: 16),
                      // نام کاربر
                      FadeInUp(
                        child: Text(
                          user?.name ?? 'کاربر',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // تنظیمات
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ویرایش نام
                    FadeInUp(
                      child: _buildSettingCard(
                        icon: Icons.edit,
                        title: 'ویرایش نام',
                        subtitle: user?.name ?? '',
                        onTap: () => _showEditNameDialog(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // تغییر آواتار
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: _buildSettingCard(
                        icon: Icons.face,
                        title: 'تغییر آواتار',
                        subtitle: 'ظاهر خود را شخصی‌سازی کنید',
                        onTap: () => _showAvatarPicker(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // حالت تاریک
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: SwitchListTile(
                          secondary: Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(
                            'حالت تاریک',
                            style: GoogleFonts.vazirmatn(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            isDark ? 'فعال' : 'غیرفعال',
                            style: GoogleFonts.vazirmatn(fontSize: 12),
                          ),
                          value: isDark,
                          onChanged: (_) {
                            ref.read(userProfileProvider.notifier).toggleDarkMode();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // کتاب‌های مورد علاقه
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: _buildSettingCard(
                        icon: Icons.favorite,
                        title: 'کتاب‌های مورد علاقه',
                        subtitle: '${user?.favoriteBookIds.length ?? 0} کتاب',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // کتاب‌های دانلود شده
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildSettingCard(
                        icon: Icons.download,
                        title: 'کتاب‌های دانلود شده',
                        subtitle: 'مدیریت دانلودها',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // درباره ما
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: _buildSettingCard(
                        icon: Icons.info,
                        title: 'درباره ما',
                        subtitle: 'کتابخانه شهید حاج قاسم سلیمانی',
                        onTap: () => _showAboutDialog(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.vazirmatn(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'ویرایش نام',
          style: GoogleFonts.vazirmatn(),
        ),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'نام جدید خود را وارد کنید',
            hintStyle: GoogleFonts.vazirmatn(),
          ),
          style: GoogleFonts.vazirmatn(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'انصراف',
              style: GoogleFonts.vazirmatn(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(userProfileProvider.notifier).updateName(_nameController.text);
              Navigator.pop(context);
            },
            child: Text(
              'ذخیره',
              style: GoogleFonts.vazirmatn(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'انتخاب آواتار',
              style: GoogleFonts.vazirmatn(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildAvatarStyleTile('adventurer', 'ماجراجو'),
                  _buildAvatarStyleTile('fun-emoji', 'ایموجی'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStyleTile(String style, String label) {
    return ListTile(
      leading: DiceBearWidget(
        style: style == 'fun-emoji'
            ? FunEmojiStyle(options: FunEmojiOptions(seed: 'preview'))
            : AdventurerStyle(options: AdventurerOptions(seed: 'preview')),
        width: 50,
        height: 50,
      ),
      title: Text(
        label,
        style: GoogleFonts.vazirmatn(),
      ),
      onTap: () {
        final newSeed = 'seed-${DateTime.now().millisecondsSinceEpoch}';
        ref.read(userProfileProvider.notifier).updateAvatar(newSeed, style);
        Navigator.pop(context);
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'درباره ما',
          style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book, size: 60, color: Color(0xFF1B5E20)),
            const SizedBox(height: 16),
            Text(
              'کتابخانه شهید حاج قاسم سلیمانی',
              style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'نسخه ۱.۰.۰',
              style: GoogleFonts.vazirmatn(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'دانش، نور است',
              style: GoogleFonts.vazirmatn(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('بستن', style: GoogleFonts.vazirmatn()),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}