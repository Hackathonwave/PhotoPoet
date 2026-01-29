import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'composition_screen.dart';
import 'explore_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/analytics_service.dart';
import 'package:image_picker/image_picker.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    const ExploreScreen(),
    const Center(child: Text('Profile')),
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      AnalyticsService.logPhotoPicked(source: 'gallery');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompositionScreen(image: image),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onFabPressed: _pickImage,
      ),
    );
  }
}
