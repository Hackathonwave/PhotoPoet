import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Composition {
  final String id;
  final String imagePath;
  final String poem;
  final String voice;
  final String style;
  final DateTime date;

  Composition({
    required this.id,
    required this.imagePath,
    required this.poem,
    required this.voice,
    required this.style,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'poem': poem,
    'voice': voice,
    'style': style,
    'date': date.toIso8601String(),
  };

  factory Composition.fromJson(Map<String, dynamic> json) => Composition(
    id: json['id'],
    imagePath: json['imagePath'],
    poem: json['poem'],
    voice: json['voice'],
    style: json['style'],
    date: DateTime.parse(json['date']),
  );
}

class StorageService {
  static const String _key = 'saved_compositions';

  static Future<void> saveComposition(Composition composition) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_key) ?? [];
    current.add(jsonEncode(composition.toJson()));
    await prefs.setStringList(_key, current);
  }

  static Future<List<Composition>> loadCompositions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_key) ?? [];
    return current
        .map((item) => Composition.fromJson(jsonDecode(item)))
        .toList();
  }
}
