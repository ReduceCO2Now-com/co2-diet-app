import 'package:flutter/material.dart';

/// Hand-rolled "Sign in with Apple" button following Apple's Human
/// Interface Guidelines: full-width, black background, white glyph/text,
/// rounded corners.
///
/// Deliberately NOT restyled to the app's own primary/secondary color
/// tokens (07-RESEARCH.md's locked brand-compliance decision) -- Apple
/// explicitly rejects non-compliant "Sign in with Apple" buttons during
/// App Store review, so this widget's colors are fixed regardless of the
/// active theme (light or dark).
///
/// A dumb, reusable widget -- takes no dependency on `AuthNotifier`
/// directly; the calling screen (`AuthScreen`) wires [onPressed].
class AppleSignInButton extends StatelessWidget {
  /// Creates an [AppleSignInButton].
  const AppleSignInButton({required this.onPressed, super.key});

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // `Icons.apple` from the Material icon set is used as the
            // Apple glyph -- visually acceptable for this purpose; a
            // bundled brand asset is out of scope for a hand-rolled
            // widget (per this plan's action spec).
            Icon(Icons.apple, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Sign in with Apple',
              style: TextStyle(
                color: Colors.white,
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
