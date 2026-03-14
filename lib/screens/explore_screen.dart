import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import '../services/explore_service.dart';
import '../services/local_poetry_service.dart';
import '../services/analytics_service.dart';
import 'composition_screen.dart';
import '../widgets/mood_orb.dart';
import '../widgets/poetic_whisper.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  List<UnsplashPhoto> _photos = [];
  bool _isLoading = false;
  String _currentWhisper = "";
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0.0;
      });
    });
    _fetchPhotos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPhotos({String? query}) async {
    setState(() => _isLoading = true);
    try {
      final effectiveQuery = (query != null && query.isNotEmpty)
          ? query
          : (_searchController.text.trim().isEmpty
                ? 'cinematic'
                : _searchController.text.trim());

      final results = await ExploreService.searchPhotos(effectiveQuery);
      setState(() {
        _photos = results;
        _isLoading = false;
      });
      _updateWhisper(0);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateWhisper(int index) async {
    if (_photos.isEmpty) return;
    try {
      final poemTxt = await LocalPoetryService.getRandomPoem();
      if (mounted) {
        final lines = poemTxt
            .split('\n')
            .where((l) => l.trim().length > 10)
            .toList();
        setState(() {
          _currentWhisper = lines.isNotEmpty
              ? lines.first
              : "Captured in a breath...";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _currentWhisper = "Captured in a breath...");
    }
  }

  double _orbX = 0.0;
  double _orbY = 0.0;

  void _onMoodOrbChanged(double x, double y) {
    _orbX = x;
    _orbY = y;
  }

  Future<void> _onMoodOrbReleased() async {
    setState(() => _isLoading = true);
    try {
      final atmosphericResults = await ExploreService.searchAtmosphere(
        _orbX,
        _orbY,
      );
      setState(() {
        _photos = atmosphericResults;
        _isLoading = false;
      });
      _updateWhisper(0);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _photos.isEmpty && !_isLoading
              ? const Center(
                  child: Text(
                    "No inspirations found",
                    style: TextStyle(color: Colors.white24),
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _photos.length,
                  onPageChanged: _updateWhisper,
                  itemBuilder: (context, index) {
                    return _buildImmersiveCard(index);
                  },
                ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFB08D5B)),
            ),

          // Floating Interface
          _buildFloatingUI(),

          // Mood Orb
          Positioned(
            right: 20,
            bottom: 120,
            child: MoodOrb(
              onMoodChanged: _onMoodOrbChanged,
              onMoodReleased: _onMoodOrbReleased,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImmersiveCard(int index) {
    final photo = _photos[index];
    final double offset = _pageOffset - index;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image with Parallax
        Transform.scale(
          scale: 1.1 + (offset.abs() * 0.2),
          child: Transform.translate(
            offset: Offset(0, offset * 100),
            child: CachedNetworkImage(
              imageUrl: photo.url,
              fit: BoxFit.cover,
              placeholder: (context, url) => BlurHash(hash: photo.blurHash),
            ),
          ),
        ),

        // Darkened overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.4),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),

        // Poetic Whisper
        Positioned(
          bottom: 200,
          left: 0,
          right: 0,
          child: PoeticWhisper(
            key: ValueKey('whisper_${photo.id}'),
            text: _currentWhisper,
          ),
        ),

        // Info Row
        Positioned(
          bottom: 140,
          left: 24,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Captured by ${photo.userName}",
                style: GoogleFonts.manrope(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  AnalyticsService.logPhotoPicked(source: 'ethereal_flow');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompositionScreen(
                        imageUrl: photo.url,
                        heroTag: 'explore_${photo.id}',
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB08D5B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFB08D5B).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        color: Color(0xFFB08D5B),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "INSCRIBE",
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFB08D5B),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingUI() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 24,
      right: 24,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search ether...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              onSubmitted: (val) => _fetchPhotos(query: val),
            ),
          ),
        ),
      ),
    );
  }
}
