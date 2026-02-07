import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AudioUtils {
  /// Safely reads bytes from a path (local file on native, blob URL on web)
  static Future<Uint8List> readBytes(String path) async {
    debugPrint('[AudioUtils] Reading bytes from: $path');

    if (kIsWeb) {
      // On Web, paths are often blob URLs (e.g., blob:http://localhost:1234/...)
      // We must use http to fetch the blob data
      try {
        final response = await http.get(Uri.parse(path));
        if (response.statusCode == 200) {
          debugPrint(
            '[AudioUtils] Successfully fetched blob bytes (${response.bodyBytes.length} bytes)',
          );
          return response.bodyBytes;
        } else {
          throw Exception(
            'Failed to fetch audio blob: Status ${response.statusCode}',
          );
        }
      } catch (e) {
        debugPrint('[AudioUtils] Error fetching web blob: $e');
        rethrow;
      }
    } else {
      // On Native, paths are local file paths
      try {
        final file = File(path);
        final bytes = await file.readAsBytes();
        debugPrint(
          '[AudioUtils] Successfully read local file bytes (${bytes.length} bytes)',
        );
        return bytes;
      } catch (e) {
        debugPrint('[AudioUtils] Error reading local file: $e');
        rethrow;
      }
    }
  }
}
