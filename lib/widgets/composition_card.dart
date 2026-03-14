import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../screens/result_screen.dart';

class RecentCompositionsGrid extends StatelessWidget {
  const RecentCompositionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Static mock data that was previously displayed
    final compositions = [
      {
        'title': 'Autumn Whispers',
        'verse':
            '"The golden leaves fall gently,\nLike memories of a sun\nWe once knew..."',
        'date': 'OCT 12',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAM0Mx6dAIoabfe9BejsAu9UXnkHMWA5W98eoeK0vW7CV-jnAjg_v-RSntGUQWiUEgavLiHrvALwJahE92ZjMR8ec4ueRWP8yRDWqxsrpAVsFHDLIYixeDi2BUGnIQH1gkD6hecLsBSxNmV1anAKkzzbEzf0v0Ab9XCibk-AHYFzLxGbNoQgnHYFCKIwdGZcNaZ9kYns6toAIZ5l0PLfVARUChmhFiITUjrswxZTCMa7NyVG7qiAjFZHkBPmziNdZLhdOgoJDBWPXQ',
      },
      {
        'title': 'Neon Rain',
        'verse':
            '"Reflections dance on stone,\nA liquid electric dream\nIn the silence..."',
        'date': 'YESTERDAY',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuApoZYXoVUXs2dxeJ8abEkdR190a2tGIAmao0G1DdW5XRGIKR2_xcBjuUgaJqaMBzeFmnVruKOvdC6RABmp3WsXYEvoRQS8UWLUAI02lSVmYkFhZUVAX_ZSzqZoYhMokYcnbZJFg53b-cc7oTh49I40kCwVPlNWNUWIy_V3TN-dGhOhra-jc10-xubmvdG16bvtqwpgtJqMPP9cWQUNPp4LSxVUlJdyPyEXsFhxcRjYzB5Jojs8wdqKBo2pGT1bODbF7JyqMuUHYFo',
      },
      {
        'title': 'Silent Flight',
        'verse':
            '"Wings against the grey,\nA heartbeat in the void\nOf morning mist..."',
        'date': 'SEPT 28',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDzYO1mw0haS_4Mm0XJlkC4dVk9h7IigkbWUR-EJfuxAw9ksgy5_x5Cbc1WsL_LoTPEq09u-ZGsfJhgoTdpZL4ljAqclniasibLgLcY52F-IaO9IJimU6pZNwWK4TfZZa1EZbG_BeRjKtAk9RVYS-ozHmf_sUOV6t4Sfc_sKF6t9csz4PbE_2_hGJqp-6skf_YZRcu2H7tT762UAW5hEsovQMSK8996YCCGG-w2U-Hj7qjCtLhBMI2tnNRe14q_NPxmY9UxSrfX6EQ',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: compositions.length + 1,
        itemBuilder: (context, index) {
          if (index < compositions.length) {
            final item = compositions[index];
            final heroTag = 'recent_${item['title']}_$index';
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      imageUrl: item['image'],
                      poem: item['verse']!,
                      voice: 'The Romantic',
                      heroTag: heroTag,
                    ),
                  ),
                );
              },
              child: Transform.translate(
                offset: Offset(0, index.isOdd ? 32 : 0),
                child: CompositionCard(
                  title: item['title']!,
                  verse: item['verse']!,
                  date: item['date']!,
                  imageUrl: item['image']!,
                  heroTag: heroTag,
                ),
              ),
            );
          } else {
            return Transform.translate(
              offset: const Offset(0, 32),
              child: const EmptyStateCard(),
            );
          }
        },
      ),
    );
  }
}

class CompositionCard extends StatelessWidget {
  final String title;
  final String verse;
  final String date;
  final String imageUrl;
  final String heroTag;

  const CompositionCard({
    super.key,
    required this.title,
    required this.verse,
    required this.date,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252D36),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: heroTag,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    const Color(0xFF171B21).withValues(alpha: 0.6),
                    const Color(0xFF171B21).withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 1,
                    color: const Color(0xFFB08D5B),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.notoSerif(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    verse,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSerif(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[300],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: GoogleFonts.manrope(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Default action could be to switch to Explore or open Picker
        // For now let's just show a snackbar or maybe we can't easily switch MainScreen state from here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Try exploring the gallery for inspiration!'),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[800]!,
              style: BorderStyle.solid,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF252D36),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_note, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                'Compose New',
                style: GoogleFonts.notoSerif(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
