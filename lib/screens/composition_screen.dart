import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/storage_service.dart';
import '../services/audio_recorder_service.dart';
import '../services/poetry_coordinator.dart';
import '../widgets/waveform_animator.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'result_screen.dart';

class CompositionScreen extends StatefulWidget {
  final XFile? image;
  final String? imageUrl;
  final String heroTag;

  const CompositionScreen({
    super.key,
    this.image,
    this.imageUrl,
    this.heroTag = 'composition_hero',
    this.initialPrompt,
  }) : assert(
         image != null || imageUrl != null,
         'Either image or imageUrl must be provided',
       );

  final String? initialPrompt;

  @override
  State<CompositionScreen> createState() => _CompositionScreenState();
}

class _CompositionScreenState extends State<CompositionScreen> {
  String _selectedVoice = 'The Romantic';
  double _intensity = 0.6;
  bool _isGenerating = false;
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: widget.initialPrompt);
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _voices = [
    {'name': 'Uforo', 'icon': Icons.local_bar_rounded},
    {'name': 'The Romantic', 'icon': Icons.auto_stories_rounded},
    {'name': 'The Haiku', 'icon': Icons.eco_rounded},
    {'name': 'The Beat', 'icon': Icons.music_note_rounded},
  ];

  Future<void> _generatePoetry() async {
    debugPrint('[CompositionScreen] _generatePoetry called');
    setState(() {
      _isGenerating = true;
    });

    try {
      Uint8List? imageBytes;

      if (widget.image != null) {
        imageBytes = await widget.image!.readAsBytes();
      } else if (widget.imageUrl != null) {
        final response = await http.get(Uri.parse(widget.imageUrl!));
        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
        }
      }

      if (imageBytes != null) {
        final poem = await PoetryCoordinator.generatePoetry(
          imageBytes,
          voice: _selectedVoice,
          intensity: _intensity,
        );

        if (mounted) {
          setState(() {
            _isGenerating = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                image: widget.image,
                imageUrl: widget.imageUrl,
                poem: poem,
                voice: _selectedVoice,
                heroTag: widget.heroTag,
              ),
            ),
          );
        }
      } else {
        throw Exception('Could not load image bytes');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171B21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'COMPOSE',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Hero(
              tag: widget.heroTag,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(aspectRatio: 1, child: _buildImage()),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildVoiceMemoSection(),
            const SizedBox(height: 40),
            _buildVoiceSelection(),
            const SizedBox(height: 40),
            _buildIntensitySlider(),
            const SizedBox(height: 48),
            _buildGenerateButton(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.imageUrl != null) {
      return Image.network(widget.imageUrl!, fit: BoxFit.cover);
    } else {
      return kIsWeb
          ? Image.network(widget.image!.path, fit: BoxFit.cover)
          : Image.file(File(widget.image!.path), fit: BoxFit.cover);
    }
  }

  Widget _buildVoiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CHOOSE YOUR VOICE',
              style: GoogleFonts.manrope(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Icon(Icons.auto_awesome, color: Color(0xFFB08D5B), size: 16),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _voices.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final voice = _voices[index];
              final isSelected = _selectedVoice == voice['name'];
              return GestureDetector(
                onTap: () => setState(() => _selectedVoice = voice['name']),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 104,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFF252D36),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFB08D5B)
                          : Colors.white10,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        voice['icon'],
                        color: isSelected
                            ? const Color(0xFFB08D5B)
                            : Colors.white38,
                        size: 28,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        voice['name'].split(' ').last,
                        style: GoogleFonts.manrope(
                          color: isSelected
                              ? const Color(0xFFB08D5B)
                              : Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIntensitySlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'INTENSITY',
              style: GoogleFonts.manrope(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '${(_intensity * 100).toInt()}%',
              style: GoogleFonts.manrope(
                color: const Color(0xFFB08D5B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFB08D5B),
            inactiveTrackColor: Colors.white10,
            thumbColor: const Color(0xFFB08D5B),
            overlayColor: const Color(0xFFB08D5B).withValues(alpha: 0.2),
            trackHeight: 2,
          ),
          child: Slider(
            value: _intensity,
            onChanged: (value) => setState(() => _intensity = value),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LITERAL',
              style: GoogleFonts.manrope(
                color: Colors.white30,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              'ABSTRACT',
              style: GoogleFonts.manrope(
                color: Colors.white30,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: _isGenerating ? null : _generatePoetry,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB08D5B),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: _isGenerating
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_note_rounded, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Compose Poem',
                  style: GoogleFonts.notoSerif(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildVoiceMemoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252D36).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VOICE INSPIRATION',
                style: GoogleFonts.manrope(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (_isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'REC',
                    style: GoogleFonts.manrope(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_promptController.text.isNotEmpty && !_isRecording)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _promptController.text,
                style: GoogleFonts.notoSerif(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: WaveformAnimator(
                  isRecording: _isRecording,
                  color: _isRecording
                      ? const Color(0xFFB08D5B)
                      : Colors.white10,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _handleRecording,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? Colors.red.withValues(alpha: 0.2)
                        : const Color(0xFFB08D5B).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: _isRecording ? Colors.red : const Color(0xFFB08D5B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleRecording() async {
    debugPrint(
      '[CompositionScreen] _handleRecording tapped, isRecording: $_isRecording',
    );
    if (_isRecording) {
      try {
        final path = await AudioRecorderService.stopRecording();
        final now = DateTime.now();
        final duration = _recordingStartTime != null
            ? now.difference(_recordingStartTime!)
            : Duration.zero;

        setState(() {
          _isRecording = false;
          _recordingStartTime = null;
        });

        if (path != null) {
          debugPrint(
            '[CompositionScreen] Recording stopped, duration: ${duration.inSeconds}s',
          );
          // Save to archive automatically
          final memo = AudioMemo(
            id: now.millisecondsSinceEpoch.toString(),
            filePath: path,
            date: now,
            duration: duration,
          );
          await StorageService.saveAudioMemo(memo);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Voice inspiration saved to library!'),
                backgroundColor: const Color(0xFFB08D5B),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('[CompositionScreen] Stop recording failed: $e');
        setState(() {
          _isRecording = false;
          _recordingStartTime = null;
        });
      }
    } else {
      try {
        await AudioRecorderService.startRecording();
        setState(() {
          _isRecording = true;
          _recordingStartTime = DateTime.now();
        });
      } catch (e) {
        debugPrint('[CompositionScreen] Recording failed error: $e');
        if (mounted) {
          String message = 'Recording failed. Please try again.';
          if (e.toString().contains('MICROPHONE_PERMISSION_DENIED')) {
            message =
                'Microphone access denied. Please allow it in your settings.';
          } else if (e.toString().contains('RECORDER_PLUGIN_MISSING')) {
            message = 'Audio recorder plugin not found.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    }
  }
}
