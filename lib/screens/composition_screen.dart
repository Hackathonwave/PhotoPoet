import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/poetry_coordinator.dart';
import 'package:image_picker/image_picker.dart';
import 'result_screen.dart';
import 'package:http/http.dart' as http;

class CompositionScreen extends StatefulWidget {
  final XFile? image;
  final String? imageUrl;
  final String heroTag;

  const CompositionScreen({
    super.key,
    this.image,
    this.imageUrl,
    this.heroTag = 'composition_hero',
  }) : assert(
         image != null || imageUrl != null,
         'Either image or imageUrl must be provided',
       );

  @override
  State<CompositionScreen> createState() => _CompositionScreenState();
}

class _CompositionScreenState extends State<CompositionScreen> {
  String _selectedVoice = 'The Romantic';
  double _intensity = 0.6;
  bool _isGenerating = false;

  final List<Map<String, dynamic>> _voices = [
    {'name': 'Uforo', 'icon': Icons.local_bar_rounded},
    {'name': 'The Romantic', 'icon': Icons.auto_stories_rounded},
    {'name': 'The Haiku', 'icon': Icons.eco_rounded},
    {'name': 'The Beat', 'icon': Icons.music_note_rounded},
  ];

  Future<void> _generatePoetry() async {
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
}
