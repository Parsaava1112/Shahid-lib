import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/database/db_helper.dart';
import '../../data/models/user_model.dart';
import '../../core/utils/national_code_validator.dart';
import '../../services/api_service.dart';
import '../widgets/animated_background.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCode = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final code = _codeController.text.trim();

    try {
      // ۱. تلاش برای اتصال به سرور
      final result = await ApiService.login(
        name: name,
        nationalCode: code,
      );

      if (result['success'] == true) {
        final user = result['user'] as UserModel;
        await ApiService.setCurrentUser(user);
        await _goToHome();
        return;
      }

      // ۲. اگر سرور در دسترس نبود، از دیتابیس محلی استفاده کن
      if (result['offline'] == true) {
        final existing = await DBHelper.getUserByNationalCode(code);
        if (existing != null) {
          await ApiService.setCurrentUser(existing);
          await _goToHome();
          return;
        } else {
          final user = UserModel(
            name: name,
            nationalCode: code,
            avatarSeed: code,
            avatarStyle: 'adventurer',
          );
          final id = await DBHelper.insertUser(user);
          final saved = UserModel(
            id: id,
            name: name,
            nationalCode: code,
            avatarSeed: code,
            avatarStyle: 'adventurer',
          );
          await ApiService.setCurrentUser(saved);
          await _goToHome();
          return;
        }
      }

      if (mounted) {
        _showError(result['error'] ?? 'خطای نامشخص');
      }
    } catch (e) {
      if (mounted) _showError('خطا: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _goToHome() async {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.vazirmatn()),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBackground(
        blobCount: 5,
        intensity: 0.7,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withOpacity(0.85),
                theme.colorScheme.primary.withOpacity(0.5),
                theme.colorScheme.background,
              ],
              stops: const [0.0, 0.35, 0.75],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ==================== لوگوی اصلی ====================
                      _buildLogo(theme),

                      const SizedBox(height: 24),

                      // ==================== نام کتابخانه ====================
                      Text(
                        'کتابخانه شهید بهشتی',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),

                      const SizedBox(height: 10),

                      // ==================== نام کامل مدرسه ====================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          child: Text(
                            'مدرسه استعداد های درخشان شهید بهشتی\nناحیه ۲ شهرری - متوسطه اول',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

                      const SizedBox(height: 32),

                      // ==================== کارت فرم ورود ====================
                      _buildLoginCard(theme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== لوگو با تصویر اصلی ====================

  Widget _buildLogo(ThemeData theme) {
    return Container(
      width: 130,
      height: 130,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: theme.colorScheme.secondary.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.school_rounded,
            size: 70,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .scale(delay: 200.ms, duration: 700.ms, curve: Curves.elasticOut);
  }

  // ==================== کارت فرم ====================

  Widget _buildLoginCard(ThemeData theme) {
    return Card(
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            // آیکون بالای فرم
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ورود به حساب کاربری',
              style: GoogleFonts.vazirmatn(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),

            // ==================== فیلد نام ====================
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'نام و نام خانوادگی',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'نام را وارد کنید';
                }
                if (v.trim().length < 3) {
                  return 'نام باید حداقل ۳ حرف باشد';
                }
                return null;
              },
            )
                .animate()
                .fadeIn(delay: 800.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 16),

            // ==================== فیلد کد ملی ====================
            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              obscureText: _obscureCode,
              decoration: InputDecoration(
                labelText: 'کد ملی',
                prefixIcon: const Icon(Icons.badge_outlined),
                counterText: '',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCode
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                  onPressed: () {
                    setState(() => _obscureCode = !_obscureCode);
                  },
                ),
              ),
              validator: (v) => NationalCodeValidator.validate(v),
            )
                .animate()
                .fadeIn(delay: 1000.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 24),

            // ==================== دکمه ورود ====================
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login_rounded, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'ورود به کتابخانه',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            )
                .animate()
                .fadeIn(delay: 1200.ms)
                .scale(),

            const SizedBox(height: 14),

            // ==================== متن راهنما ====================
            Text(
              'با وارد کردن نام و کد ملی، وارد کتابخانه می‌شوید',
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ).animate().fadeIn(delay: 1400.ms),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 700.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}