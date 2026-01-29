import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import '../services/explore_service.dart';
import '../services/ai_service.dart';
import '../services/analytics_service.dart';
import 'composition_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UnsplashPhoto> _photos = [];
  List<String> _suggestions = ['Nature', 'Urban', 'Abstract', 'Minimalist'];
  bool _isLoading = false;
  String _selectedColor = 'All';

  final List<Map<String, dynamic>> _colors = [
    {'name': 'All', 'color': Colors.grey},
    {
      'name': 'Black_and_white',
      'color': Colors.black,
      'display': Colors.white10,
    },
    {'name': 'Blue', 'color': Colors.blue},
    {'name': 'Green', 'color': Colors.green},
    {'name': 'Yellow', 'color': Colors.yellow},
    {'name': 'Orange', 'color': Colors.orange},
    {'name': 'Red', 'color': Colors.red},
    {'name': 'Purple', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos({String? query}) async {
    setState(() => _isLoading = true);
    try {
      final effectiveQuery = (query != null && query.isNotEmpty)
          ? query
          : (_searchController.text.trim().isEmpty
                ? 'nature'
                : _searchController.text.trim());

      final results = await ExploreService.searchPhotos(
        effectiveQuery,
        color: _selectedColor == 'All' ? null : _selectedColor,
      );
      setState(() {
        _photos = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAISuggestions(String mood) async {
    final suggestions = await AIService.suggestSearchTerms(mood);
    setState(() {
      _suggestions = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildFilters()),
          _buildPhotoGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search inspiration...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFB08D5B),
                      ),
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          _getAISuggestions(_searchController.text);
                        }
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (val) => _fetchPhotos(query: val),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildMoodSuggestions(), _buildColorPicker()],
    );
  }

  Widget _buildMoodSuggestions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: _suggestions.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return ActionChip(
              label: Text(_suggestions[index]),
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              labelStyle: GoogleFonts.manrope(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.white10),
              ),
              onPressed: () {
                _searchController.text = _suggestions[index];
                _fetchPhotos(query: _suggestions[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COLOR MOOD',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white38,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _colors.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final colorItem = _colors[index];
                final isSelected = _selectedColor == colorItem['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = colorItem['name']);
                    _fetchPhotos();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorItem['display'] ?? colorItem['color'],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFB08D5B)
                            : Colors.white10,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Color(0xFFB08D5B),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFB08D5B)),
        ),
      );
    }

    if (_photos.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'No photos found',
            style: TextStyle(color: Colors.white38),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          final heroTag = 'explore_${photo.id}_$index';
          return GestureDetector(
            onTap: () {
              AnalyticsService.logPhotoPicked(source: 'explore');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CompositionScreen(imageUrl: photo.url, heroTag: heroTag),
                ),
              );
            },
            child: Hero(
              tag: heroTag,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: photo.thumbUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => AspectRatio(
                      aspectRatio: 0.7,
                      child: BlurHash(hash: photo.blurHash),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            ),
          );
        },
        childCount: _photos.length,
      ),
    );
  }
}
