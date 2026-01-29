import 'ai_service.dart';
import 'local_poetry_service.dart';
import 'analytics_service.dart';
import 'package:flutter/foundation.dart';

class PoetryCoordinator {
  static Future<String> generatePoetry(
    Uint8List imageBytes, {
    required String voice,
    required double intensity,
  }) async {
    try {
      // 1. Try Gemini AI first
      final poem = await AIService.generatePoetry(
        imageBytes,
        voice: voice,
        intensity: intensity,
      );

      // Simple check if it returned an error message instead of a poem
      // (Gemini API sometimes returns error strings in catch blocks)
      if (poem.startsWith('Error') || poem.contains('API key')) {
        throw Exception('AI Generation failed: $poem');
      }

      AnalyticsService.logPoemGenerated(
        voice: voice,
        intensity: intensity,
        isFallback: false,
      );
      return poem;
    } catch (e) {
      debugPrint('Falling back to local poetry database due to: $e');

      // 2. Fallback to Local Hive Database
      // Add a slight "thinking" delay to maintain the premium feel
      await Future.delayed(const Duration(milliseconds: 1500));

      AnalyticsService.logPoemGenerated(
        voice: voice,
        intensity: intensity,
        isFallback: true,
      );
      return await LocalPoetryService.getRandomPoem(voice: voice);
    }
  }
}
