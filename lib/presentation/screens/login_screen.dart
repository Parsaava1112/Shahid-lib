import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/database/db_helper.dart';
import '../../core/utils/national_code_validator.dart';
import '../../core/widgets/animated_background.dart';
import '../../data/models/user_model.dart';
import '../../services/api_service.dart';
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

      // ۲. حالت آفلاین
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
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: GoogleFonts.vazirmatn()),
            ),
          ],
        ),
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
      backgroundColor: theme.colorScheme.background,
      body: AnimatedBackground(
        blobCount: 7,
        intensity: 1.1,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(theme),
                    const SizedBox(height: 28),
                    _buildTitle(theme),
                    const SizedBox(height: 40),
                    _buildFormCard(theme),
                    const SizedBox(height: 24),
                    _buildFooter(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== لوگو ====================
  Widget _buildLogo(ThemeData theme) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        size: 56,
        color: Colors.white,
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
        .then()
        .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.4));
  }

  // ==================== عنوان ====================
  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (r) => LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              theme.colorScheme.primary,
            ],
          ).createShader(r),
          child: Text(
            'کتابخانه شهید سلیمانی',
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'راهِ شهید، راهِ دانایی',
          style: GoogleFonts.vazirmatn(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'برای ورود، نام و کد ملی خود را وارد کنید',
            style: GoogleFonts.vazirmatn(
              fontSize: 11,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  // ==================== فرم ====================
  Widget _buildFormCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // نام
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'نام و نام خانوادگی',
              hintText: 'مثلاً: علی رضایی',
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            style: GoogleFonts.vazirmatn(),
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
              .fadeIn(delay: 600.ms)
              .slideX(begin: -0.15, end: 0),

          const SizedBox(height: 16),

          // کد ملی
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            obscureText: _obscureCode,
            decoration: InputDecoration(
              labelText: 'کد ملی',
              hintText: '۱۰ رقم',
              counterText: '',
              prefixIcon: Icon(
                Icons.badge_outlined,
                color: theme.colorScheme.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCode
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: theme.colorScheme.primary.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() => _obscureCode = !_obscureCode);
                },
              ),
            ),
            style: GoogleFonts.vazirmatn(letterSpacing: 2),
            validator: (v) => NationalCodeValidator.validate(v),
          )
              .animate()
              .fadeIn(delay: 750.ms)
              .slideX(begin: -0.15, end: 0),

          const SizedBox(height: 24),

          // دکمه ورود
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login_rounded, size: 22),
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
              .fadeIn(delay: 900.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 12),

          // پیام آفلاین
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: Colors.amber.shade800),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'در صورت نبود اینترنت، به‌صورت آفلاین وارد می‌شوید',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 11,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 1000.ms),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 700.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }

  // ==================== فوتر ====================
  Widget _buildFooter(ThemeData theme) {
    return Column(
      children: [
        Text(
          'با ورود، شرایط استفاده را می‌پذیرید',
          textAlign: TextAlign.center,
          style: GoogleFonts.vazirmatn(
            fontSize: 11,
            color: theme.colorScheme.onBackground.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_rounded,
                size: 14, color: Colors.red.shade400),
            const SizedBox(width: 6),
            Text(
              'تقدیم به روح بلند شهید حاج قاسم سلیمانی',
              style: GoogleFonts.vazirmatn(
                fontSize: 11,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 1100.ms);
  }
}