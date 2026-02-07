import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioPlaybackService {
  static AudioPlayer? _playerInstance;

  static AudioPlayer get _player {
    if (_playerInstance == null) {
      debugPrint(
        '[AudioPlaybackService] Initializing new AudioPlayer instance',
      );
      _playerInstance = AudioPlayer();
    }
    return _playerInstance!;
  }

  static Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  static Stream<Duration> get positionStream => _player.positionStream;
  static Stream<Duration?> get durationStream => _player.durationStream;

  static Future<void> playFromFile(String path) async {
    debugPrint('[AudioPlaybackService] playFromFile: $path');
    try {
      // Stop and reset to ensure a fresh start and clear any previous audio
      await _player.stop();
      await _player.setFilePath(''); // Clear current source if any

      if (kIsWeb || path.startsWith('http') || path.startsWith('blob:')) {
        // Just audio handles blob URLs and standard URLs via setUrl
        await _player.setUrl(path);
      } else {
        await _player.setFilePath(path);
      }
      await _player.play();
    } catch (e) {
      debugPrint('[AudioPlaybackService] Playback error: $e');
      rethrow; // Rethrow so the UI can catch it
    }
  }

  static Future<void> pause() async {
    await _player.pause();
  }

  static Future<void> resume() async {
    await _player.play();
  }

  static Future<void> stop() async {
    await _player.stop();
  }

  static Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  static void dispose() {
    debugPrint('[AudioPlaybackService] Disposing player instance');
    _playerInstance?.dispose();
    _playerInstance = null;
  }
}
