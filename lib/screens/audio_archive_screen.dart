import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/audio_playback_service.dart';
import 'package:just_audio/just_audio.dart';
import '../widgets/waveform_animator.dart';

class AudioArchiveScreen extends StatefulWidget {
  const AudioArchiveScreen({super.key});

  @override
  State<AudioArchiveScreen> createState() => _AudioArchiveScreenState();
}

class _AudioArchiveScreenState extends State<AudioArchiveScreen> {
  List<AudioMemo> _memos = [];
  bool _isLoading = true;
  String? _playingMemoId;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    debugPrint('[AudioArchiveScreen] Loading memos...');
    final memos = await StorageService.loadAudioMemos();
    if (mounted) {
      setState(() {
        _memos = memos.reversed.toList();
        _isLoading = false;
      });
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _handlePlay(AudioMemo memo) async {
    debugPrint('[AudioArchiveScreen] _handlePlay tapped for: ${memo.id}');
    try {
      if (_playingMemoId == memo.id) {
        await AudioPlaybackService.stop();
        if (mounted) setState(() => _playingMemoId = null);
      } else {
        await AudioPlaybackService.playFromFile(memo.filePath);
        if (mounted) setState(() => _playingMemoId = memo.id);

        // Reset when done
        AudioPlaybackService.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (mounted) setState(() => _playingMemoId = null);
          }
        });
      }
    } catch (e) {
      debugPrint('[AudioArchiveScreen] Playback error caught: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Playback Error: $e')));
      }
    }
  }

  // Removed transcription logic to avoid quota issues

  // Removed transcript dialog

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171B21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'AUDIO ARCHIVE',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _memos.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _memos.length,
              itemBuilder: (context, index) {
                final memo = _memos[index];
                final isPlaying = _playingMemoId == memo.id;

                return _buildMemoCard(memo, isPlaying);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_none_rounded, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            'Silence of the soul...',
            style: GoogleFonts.notoSerif(
              color: Colors.white38,
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Record your inspirations in the Compose tab.',
            style: GoogleFonts.manrope(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoCard(AudioMemo memo, bool isPlaying) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF252D36).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _handlePlay(memo),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? const Color(0xFFB08D5B).withValues(alpha: 0.2)
                          : Colors.white10,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: isPlaying
                          ? const Color(0xFFB08D5B)
                          : Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM dd, hh:mm a').format(memo.date),
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _formatDuration(memo.duration),
                        style: GoogleFonts.manrope(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white24,
                  ),
                  onPressed: () async {
                    await StorageService.deleteAudioMemo(memo.id);
                    _loadMemos();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            WaveformAnimator(
              isRecording: isPlaying,
              color: isPlaying ? const Color(0xFFB08D5B) : Colors.white10,
            ),
            const SizedBox(height: 20),
            // Removed transcribe button
          ],
        ),
      ),
    );
  }
}
