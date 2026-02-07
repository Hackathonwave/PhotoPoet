import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static FirebaseAnalytics? _instance;

  static bool _initialized = false;

  static Future<void> _init() async {
    if (_initialized) return;
    try {
      _instance = FirebaseAnalytics.instance;
      _initialized = true;
    } catch (e) {
      debugPrint('Analytics initialization failed: $e');
    }
  }

  static FirebaseAnalyticsObserver? getObserver() {
    if (_instance == null) return null;
    return FirebaseAnalyticsObserver(analytics: _instance!);
  }

  /// Log when the app is opened
  static Future<void> logAppOpen() async {
    await _init();
    try {
      await _instance?.logAppOpen();
    } catch (e) {
      debugPrint('Log App Open failed: $e');
    }
  }

  /// Log when a photo is picked for composition
  static Future<void> logPhotoPicked({required String source}) async {
    await _init();
    try {
      await _instance?.logEvent(
        name: 'photo_picked',
        parameters: {'source': source},
      );
    } catch (e) {
      debugPrint('Log Photo Picked failed: $e');
    }
  }

  /// Log when a poem is generated
  static Future<void> logPoemGenerated({
    required String voice,
    required double intensity,
    required bool isFallback,
  }) async {
    await _init();
    try {
      await _instance?.logEvent(
        name: 'poem_generated',
        parameters: {
          'voice': voice,
          'intensity': intensity,
          'method': isFallback ? 'local_fallback' : 'gemini_ai',
        },
      );
    } catch (e) {
      debugPrint('Log Poem Generated failed: $e');
    }
  }

  /// Log when a composition is saved to the library
  static Future<void> logCompositionSaved() async {
    await _init();
    try {
      await _instance?.logEvent(name: 'composition_saved');
    } catch (e) {
      debugPrint('Log Composition Saved failed: $e');
    }
  }

  /// Log when a composition is shared
  static Future<void> logCompositionShared({required String method}) async {
    await _init();
    try {
      await _instance?.logEvent(
        name: 'composition_shared',
        parameters: {'method': method},
      );
    } catch (e) {
      debugPrint('Log Composition Shared failed: $e');
    }
  }

  /// Log screen views manually if needed
  static Future<void> logScreenView({required String screenName}) async {
    await _init();
    try {
      await _instance?.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Log Screen View failed: $e');
    }
  }
}
