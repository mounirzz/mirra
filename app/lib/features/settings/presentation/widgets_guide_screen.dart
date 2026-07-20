import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Explains how to add the Mirra widget to the Home / Lock screen, with a
/// preview of what it looks like.
class WidgetsGuideScreen extends StatelessWidget {
  const WidgetsGuideScreen({super.key});

  static const _steps = [
    'Long-press an empty spot on your Home screen.',
    'Tap the "+" in the top-left corner.',
    'Search "Mirra" and pick a size.',
    'Tap "Add Widget" — done.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Icon(Icons.close_rounded, size: 22, color: MirraColors.ink),
              ),
            ),
            Text('Widgets', style: MirraType.cochin(size: 24, weight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Add the Mirra widget to your Home or Lock screen for a daily '
              'affirmation, right where you look.',
              style: MirraType.cochin(size: 14, color: MirraColors.muted, height: 1.35),
            ),
            const SizedBox(height: 22),
            // Preview of the widget.
            Center(
              child: Container(
                width: 168,
                height: 168,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1F2438), Color(0xFF3A2B45)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SELF-WORTH',
                        style: MirraType.cochin(
                            size: 10,
                            weight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.6))),
                    const SizedBox(height: 8),
                    Text('My worth stays steady, even on hard days.',
                        style: MirraType.cochin(
                            size: 15, weight: FontWeight.w700, color: Colors.white, height: 1.25)),
                    const Spacer(),
                    Text('Mirra',
                        style: MirraType.cochin(
                            size: 11, color: Colors.white.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            for (var i = 0; i < _steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F2F8),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text('${i + 1}',
                          style: MirraType.cochin(size: 13, weight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(_steps[i],
                            style: MirraType.cochin(size: 15, weight: FontWeight.w600, height: 1.3)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F2F8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'The widget shows your daily affirmations and refreshes each time '
                'you open Mirra. Lock-screen widgets work too.',
                style: MirraType.cochin(size: 13, color: MirraColors.muted, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
