import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'core/theme/theme_controller.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('❌ FLUTTER ERROR: ${details.exception}');
    };

    try {
      await JustAudioBackground.init(
        androidNotificationChannelId:
            'com.example.shahid_suleimani_library.channel.audio',
        androidNotificationChannelName: 'کتابخانه شهید سلیمانی',
        androidNotificationOngoing: true,
      );
    } catch (e) {
      debugPrint('⚠️ JustAudioBackground init failed: $e');
    }

    runApp(const ShahidLibraryApp());
  }, (error, stack) {
    debugPrint('❌ ZONE ERROR: $error');
  });
}

class ShahidLibraryApp extends StatelessWidget {
  const ShahidLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'کتابخانه شهید حاج قاسم سلیمانی',
            debugShowCheckedModeBanner: false,
            theme: themeController.themeFor(Brightness.light),
            darkTheme: themeController.themeFor(Brightness.dark),
            themeMode: themeController.mode,
            locale: const Locale('fa', 'IR'),
            builder: (context, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}