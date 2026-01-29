import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

class ResultScreen extends StatefulWidget {
  final XFile? image;
  final String? imageUrl;
  final String poem;
  final String voice;
  final String heroTag;

  const ResultScreen({
    super.key,
    this.image,
    this.imageUrl,
    required this.poem,
    required this.voice,
    this.heroTag = 'composition_hero',
  }) : assert(image != null || imageUrl != null);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String _currentPoem;
  String _selectedStyle = 'Classic';

  @override
  void initState() {
    super.initState();
    _currentPoem = widget.poem;
  }

  TextStyle _getPoemStyle() {
    switch (_selectedStyle) {
      case 'Modern':
        return GoogleFonts.manrope(
          fontSize: 18,
          height: 1.8,
          color: Colors.white.withValues(alpha: 0.9),
          letterSpacing: 1.2,
        );
      case 'Typewriter':
        return GoogleFonts.specialElite(
          fontSize: 18,
          height: 1.8,
          color: Colors.white.withValues(alpha: 0.8),
        );
      default:
        return GoogleFonts.notoSerif(
          fontSize: 18,
          height: 1.8,
          fontStyle: FontStyle.italic,
          color: Colors.white.withValues(alpha: 0.9),
        );
    }
  }

  void _handleShare() async {
    try {
      final result = await Share.share(
        'Check out this poem from Photo Poet:\n\n$_currentPoem',
      );
      if (result.status == ShareResultStatus.dismissed) return;
      AnalyticsService.logCompositionShared(method: 'system_share');
    } catch (e) {
      debugPrint('Share error: $e');
      await Clipboard.setData(ClipboardData(text: _currentPoem));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sharing unavailable. Poem copied to clipboard!'),
            backgroundColor: Color(0xFFB08D5B),
          ),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    try {
      final composition = Composition(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: widget.image?.path ?? widget.imageUrl!,
        poem: _currentPoem,
        voice: widget.voice,
        style: _selectedStyle,
        date: DateTime.now(),
      );

      await StorageService.saveComposition(composition);
      AnalyticsService.logCompositionSaved();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Composition saved to library!'),
            backgroundColor: Color(0xFFB08D5B),
          ),
        );
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  void _handleEdit() {
    final controller = TextEditingController(text: _currentPoem);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252D36),
        title: Text(
          'Edit Poem',
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 8,
          style: GoogleFonts.notoSerif(color: Colors.white70),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFB08D5B)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _currentPoem = controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB08D5B),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171B21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'YOUR BROADSIDE',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Hero(
              tag: widget.heroTag,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF252D36).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      child: AspectRatio(
                        aspectRatio: 0.8,
                        child: _buildImage(),
                      ),
                    ),
                    _buildContent(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildBottomActions(),
            const SizedBox(height: 60),
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

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['Classic', 'Modern', 'Typewriter'].map((style) {
              final isSelected = _selectedStyle == style;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(style),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedStyle = style);
                    }
                  },
                  backgroundColor: Colors.transparent,
                  selectedColor: Colors.white10,
                  labelStyle: GoogleFonts.manrope(
                    fontSize: 12,
                    color: isSelected
                        ? const Color(0xFFB08D5B)
                        : Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFFB08D5B).withValues(alpha: 0.5)
                          : Colors.white10,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text(
            'Whispers of the Scene',
            style: GoogleFonts.notoSerif(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB08D5B),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  _currentPoem,
                  textAlign: TextAlign.center,
                  textStyle: _getPoemStyle(),
                  speed: const Duration(milliseconds: 50),
                ),
              ],
              totalRepeatCount: 1,
              displayFullTextOnTap: true,
            ),
          ),
          const SizedBox(height: 32),
          Container(width: 40, height: 1, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            '— Photo Poet AI',
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF252D36),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.ios_share, 'Share', onTap: _handleShare),
          _buildActionButton(
            Icons.file_download_outlined,
            'Save',
            onTap: _handleSave,
          ),
          _buildActionButton(Icons.edit_outlined, 'Edit', onTap: _handleEdit),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white70, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: Colors.white38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
