import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.library_books,
                size: 120,
                color: Colors.white,
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(delay: 200.ms, duration: 800.ms),
              const SizedBox(height: 24),
              Text(
                'کتابخانه شهید حاج قاسم سلیمانی',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 16),
              const Text(
                'در حال آماده‌سازی...',
                style: TextStyle(color: Colors.white70),
              ).animate().fadeIn(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}