import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Composition {
  final String id;
  final String imagePath;
  final String poem;
  final String voice;
  final String style;
  final DateTime date;
  final String? audioPath;
  final String? transcript;

  Composition({
    required this.id,
    required this.imagePath,
    required this.poem,
    required this.voice,
    required this.style,
    required this.date,
    this.audioPath,
    this.transcript,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'poem': poem,
    'voice': voice,
    'style': style,
    'date': date.toIso8601String(),
    'audioPath': audioPath,
    'transcript': transcript,
  };

  factory Composition.fromJson(Map<String, dynamic> json) => Composition(
    id: json['id'],
    imagePath: json['imagePath'],
    poem: json['poem'],
    voice: json['voice'],
    style: json['style'],
    date: DateTime.parse(json['date']),
    audioPath: json['audioPath'],
    transcript: json['transcript'],
  );
}

class AudioMemo {
  final String id;
  final String filePath;
  final String? transcript;
  final DateTime date;
  final Duration duration;

  AudioMemo({
    required this.id,
    required this.filePath,
    this.transcript,
    required this.date,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'transcript': transcript,
    'date': date.toIso8601String(),
    'durationMs': duration.inMilliseconds,
  };

  factory AudioMemo.fromJson(Map<String, dynamic> json) => AudioMemo(
    id: json['id'],
    filePath: json['filePath'],
    transcript: json['transcript'],
    date: DateTime.parse(json['date']),
    duration: Duration(milliseconds: json['durationMs']),
  );
}

class StorageService {
  static const String _compKey = 'saved_compositions';
  static const String _memoKey = 'audio_memos';

  // --- Compositions ---

  static Future<void> saveComposition(Composition composition) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_compKey) ?? [];
    current.add(jsonEncode(composition.toJson()));
    await prefs.setStringList(_compKey, current);
  }

  static Future<List<Composition>> loadCompositions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_compKey) ?? [];
    return current
        .map((item) => Composition.fromJson(jsonDecode(item)))
        .toList();
  }

  // --- Audio Memos ---

  static Future<void> saveAudioMemo(AudioMemo memo) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_memoKey) ?? [];
    current.add(jsonEncode(memo.toJson()));
    await prefs.setStringList(_memoKey, current);
  }

  static Future<List<AudioMemo>> loadAudioMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_memoKey) ?? [];
    return current.map((item) => AudioMemo.fromJson(jsonDecode(item))).toList();
  }

  static Future<void> deleteAudioMemo(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_memoKey) ?? [];
    current.removeWhere((item) {
      final memo = AudioMemo.fromJson(jsonDecode(item));
      return memo.id == id;
    });
    await prefs.setStringList(_memoKey, current);
  }
}
