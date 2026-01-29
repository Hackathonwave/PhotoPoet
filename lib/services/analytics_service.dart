import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver getObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log when the app is opened
  static Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  /// Log when a photo is picked for composition
  static Future<void> logPhotoPicked({required String source}) async {
    await _analytics.logEvent(
      name: 'photo_picked',
      parameters: {
        'source': source, // 'gallery' or 'explore'
      },
    );
  }

  /// Log when a poem is generated
  static Future<void> logPoemGenerated({
    required String voice,
    required double intensity,
    required bool isFallback,
  }) async {
    await _analytics.logEvent(
      name: 'poem_generated',
      parameters: {
        'voice': voice,
        'intensity': intensity,
        'method': isFallback ? 'local_fallback' : 'gemini_ai',
      },
    );
  }

  /// Log when a composition is saved to the library
  static Future<void> logCompositionSaved() async {
    await _analytics.logEvent(name: 'composition_saved');
  }

  /// Log when a composition is shared
  static Future<void> logCompositionShared({required String method}) async {
    await _analytics.logEvent(
      name: 'composition_shared',
      parameters: {'method': method},
    );
  }

  /// Log screen views manually if needed (useful for more granular tracking)
  static Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
