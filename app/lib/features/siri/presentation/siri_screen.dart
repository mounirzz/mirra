import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../voice/voice_service.dart';

/// One Siri "affirmation type" the MotivateMeIntent understands.
class _SiriType {
  const _SiriType(this.label, this.icon, this.phrase, this.sample);
  final String label;
  final IconData icon;
  final String phrase; // what to say to Siri
  final String sample; // spoken preview when tapped
}

const _types = <_SiriType>[
  _SiriType('Surprise me', Icons.auto_awesome_rounded, 'Hey Siri, motivate me',
      'You are exactly where you need to be.'),
  _SiriType('Morning', Icons.wb_twilight_rounded,
      'Hey Siri, give me a morning affirmation',
      'Today is full of fresh possibility.'),
  _SiriType('Positive energy', Icons.wb_sunny_outlined,
      'Hey Siri, give me a positive affirmation',
      'Good things are quietly making their way to you.'),
  _SiriType('Love', Icons.favorite_border_rounded,
      'Hey Siri, give me a love affirmation',
      'You are worthy of deep, gentle love.'),
  _SiriType('Work', Icons.work_outline_rounded,
      'Hey Siri, give me a work affirmation',
      'You bring calm, steady focus to everything you do.'),
  _SiriType('Sports', Icons.sports_basketball_outlined,
      'Hey Siri, give me a sports affirmation',
      'Your body is strong and ready for this.'),
  _SiriType('Workout', Icons.fitness_center_rounded,
      'Hey Siri, give me a workout affirmation',
      'Every rep is making you stronger.'),
];

/// "Add Siri Shortcuts" — explains the wake phrase and lets you preview each
/// type in your chosen voice, or jump to the Shortcuts app to pin one.
class SiriScreen extends ConsumerWidget {
  const SiriScreen({super.key});

  Future<void> _preview(WidgetRef ref, String text) =>
      ref.read(voiceServiceProvider).speak(text);

  Future<void> _openShortcuts(BuildContext context, String phrase) async {
    final uri = Uri.parse('shortcuts://');
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(opened ? 'Say: “$phrase”' : 'Just say: “$phrase”'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: GestureDetector(
                onTap: () =>
                    context.canPop() ? context.pop() : context.go('/home'),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: MirraColors.ink),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text('Siri',
                  style: MirraType.cochin(size: 26, weight: FontWeight.w800)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                'Ask Siri to read your affirmations out loud — in the voice you picked.',
                style: MirraType.cochin(
                    size: 14, color: MirraColors.muted, height: 1.35),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                children: [
                  _HeroCard(onTap: () => _preview(ref, _types.first.sample)),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                    child: Text(
                      'ADD SIRI SHORTCUTS',
                      style: MirraType.carmenSans(
                          size: 11,
                          color: MirraColors.muted,
                          letterSpacing: 0.6),
                    ),
                  ),
                  for (final t in _types)
                    _TypeRow(
                      type: t,
                      onPreview: () => _preview(ref, t.sample),
                      onAdd: () => _openShortcuts(context, t.phrase),
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          gradient: MirraColors.gradSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: MirraColors.accentA, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('“Hey Siri, motivate me”',
                      style:
                          MirraType.cochin(size: 17, weight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text('Tap to hear it in your voice.',
                      style: MirraType.cochin(
                          size: 13, color: MirraColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.volume_up_rounded,
                color: MirraColors.ink, size: 22),
          ],
        ),
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow(
      {required this.type, required this.onPreview, required this.onAdd});
  final _SiriType type;
  final VoidCallback onPreview;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onPreview,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F2F8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(type.icon, size: 20, color: MirraColors.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(type.label,
                    style: MirraType.cochin(size: 15, weight: FontWeight.w700)),
              ),
              GestureDetector(
                onTap: onAdd,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: MirraColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
