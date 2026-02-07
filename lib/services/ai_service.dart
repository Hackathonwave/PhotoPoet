import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AIService {
  // IMPORTANT: For production, use environment variables or a secure vault.
  static const String _apiKey = 'AIzaSyCIiqgiDV4pR-V9J_zniR6r8VXiazMXPVw';

  static Future<String> generatePoetry(
    Uint8List imageBytes, {
    required String voice,
    required double intensity,
  }) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE' || _apiKey.isEmpty) {
      return 'Please provide a valid Gemini API key in AIService to generate poetry.';
    }

    try {
      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

      final String intensityDescription = intensity < 0.3
          ? "literal and descriptive"
          : intensity < 0.7
          ? "balanced between literal and abstract"
          : "highly abstract and metaphorical";

      final prompt = TextPart(
        "Write an evocative poem of exactly 10 lines based on this photo. "
        "The style should be modern, deeply immersive, and highly poetic. "
        "Voice: $voice. "
        "Intensity: $intensityDescription. "
        "Focus on the mood, visual texture, and emotional resonance. "
        "Ensure the poem is exactly 10 lines long.",
      );

      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      return response.text ??
          'The photo left the poet speechless. (No response)';
    } catch (e) {
      return 'Error generating poetry: $e';
    }
  }

  static Future<List<String>> suggestSearchTerms(String mood) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE' || _apiKey.isEmpty) {
      return ['Mountains', 'Ocean', 'Forest', 'City'];
    }

    try {
      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

      final prompt =
          "A user of a poetry app is looking for a photo to write a poem about. "
          "Their current mood/theme is: '$mood'. "
          "Suggest 4 short, highly visual search terms (1-2 words each) that would find evocative photos for this mood. "
          "Return ONLY a comma-separated list of the 4 terms.";

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? "";

      if (text.isEmpty) return ['Nature', 'Urban', 'Abstract', 'Minimalist'];

      return text.split(',').map((s) => s.trim()).take(4).toList();
    } catch (e) {
      return ['Nature', 'Urban', 'Abstract', 'Minimalist'];
    }
  }

  static Future<String> transcribeAudio(Uint8List audioBytes) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE' || _apiKey.isEmpty) {
      return 'Please provide a valid Gemini API key for transcription.';
    }

    try {
      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

      final prompt = TextPart(
        "Transcribe this audio recording accurately. "
        "If there are any poetic or deep thoughts, preserve them exactly as spoken. "
        "Return ONLY the transcription text.",
      );

      // On Web, and now Windows, we use wav for max compatibility. On other native, we use m4a.
      String mimeType = 'audio/m4a';
      if (kIsWeb || (defaultTargetPlatform == TargetPlatform.windows)) {
        mimeType = 'audio/wav';
      }

      final audioPart = DataPart(mimeType, audioBytes);

      final response = await model.generateContent([
        Content.multi([prompt, audioPart]),
      ]);

      return response.text ?? 'Could not transcribe audio.';
    } catch (e) {
      debugPrint('Transcription error: $e');
      return 'Error transcribing: $e';
    }
  }
}
