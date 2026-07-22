import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/tap_icon.dart';

/// Motivation-style commitment screen shown inside onboarding, right before
/// the "how many reminders" question: a big flame, the promise of a daily
/// routine, and the week ahead. Emotional warm-up that lifts conversion.
/// Rendered inline by the onboarding flow via [onContinue]/[onBack].
class StreakIntroScreen extends ConsumerWidget {
  const StreakIntroScreen({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  final VoidCallback onContinue;
  final VoidCallback onBack;

  // Monday-indexed weekday abbreviations (DateTime.weekday: Mon=1..Sun=7).
  static const _weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    // A rolling 7-day week starting today (today first, then the days ahead).
    final letters = [
      for (var i = 0; i < 7; i++) _weekdays[(today.weekday - 1 + i) % 7],
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: PrimaryButton(
            label: ref.tr('Continue'),
            gradient: true,
            onPressed: onContinue,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: TapIcon(
                  icon: Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  semanticLabel: 'Back',
                  onTap: onBack,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _BigFlame(count: 1),
                    const SizedBox(height: 28),
                    Text(
                      ref.tr('Stay motivated with a\nconsistent daily routine'),
                      textAlign: TextAlign.center,
                      style: MirraType.cochin(
                        size: 24,
                        weight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F2F8),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (var i = 0; i < 7; i++)
                                _DayDot(label: letters[i], done: i == 0),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            ref.tr('Build a streak, one day at a time'),
                            style: MirraType.cochin(
                              size: 13,
                              color: MirraColors.muted,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigFlame extends StatelessWidget {
  const _BigFlame({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8B6FD6), Color(0xFFE99BB0)],
            ).createShader(bounds),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 150,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              '$count',
              style: MirraType.cochin(
                size: 44,
                weight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: MirraType.cochin(
            size: 11,
            weight: FontWeight.w700,
            color: done ? MirraColors.ink : MirraColors.muted2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: done
                ? const LinearGradient(
                    colors: [Color(0xFF8B6FD6), Color(0xFFE99BB0)],
                  )
                : null,
            color: done ? null : const Color(0xFFDBD8E3),
            shape: BoxShape.circle,
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : null,
        ),
      ],
    );
  }
}
