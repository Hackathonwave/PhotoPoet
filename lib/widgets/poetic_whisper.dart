import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class PoeticWhisper extends StatelessWidget {
  final String text;
  final VoidCallback? onFinished;

  const PoeticWhisper({super.key, required this.text, this.onFinished});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.4),
            Colors.black.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Center(
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              text,
              textAlign: TextAlign.center,
              textStyle: GoogleFonts.notoSerif(
                fontSize: 18,
                color: Colors.white.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
                height: 1.6,
                letterSpacing: 0.5,
              ),
              speed: const Duration(milliseconds: 60),
            ),
          ],
          totalRepeatCount: 1,
          onFinished: onFinished,
          displayFullTextOnTap: true,
        ),
      ),
    );
  }
}
