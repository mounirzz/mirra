import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// The "add the Mirra widget" onboarding screen — a phone mock with a dashed
/// widget slot, the steps, and an Install CTA. Shown from the hub's Widgets
/// card (iOS can't tell us whether a widget is already placed, so this is the
/// guide state).
class WidgetsGuideScreen extends StatelessWidget {
  const WidgetsGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20, color: MirraColors.ink),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                children: [
                  Text('Widgets',
                      style: MirraType.cochin(size: 26, weight: FontWeight.w800)),
                  const SizedBox(height: 22),
                  const _PhoneMock(),
                  const SizedBox(height: 26),
                  Text(
                    'Add a widget to your\nHome Screen',
                    textAlign: TextAlign.center,
                    style: MirraType.cochin(size: 22, weight: FontWeight.w800, height: 1.15),
                  ),
                  const SizedBox(height: 18),
                  _step('1.',
                      "On your phone's Home Screen, touch and hold an empty area until the apps jiggle"),
                  const SizedBox(height: 12),
                  _step('2.', 'Tap the Edit button in the upper corner to add the widget'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: GestureDetector(
                onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: MirraColors.ink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Install widget',
                      style: MirraType.cochin(
                          size: 16, weight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(String n, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(n, style: MirraType.cochin(size: 15, weight: FontWeight.w800)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: MirraType.cochin(size: 15, weight: FontWeight.w600, height: 1.35)),
        ),
      ],
    );
  }
}

/// A stylised phone top with a dashed widget slot + faded app icons.
class _PhoneMock extends StatelessWidget {
  const _PhoneMock();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        decoration: const BoxDecoration(
          color: Color(0xFFEDEBF3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(44)),
        ),
        child: Column(
          children: [
            // Dynamic island.
            Container(
              width: 84,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFCFCBDD),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 22),
            // Dashed widget slot with an affirmation.
            CustomPaint(
              painter: _DashedRRectPainter(
                color: const Color(0xFF9E97B4),
                radius: 22,
              ),
              child: Container(
                height: 128,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(18),
                child: Text(
                  'You are stronger than\nyou think.',
                  textAlign: TextAlign.center,
                  style: MirraType.cochin(
                    size: 17,
                    weight: FontWeight.w700,
                    color: const Color(0xFF7C7690),
                    height: 1.25,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Faded app icon rows.
            for (var r = 0; r < 2; r++) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var c = 0; c < 4; c++)
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 7.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}
