// Custom bottom-nav icons (Mix grid, Theme palette+brush, Profile user).
// Hand-drawn vector reproductions of the icons provided by the user, so they
// stay crisp and follow the nav's ink colour. viewBox 24×24, rounded strokes.

import 'package:flutter/widgets.dart';

class MixGridIcon extends StatelessWidget {
  const MixGridIcon({super.key, this.size = 22, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _GridPainter(color));
}

class ThemePaletteIcon extends StatelessWidget {
  const ThemePaletteIcon({super.key, this.size = 22, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _PalettePainter(color));
}

class ProfileUserIcon extends StatelessWidget {
  const ProfileUserIcon({super.key, this.size = 22, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _UserPainter(color));
}

Paint _stroke(Color c, [double w = 1.9]) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..isAntiAlias = true;

Paint _fill(Color c) => Paint()
  ..color = c
  ..style = PaintingStyle.fill
  ..isAntiAlias = true;

void _scaled(Canvas c, Size s, void Function() draw) {
  final k = s.width / 24.0;
  c.save();
  c.scale(k, k);
  draw();
  c.restore();
}

// ── Grid: 2×2 rounded squares ────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  _GridPainter(this.color);
  final Color color;
  @override
  void paint(Canvas c, Size s) {
    _scaled(c, s, () {
      final p = _stroke(color, 2.0);
      const r = Radius.circular(2);
      for (final o in const [
        Offset(3, 3),
        Offset(13, 3),
        Offset(3, 13),
        Offset(13, 13),
      ]) {
        c.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(o.dx, o.dy, 8, 8), r),
          p,
        );
      }
    });
  }

  @override
  bool shouldRepaint(_GridPainter o) => o.color != color;
}

// ── Palette + brush ──────────────────────────────────────────────────────────
class _PalettePainter extends CustomPainter {
  _PalettePainter(this.color);
  final Color color;
  @override
  void paint(Canvas c, Size s) {
    _scaled(c, s, () {
      final stroke = _stroke(color, 1.9);
      final fill = _fill(color);

      // Palette blob (left) with a thumb-notch on the lower right.
      final palette = Path()
        ..moveTo(9.2, 3.4)
        ..cubicTo(13.2, 3.2, 16.4, 6.0, 16.4, 9.7)
        ..cubicTo(16.4, 11.5, 15.0, 12.1, 13.8, 12.3)
        ..cubicTo(12.8, 12.5, 12.2, 13.3, 12.3, 14.3)
        ..cubicTo(12.5, 16.7, 10.8, 18.7, 8.7, 18.7)
        ..cubicTo(5.0, 18.7, 2.3, 15.3, 2.5, 11.0)
        ..cubicTo(2.7, 6.7, 5.5, 3.6, 9.2, 3.4)
        ..close();
      c.drawPath(palette, stroke);

      // Three paint wells.
      c.drawCircle(const Offset(6.3, 8.0), 1.0, fill);
      c.drawCircle(const Offset(9.4, 6.7), 1.0, fill);
      c.drawCircle(const Offset(5.4, 11.4), 1.0, fill);

      // Paint dropper / tube on the right: rounded body + small base.
      final tube = RRect.fromRectAndRadius(
        const Rect.fromLTWH(16.7, 5.2, 3.2, 8.4),
        const Radius.circular(1.6),
      );
      c.drawRRect(tube, stroke);
      final base = RRect.fromRectAndRadius(
        const Rect.fromLTWH(16.9, 14.2, 2.8, 2.2),
        const Radius.circular(0.6),
      );
      c.drawRRect(base, stroke);
    });
  }

  @override
  bool shouldRepaint(_PalettePainter o) => o.color != color;
}

// ── User: head + rounded body ────────────────────────────────────────────────
class _UserPainter extends CustomPainter {
  _UserPainter(this.color);
  final Color color;
  @override
  void paint(Canvas c, Size s) {
    _scaled(c, s, () {
      final stroke = _stroke(color, 1.9);
      // Head.
      c.drawCircle(const Offset(12, 7.6), 3.7, stroke);
      // Body: rounded container with a domed shoulder top and rounded base.
      final body = Path()
        ..moveTo(4.6, 20.6)
        ..lineTo(4.6, 18.6)
        ..arcToPoint(const Offset(19.4, 18.6),
            radius: const Radius.circular(7.4), clockwise: true)
        ..lineTo(19.4, 20.6)
        ..arcToPoint(const Offset(17.4, 22.6),
            radius: const Radius.circular(2), clockwise: true)
        ..lineTo(6.6, 22.6)
        ..arcToPoint(const Offset(4.6, 20.6),
            radius: const Radius.circular(2), clockwise: true)
        ..close();
      c.drawPath(body, stroke);
    });
  }

  @override
  bool shouldRepaint(_UserPainter o) => o.color != color;
}
