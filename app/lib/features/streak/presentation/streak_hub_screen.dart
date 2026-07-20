import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/share_anchor.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../../../core/i18n/strings.dart';
import '../providers/streak_provider.dart';

/// Hub opened by tapping the 🔥 badge on the feed — modeled on Motivation's
/// menu: streak card with the week ahead, quick links, then app
/// customization shortcuts.
class StreakHubScreen extends ConsumerWidget {
  const StreakHubScreen({super.key});

  static const _dayLetters = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider).count;
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Row(
                children: [
                  TapIcon(
                    icon: Icons.close_rounded,
                    semanticLabel: 'Close',
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/preferences'),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        ref.tr('Settings'),
                        style: MirraType.cochin(
                          size: 15,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                children: [
                  Text(
                    'Mirra',
                    style: MirraType.cochin(size: 26, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  // ── Streak card ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F2F8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _FlameWithCount(count: streak),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ref.tr('Your streak'),
                                      style: MirraType.cochin(
                                        size: 16,
                                        weight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Builder(
                                    builder: (shareCtx) => TapIcon(
                                      icon: Icons.ios_share_rounded,
                                      size: 18,
                                      color: MirraColors.muted,
                                      semanticLabel: 'Share streak',
                                      onTap: () => shareAnchored(
                                        shareCtx,
                                        '🔥 $streak day streak on Mirra — '
                                        'one affirmation at a time.',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  for (var i = 0; i < 7; i++)
                                    _DayDot(
                                      label: _dayLetters[(today.weekday -
                                              1 +
                                              i) %
                                          7],
                                      done: i == 0,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ── Quick links ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _QuickLink(
                          label: ref.tr('My favorites'),
                          icon: Icons.favorite_border_rounded,
                          onTap: () => context.push('/favorites'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickLink(
                          label: ref.tr('My themes'),
                          icon: Icons.bookmark_border_rounded,
                          onTap: () => context.push('/theme'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickLink(
                          label: ref.tr('My own quotes'),
                          icon: Icons.edit_note_rounded,
                          onTap: () => context.push('/my-quotes'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickLink(
                          label: ref.tr('My profile'),
                          icon: Icons.person_outline_rounded,
                          onTap: () => context.push('/profile'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  // ── Customize the app ─────────────────────────────────
                  Text(
                    ref.tr('Customize the app'),
                    style: MirraType.cochin(size: 20, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CustomizeCard(
                          label: ref.tr('Topics you follow'),
                          emoji: '🗂️',
                          onTap: () => context.push('/topics'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CustomizeCard(
                          label: ref.tr('Reminders'),
                          emoji: '🔔',
                          onTap: () => context.push('/preferences/reminders'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CustomizeCard(
                          label: ref.tr('Themes'),
                          emoji: '🎨',
                          onTap: () => context.push('/theme'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CustomizeCard(
                          label: ref.tr('App icon'),
                          emoji: '📱',
                          onTap: () => context.push('/app-icon'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _CustomizeCard(
                          label: ref.tr('Widgets'),
                          emoji: '🧩',
                          onTap: () => context.push('/widgets'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()),
                    ],
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

/// Gradient flame with the day count in a white bubble, like the reference.
class _FlameWithCount extends StatelessWidget {
  const _FlameWithCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB79DE8), Color(0xFFE86A5E)],
            ).createShader(bounds),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 74,
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: 6,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: MirraType.cochin(size: 16, weight: FontWeight.w800),
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
        const SizedBox(height: 4),
        done
            ? Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB79DE8), Color(0xFFE86A5E)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              )
            : Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBD8E3),
                  shape: BoxShape.circle,
                ),
              ),
      ],
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F2F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: MirraType.cochin(size: 14, weight: FontWeight.w700),
              ),
            ),
            Icon(icon, size: 20, color: MirraColors.ink),
          ],
        ),
      ),
    );
  }
}

class _CustomizeCard extends StatelessWidget {
  const _CustomizeCard({
    required this.label,
    required this.emoji,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F2F8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: MirraType.cochin(size: 14, weight: FontWeight.w700),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(emoji, style: const TextStyle(fontSize: 40)),
            ),
          ],
        ),
      ),
    );
  }
}
