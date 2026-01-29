import 'package:hive/hive.dart';

class LocalPoem extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String lines;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final List<String> tags;

  LocalPoem({
    required this.title,
    required this.lines,
    required this.author,
    required this.tags,
  });

  factory LocalPoem.fromJson(Map<String, dynamic> json) {
    return LocalPoem(
      title: json['title'] ?? 'Untitled',
      lines: (json['lines'] as List).join('\n'),
      author: json['author'] ?? 'Unknown',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'lines': lines.split('\n'),
      'author': author,
      'tags': tags,
    };
  }
}
