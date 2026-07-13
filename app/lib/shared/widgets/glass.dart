// "Liquid glass" surface — a Flutter port of the macOS liquid-glass effect
// (lucasromerodb/liquid-glass-effect-macos). Layers, matching the CSS:
//   • effect  — light backdrop blur (the CSS uses blur(3px) + an SVG
//               displacement warp; Flutter's BackdropFilter can't run the
//               feDisplacementMap refraction, so we approximate with a light
//               blur only — see note below).
//   • tint    — rgba(255,255,255,0.25) flat wash.
//   • shine   — inset highlights on the top-left and bottom-right edges
//               (CSS inset box-shadows), drawn as a gradient rim stroke.
//   • wrapper — outer drop shadow 0 6px 6px /  0 0 20px black.
//
// NOTE: the true liquid *refraction* (url(#glass-distortion)) needs a fragment
// shader reading the backdrop, which stock BackdropFilter doesn't support.
// This gets the clear-glass + shine + tint look; add a shader package later
// for the warping if desired.

import 'dart:ui';

import 'package:flutter/material.dart';

class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = 999,
    this.blur = 6,
    this.padding,
    this.width,
    this.height,
    this.tint = 0.22,
  });

  final Widget child;
  final double radius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double tint;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return DecoratedBox(
      // wrapper: outer drop shadow
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 6,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Stack(
          children: [
            // effect: blurred backdrop
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: const ColoredBox(color: Color(0x00000000)),
              ),
            ),
            // tint: flat white wash
            Positioned.fill(
              child: ColoredBox(color: Colors.white.withValues(alpha: tint)),
            ),
            // shine: bright rim on top-left + bottom-right
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ShinePainter(radius)),
              ),
            ),
            // content (defines the surface size)
            Container(
              width: width,
              height: height,
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShinePainter extends CustomPainter {
  _ShinePainter(this.radius);
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(
      rect.deflate(0.9),
      Radius.circular(radius),
    );
    // Bright at top-left and bottom-right, transparent through the middle —
    // mirrors the CSS dual inset box-shadows.
    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x8CFFFFFF), // ~0.55 white
        Color(0x00FFFFFF),
        Color(0x73FFFFFF), // ~0.45 white
      ],
      stops: [0.0, 0.5, 1.0],
    ).createShader(rect);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = shader
      ..isAntiAlias = true;
    canvas.drawRRect(rr, paint);
  }

  @override
  bool shouldRepaint(_ShinePainter old) => old.radius != radius;
}
