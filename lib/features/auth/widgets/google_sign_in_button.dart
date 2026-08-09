import 'package:flutter/material.dart';

/// Hand-rolled "Sign in with Google" button following Google's brand
/// guidelines: white background, grey border, Google's colored "G" glyph.
///
/// A pixel-exact multi-color Google "G" logo asset is out of scope for a
/// hand-rolled widget (per this plan's action spec) -- `Icons.g_mobiledata`
/// does not visually resemble Google's logo, so a small colored-circle
/// approximation (4 quadrant colors matching Google's brand palette) is
/// used instead as the documented, deliberate choice.
///
/// Deliberately NOT restyled to the app's own primary/secondary color
/// tokens (07-RESEARCH.md's locked brand-compliance decision) -- fixed
/// white/grey-border regardless of the active theme (light or dark).
///
/// A dumb, reusable widget -- takes no dependency on `AuthNotifier`
/// directly; the calling screen (`AuthScreen`) wires [onPressed].
class GoogleSignInButton extends StatelessWidget {
  /// Creates a [GoogleSignInButton].
  const GoogleSignInButton({required this.onPressed, super.key});

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F1F1F),
          side: const BorderSide(color: Color(0xFFDADCE0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GoogleGlyph(),
            SizedBox(width: 8),
            Text(
              'Sign in with Google',
              style: TextStyle(
                color: Color(0xFF1F1F1F),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A colored-circle approximation of Google's four-color "G" glyph
/// (blue/red/yellow/green quadrants) -- see [GoogleSignInButton]'s doc
/// comment for why a pixel-exact logo asset is out of scope here.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGlyphPainter()),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  const _GoogleGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const colors = [
      Color(0xFF4285F4), // blue
      Color(0xFF34A853), // green
      Color(0xFFFBBC05), // yellow
      Color(0xFFEA4335), // red
    ];

    for (var i = 0; i < 4; i++) {
      final paint = Paint()..color = colors[i];
      canvas.drawArc(
        rect,
        (i * 90) * (3.14159265 / 180),
        90 * (3.14159265 / 180),
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
