import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/database/db_helper.dart';
import '../../data/models/user_model.dart';
import '../../core/utils/national_code_validator.dart';
import '../../services/api_service.dart';
import 'home_screen.dart';

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
          // ثبت‌نام محلی
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

      // ۳. خطای دیگر
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
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.7),
              theme.colorScheme.background,
            ],
            stops: const [0.0, 0.4, 0.8],
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
                    // ==================== لوگو ====================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.library_books,
                        size: 70,
                        color: Colors.white,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .scale(delay: 200.ms, duration: 600.ms),

                    const SizedBox(height: 24),

                    // ==================== عنوان ====================
                    Text(
                      'کتابخانه شهید حاج قاسم سلیمانی',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 8),

                    Text(
                      'لطفاً برای ورود اطلاعات خود را وارد کنید',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

                    const SizedBox(height: 40),

                    // ==================== فرم ====================
                    Card(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'نام و نام خانوادگی',
                                prefixIcon: Icon(Icons.person_outline),
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
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () => _obscureCode = !_obscureCode,
                                    );
                                  },
                                ),
                              ),
                              validator: (v) =>
                                  NationalCodeValidator.validate(v),
                            )
                                .animate()
                                .fadeIn(delay: 1000.ms)
                                .slideX(begin: -0.2, end: 0),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'ورود به کتابخانه',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 1200.ms)
                                .scale(),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}