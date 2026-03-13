import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/main_screen.dart';
import 'services/local_poetry_service.dart';
import 'services/analytics_service.dart';
import 'firebase_options.dart';

void main() async {
  // Emergency logging for startup issues
  debugPrint('--- APP STARTUP ---');

  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Binding initialized');

  // Catch ALL top-level errors to prevent white screen
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  try {
    // Initialize Firebase (Google Analytics & Firestore)
    debugPrint('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');

    // Log App Open
    await AnalyticsService.logAppOpen();
  } catch (e) {
    debugPrint('--- FIREBASE INITIALIZATION FAILED ---');
    debugPrint('Error: $e');
    debugPrint('Check if google-services.json (Android) or GoogleService-Info.plist (iOS) are missing.');
    debugPrint('---------------------------------------');
    // We continue so the app doesn't show a white screen, 
    // but features requiring Firebase will show descriptive errors.
  }

  try {
    // Initialize Local Poetry System
    await LocalPoetryService.init();
    await LocalPoetryService.seedDatabaseIfNeeded();
  } catch (e) {
    debugPrint('Local storage initialization failed: $e');
  }

  runApp(const PhotoPoetApp());
}

class PhotoPoetApp extends StatelessWidget {
  const PhotoPoetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Poet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF171B21), // background-dark
        textTheme: GoogleFonts.manropeTextTheme(
          ThemeData.dark().textTheme.copyWith(
            displayLarge: GoogleFonts.notoSerif(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            titleLarge: GoogleFonts.notoSerif(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2C4A59),
          surface: Color(0xFF252D36),
          secondary: Color(0xFFB08D5B), // Bronze
        ),
      ),
      home: const MainScreen(),
    );
  }
}
