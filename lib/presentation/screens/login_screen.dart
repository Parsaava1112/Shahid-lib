import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/database/db_helper.dart';
import '../../core/utils/national_code_validator.dart';
import '../../core/widgets/animated_background.dart';
import '../../data/models/user_model.dart';
import '../../services/api_service.dart';
import '../widgets/dicebear_avatar.dart';
import 'shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _codeFocus = FocusNode();

  late AnimationController _entryCtrl;
  late AnimationController _shakeCtrl;
  late AnimationController _avatarCtrl;

  bool _loading = false;
  bool _obscureCode = false;
  bool _showAvatar = false;
  String _avatarSeed = '';
  String _avatarStyle = 'adventurer';

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _avatarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _nameCtrl.addListener(_onNameChanged);
    _entryCtrl.forward();
  }

  void _onNameChanged() {
    final text = _nameCtrl.text.trim();
    final shouldShow = text.length >= 3;
    if (shouldShow != _showAvatar) {
      setState(() {
        _showAvatar = shouldShow;
        _avatarSeed = text;
        if (shouldShow) _avatarCtrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onNameChanged);
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _nameFocus.dispose();
    _codeFocus.dispose();
    _entryCtrl.dispose();
    _shakeCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  // ==================== ورود ====================
  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      _shakeCtrl.forward(from: 0);
      return;
    }

    setState(() => _loading = true);

    final name = _nameCtrl.text.trim();
    final code = _codeCtrl.text.trim();

    try {
      // ۱. تلاش برای اتصال به سرور
      final result = await ApiService.login(
        name: name,
        nationalCode: code,
      );

      if (result['success'] == true) {
        final user = result['user'] as UserModel;
        await ApiService.setCurrentUser(user);
        await _goToShell();
        return;
      }

      // ۲. حالت آفلاین
      if (result['offline'] == true) {
        final existing = await DBHelper.getUserByNationalCode(code);
        if (existing != null) {
          await ApiService.setCurrentUser(existing);
          await _goToShell();
          return;
        } else {
          final user = UserModel(
            name: name,
            nationalCode: code,
            avatarSeed: code,
            avatarStyle: _avatarStyle,
          );
          final id = await DBHelper.insertUser(user);
          final saved = UserModel(
            id: id,
            name: name,
            nationalCode: code,
            avatarSeed: code,
            avatarStyle: _avatarStyle,
          );
          await ApiService.setCurrentUser(saved);
          await _goToShell();
          return;
        }
      }

      // ۳. خطا
      _showError(result['error'] ?? 'خطای نامشخص');
      _shakeCtrl.forward(from: 0);
    } catch (e) {
      _showError('خطا در ورود: $e');
      _shakeCtrl.forward(from: 0);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _goToShell() async {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const ShellScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(msg, style: GoogleFonts.vazirmatn()),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedBackground(
        blobCount: 6,
        intensity: 1.2,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(scheme),
                    const SizedBox(height: 36),
                    _buildForm(scheme),
                    const SizedBox(height: 24),
                    _buildLoginButton(scheme),
                    const SizedBox(height: 20),
                    _buildFooter(scheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== هدر با انیمیشن ====================
  Widget _buildHeader(ColorScheme scheme) {
    return Column(
      children: [
        // لوگو با انیمیشن ورود
        ScaleTransition(
          scale: CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _entryCtrl,
              curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    scheme.primary,
                    scheme.primary.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.4),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // عنوان
        FadeTransition(
          opacity: CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _entryCtrl,
              curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
            )),
            child: Text(
              'خوش آمدید',
              style: GoogleFonts.vazirmatn(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: scheme.onBackground,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        FadeTransition(
          opacity: CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
          ),
          child: Text(
            'برای ورود، اطلاعات خود را وارد کنید',
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              color: scheme.onBackground.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== فرم ====================
  Widget _buildForm(ColorScheme scheme) {
    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (context, child) {
        final shake = _shakeCtrl.value == 0
            ? 0.0
            : (1 - _shakeCtrl.value) *
                10 *
                ((_shakeCtrl.value * 4).floor().isEven ? 1 : -1);
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _entryCtrl,
          curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
          )),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withOpacity(0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: scheme.primary.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // ==================== آواتار زنده ====================
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  child: _showAvatar
                      ? Column(
                          children: [
                            ScaleTransition(
                              scale: CurvedAnimation(
                                parent: _avatarCtrl,
                                curve: Curves.elasticOut,
                              ),
                              child: DiceBearAvatar(
                                seed: _avatarSeed,
                                style: _avatarStyle,
                                size: 90,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'آواتار شما',
                              style: GoogleFonts.vazirmatn(
                                fontSize: 12,
                                color:
                                    scheme.onSurface.withOpacity(0.55),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                // ==================== نام ====================
                TextFormField(
                  controller: _nameCtrl,
                  focusNode: _nameFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_codeFocus),
                  decoration: InputDecoration(
                    labelText: 'نام و نام خانوادگی',
                    hintText: 'مثلاً: علی محمدی',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: scheme.primary,
                    ),
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
                ),

                const SizedBox(height: 16),

                // ==================== کد ملی ====================
                TextFormField(
                  controller: _codeCtrl,
                  focusNode: _codeFocus,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  obscureText: _obscureCode,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: 'کد ملی',
                    hintText: '۱۰ رقم',
                    counterText: '',
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                      color: scheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCode
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: scheme.onSurface.withOpacity(0.5),
                      ),
                      onPressed: () =>
                          setState(() => _obscureCode = !_obscureCode),
                    ),
                  ),
                  validator: (v) => NationalCodeValidator.validate(v),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== دکمه ورود ====================
  Widget _buildLoginButton(ColorScheme scheme) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _entryCtrl,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
        )),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
              shadowColor: scheme.primary.withOpacity(0.5),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _loading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      key: const ValueKey('text'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ورود به کتابخانه',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 22,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== فوتر ====================
  Widget _buildFooter(ColorScheme scheme) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: scheme.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'اطلاعات شما امن ذخیره می‌شود',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    color: scheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'کتابخانه شهید حاج قاسم سلیمانی',
            style: GoogleFonts.vazirmatn(
              fontSize: 11,
              color: scheme.onBackground.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}