import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalPoetryService {
  static const String _boxName = 'local_poems';

  static Future<void> init() async {
    await Hive.initFlutter();
    // In a real app with code generation, we'd register the adapter here
    // Hive.registerAdapter(LocalPoemAdapter());
    // Since we are moving fast, we'll store as dynamic Map for now in the box
  }

  static Future<void> seedDatabaseIfNeeded() async {
    final box = await Hive.openBox(_boxName);
    if (box.isEmpty) {
      try {
        final String response = await rootBundle.loadString(
          'assets/data/poems.json',
        );
        final List<dynamic> data = json.decode(response);

        for (var item in data) {
          await box.add(item);
        }
        debugPrint('Database seeded with ${data.length} poems');
      } catch (e) {
        debugPrint('Error seeding database: $e');
      }
    }
  }

  static Future<String> getRandomPoem({String? voice}) async {
    final box = await Hive.openBox(_boxName);
    if (box.isEmpty) return "The silence speaks where poems fade...";

    List<dynamic> poems = box.values.toList();

    if (voice != null) {
      final filtered = poems.where((p) {
        final tags = List<String>.from(p['tags'] ?? []);
        return tags.contains(voice);
      }).toList();

      if (filtered.isNotEmpty) {
        poems = filtered;
      }
    }

    poems.shuffle();
    final selected = poems.first;
    final lines = List<String>.from(selected['lines']);
    return lines.join('\n');
  }
}
