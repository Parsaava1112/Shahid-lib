// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'core/theme/theme_controller.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.shahid_library.channel.audio',
    androidNotificationChannelName: 'Shahid Library Audio',
    androidNotificationOngoing: true,
  );
  runApp(const ShahidLibraryApp());
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
            theme: themeController.getTheme(Brightness.light),
            darkTheme: themeController.getTheme(Brightness.dark),
            themeMode: themeController.themeMode,
            locale: const Locale('fa', 'IR'),
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}