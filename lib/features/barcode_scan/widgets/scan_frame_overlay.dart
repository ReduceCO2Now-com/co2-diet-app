import 'package:flutter/material.dart';

/// A static scanning guide overlay with corner-bracket decorations.
///
/// Renders a semi-transparent black overlay with a transparent cutout
/// centered in the screen, framed by four white corner brackets.
///
/// No external packages — pure Flutter custom painting.
///
/// [size] controls the side length of the transparent scan area (default 240).
/// Corner brackets: 3 dp stroke width, 32 dp arm length, white color.
class ScanFrameOverlay extends StatelessWidget {
  /// Creates [ScanFrameOverlay] with the given scan-area [size].
  const ScanFrameOverlay({this.size = 240, super.key});

  /// Side length of the transparent cutout / scan guide area, in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _ScanOverlayPainter(scanSize: size),
    );
  }
}

/// Custom painter that draws a dimmed surround with a transparent cutout and
/// four corner-bracket guides.
class _ScanOverlayPainter extends CustomPainter {
  const _ScanOverlayPainter({required this.scanSize});

  final double scanSize;

  static const double _cornerLength = 32;
  static const double _strokeWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final half = scanSize / 2;

    final rect = Rect.fromLTRB(
      centerX - half,
      centerY - half,
      centerX + half,
      centerY + half,
    );

    // Draw dimmed surround using a path with a transparent cutout.
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(rect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = const Color(0x99000000), // 60% black
    );

    // Draw corner brackets.
    final bracketPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final l = rect.left;
    final t = rect.top;
    final r = rect.right;
    final b = rect.bottom;

    // Top-left
    canvas
      ..drawLine(Offset(l, t + _cornerLength), Offset(l, t), bracketPaint)
      ..drawLine(Offset(l, t), Offset(l + _cornerLength, t), bracketPaint)
      // Top-right
      ..drawLine(Offset(r - _cornerLength, t), Offset(r, t), bracketPaint)
      ..drawLine(Offset(r, t), Offset(r, t + _cornerLength), bracketPaint)
      // Bottom-left
      ..drawLine(Offset(l, b - _cornerLength), Offset(l, b), bracketPaint)
      ..drawLine(Offset(l, b), Offset(l + _cornerLength, b), bracketPaint)
      // Bottom-right
      ..drawLine(Offset(r - _cornerLength, b), Offset(r, b), bracketPaint)
      ..drawLine(Offset(r, b), Offset(r, b - _cornerLength), bracketPaint);
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter oldDelegate) =>
      oldDelegate.scanSize != scanSize;
}
