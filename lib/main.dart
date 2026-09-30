import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/local_storage.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // راه‌اندازی Hive
  await LocalStorageService.init();
  
  // راه‌اندازی پخش صوتی در پس‌زمینه
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.shahidsoleimani.library.channel.audio',
    androidNotificationChannelName: 'پخش کتاب صوتی',
    androidNotificationOngoing: true,
  );
  
  runApp(
    const ProviderScope(
      child: ShahidSoleimaniLibraryApp(),
    ),
  );
}

class ShahidSoleimaniLibraryApp extends ConsumerWidget {
  const ShahidSoleimaniLibraryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'کتابخانه شهید حاج قاسم سلیمانی',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
        ),
        textTheme: GoogleFonts.vazirmatnTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.vazirmatn(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      locale: const Locale('fa', 'IR'),
      home: const SplashScreen(),
    );
  }
}