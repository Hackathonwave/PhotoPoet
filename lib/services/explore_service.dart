import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class UnsplashPhoto {
  final String id;
  final String url;
  final String thumbUrl;
  final String blurHash;
  final String userName;
  final String? description;

  UnsplashPhoto({
    required this.id,
    required this.url,
    required this.thumbUrl,
    required this.blurHash,
    required this.userName,
    this.description,
  });

  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) {
    return UnsplashPhoto(
      id: json['id'],
      url: json['urls']['regular'],
      thumbUrl: json['urls']['small'],
      blurHash: json['blur_hash'] ?? 'LEHV6nWB2yk8pyo0adRj00WBjtWV',
      userName: json['user']['name'],
      description: json['description'] ?? json['alt_description'],
    );
  }
}

class ExploreService {
  // Register at https://unsplash.com/developers to get an Access Key
  static const String _accessKey = 'YOUR_UNSPLASH_ACCESS_KEY';

  static Future<List<UnsplashPhoto>> searchPhotos(
    String query, {
    String? color,
    int page = 1,
  }) async {
    if (_accessKey == 'YOUR_UNSPLASH_ACCESS_KEY' || _accessKey.isEmpty) {
      // Mock data if no key is provided
      return List.generate(
        10,
        (index) => UnsplashPhoto(
          id: 'mock_$index',
          url: 'https://picsum.photos/seed/${query}_$index/800/1200',
          thumbUrl: 'https://picsum.photos/seed/${query}_$index/400/600',
          blurHash: 'LEHV6nWB2yk8pyo0adRj00WBjtWV',
          userName: 'Mock User',
          description: 'Mock description for $query',
        ),
      );
    }

    final Map<String, String> queryParams = {
      'query': query,
      'client_id': _accessKey,
      'per_page': '20',
      'page': page.toString(),
    };

    if (color != null && color != 'All') {
      queryParams['color'] = color.toLowerCase();
    }

    final uri = Uri.https('api.unsplash.com', '/search/photos', queryParams);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => UnsplashPhoto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load photos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching photos: $e');
      return [];
    }
  }

  static Future<List<UnsplashPhoto>> getRecentPhotos({int page = 1}) async {
    if (_accessKey == 'YOUR_UNSPLASH_ACCESS_KEY' || _accessKey.isEmpty) {
      // Return mock data
      return searchPhotos('nature');
    }

    final uri = Uri.https('api.unsplash.com', '/photos', {
      'client_id': _accessKey,
      'per_page': '20',
      'page': page.toString(),
      'order_by': 'latest',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => UnsplashPhoto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recent photos');
      }
    } catch (e) {
      debugPrint('Error fetching recent photos: $e');
      return [];
    }
  }
}
