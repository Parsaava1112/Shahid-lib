import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/utils/national_code_validator.dart';
import '../../data/models/user_model.dart';
import '../../core/database/db_helper.dart';
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final existing = await DBHelper.getUserByNationalCode(
        _codeController.text.trim(),
      );

      if (existing != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        final user = UserModel(
          name: _nameController.text.trim(),
          nationalCode: _codeController.text.trim(),
          avatarSeed: _codeController.text.trim(),
          avatarStyle: 'adventurer',
        );
        await DBHelper.insertUser(user);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.background,
            ],
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
                    // لوگو یا انیمیشن
                    Icon(
                      Icons.library_books,
                      size: 100,
                      color: theme.colorScheme.secondary,
                    )
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .scale(delay: 200.ms, duration: 600.ms),
                    const SizedBox(height: 24),
                    Text(
                      'کتابخانه شهید حاج قاسم سلیمانی',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'لطفاً برای ورود اطلاعات خود را وارد کنید',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'نام و نام خانوادگی',
                        prefixIcon: Icon(Icons.person),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'نام را وارد کنید';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.3, end: 0),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'کد ملی',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      validator: (v) => NationalCodeValidator.validate(v),
                    ).animate().fadeIn(delay: 1000.ms).slideX(begin: -0.3, end: 0),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'ورود به کتابخانه',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ).animate().fadeIn(delay: 1200.ms).scale(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}