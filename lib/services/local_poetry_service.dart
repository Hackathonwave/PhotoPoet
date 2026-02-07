import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalPoetryService {
  static const String _boxName = 'local_poems';
  static const String _recentBoxName = 'recently_used_ids';
  static const int _maxRecents = 99; // Ensures 1 in 100 repeat logic

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
    await Hive.openBox(_recentBoxName);
  }

  static Future<void> seedDatabaseIfNeeded() async {
    final box = Hive.box(_boxName);
    // If box does not have exactly 105 poems (our new unique set size)
    if (box.length < 105) {
      try {
        debugPrint('Seeding/Updating database with 100+ poems...');
        final String response = await rootBundle.loadString(
          'assets/data/poems.json',
        );
        final List<dynamic> data = json.decode(response);

        // Clear existing to ensure fresh 100+ set if updating
        await box.clear();
        for (var i = 0; i < data.length; i++) {
          final item = Map<String, dynamic>.from(data[i]);
          item['id'] ??= i.toString(); // Ensure every poem has an ID
          await box.add(item);
        }
        debugPrint('Database seeded with ${box.length} poems');
      } catch (e) {
        debugPrint('Error seeding database: $e');
      }
    }
  }

  static Future<String> getRandomPoem({String? voice}) async {
    final box = Hive.box(_boxName);
    final recentBox = Hive.box(_recentBoxName);

    if (box.isEmpty) return "The silence speaks where poems fade...";

    List<dynamic> poems = box.values.toList();
    List<String> recentIds = List<String>.from(recentBox.values);

    // Filter by voice
    if (voice != null) {
      final voiceFiltered = poems.where((p) {
        final tags = List<String>.from(p['tags'] ?? []);
        return tags.contains(voice);
      }).toList();
      if (voiceFiltered.isNotEmpty) poems = voiceFiltered;
    }

    // Filter out recently used poems to satisfy "Repeat only once in a 100"
    // If we have enough poems, we filter. If not, we just shuffle.
    final available = poems.where((p) => !recentIds.contains(p['id'])).toList();

    final selectedPoem = (available.isNotEmpty)
        ? (available..shuffle()).first
        : (poems..shuffle()).first;

    // Update recents
    final id = selectedPoem['id'].toString();
    recentIds.add(id);
    if (recentIds.length > _maxRecents) {
      recentIds.removeAt(0);
    }

    // Save recents back to box
    await recentBox.clear();
    for (var i = 0; i < recentIds.length; i++) {
      await recentBox.add(recentIds[i]);
    }

    final lines = List<String>.from(selectedPoem['lines']);
    return lines.join('\n');
  }
}
