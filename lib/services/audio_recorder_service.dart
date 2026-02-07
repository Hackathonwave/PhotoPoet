import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

class AudioRecorderService {
  static AudioRecorder? _recorderInstance;

  static AudioRecorder get _recorder {
    if (_recorderInstance == null) {
      debugPrint(
        '[AudioRecorderService] Initializing new AudioRecorder instance',
      );
      _recorderInstance = AudioRecorder();
    }
    return _recorderInstance!;
  }

  static Future<bool> hasPermission() async {
    // Record package has its own cross-platform permission check
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      debugPrint('[AudioRecorderService] Permission check failed: $e');
      return false;
    }
  }

  static Future<void> startRecording() async {
    debugPrint('[AudioRecorderService] startRecording called');
    try {
      bool alreadyRecording = false;
      try {
        alreadyRecording = await _recorder.isRecording();
        debugPrint(
          '[AudioRecorderService] alreadyRecording check: $alreadyRecording',
        );
      } catch (e) {
        debugPrint(
          '[AudioRecorderService] isRecording check failed (safe): $e',
        );
      }

      if (alreadyRecording) {
        debugPrint('[AudioRecorderService] Already recording, skipping');
        return;
      }

      debugPrint('[AudioRecorderService] Requesting permissions...');
      if (!await hasPermission()) {
        debugPrint('[AudioRecorderService] Permissions denied');
        throw Exception('MICROPHONE_PERMISSION_DENIED');
      }
      debugPrint('[AudioRecorderService] Permissions granted');

      String? path;
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        // Use .wav for Windows as it's more reliable with the current plugin on that platform
        final extension = (defaultTargetPlatform == TargetPlatform.windows)
            ? 'wav'
            : 'm4a';
        final fileName =
            'memo_${DateTime.now().millisecondsSinceEpoch}.$extension';
        path = p.join(directory.path, fileName);
        debugPrint('[AudioRecorderService] Native path: $path');
      } else {
        debugPrint('[AudioRecorderService] Web mode - using blob');
      }

      // Using WAV for Web and Windows as it's the most compatible
      final useWav = kIsWeb || defaultTargetPlatform == TargetPlatform.windows;

      final config = RecordConfig(
        encoder: useWav ? AudioEncoder.wav : AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      debugPrint(
        '[AudioRecorderService] Starting recorder with ${config.encoder} encoder... path: $path',
      );
      await _recorder.start(config, path: path ?? '');
      debugPrint('[AudioRecorderService] START SUCCESS');
    } catch (e) {
      debugPrint('[AudioRecorderService] START FATAL ERROR: $e');
      if (e.toString().contains('MissingPluginException')) {
        throw Exception('RECORDER_PLUGIN_MISSING');
      }
      rethrow;
    }
  }

  static Future<String?> stopRecording() async {
    debugPrint('[AudioRecorderService] stopRecording called');
    try {
      if (!await _recorder.isRecording()) {
        debugPrint('[AudioRecorderService] Not recording, nothing to stop');
        return null;
      }
      final path = await _recorder.stop();
      debugPrint('[AudioRecorderService] stop SUCCESS, path: $path');

      if (path != null && !kIsWeb) {
        final file = File(path);
        if (await file.exists()) {
          final size = await file.length();
          debugPrint(
            '[AudioRecorderService] File exists at $path, size: $size bytes',
          );
        } else {
          debugPrint(
            '[AudioRecorderService] WARNING: File does NOT exist at $path after stop()',
          );
        }
      }

      return path;
    } catch (e) {
      debugPrint('[AudioRecorderService] Stop recording ERROR: $e');
      return null;
    }
  }

  static Future<bool> isRecording() async {
    try {
      return await _recorder.isRecording();
    } catch (e) {
      debugPrint('[AudioRecorderService] isRecording check failed: $e');
      return false;
    }
  }

  static void dispose() {
    debugPrint('[AudioRecorderService] Disposing recorder instance');
    _recorderInstance?.dispose();
    _recorderInstance = null;
  }
}
