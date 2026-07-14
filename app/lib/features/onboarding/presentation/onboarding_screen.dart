import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../providers/onboarding_provider.dart';
import 'answer_chips.dart';
import 'onboarding_questions.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _index = 0;

  OnbQuestion get _q => kOnboardingQuestions[_index];

  double get _progress => (_index + 1) / kOnboardingQuestions.length;

  void _next() async {
    // Peak-intent moment for the iOS notification prompt: the user just
    // picked when they want their reminders.
    if (_q.id == 'time') {
      await NotificationService.requestPermission();
    }
    if (_index < kOnboardingQuestions.length - 1) {
      setState(() => _index += 1);
    } else {
      await ref.read(onboardingProvider.notifier).persist();
      ref.read(onboardingCompleteProvider.notifier).state = true;
      // One skippable paywall right after onboarding — the single
      // highest-converting placement in this category.
      if (mounted) context.go('/paywall?from=onboarding');
    }
  }

  void _back() {
    if (_index > 0) {
      setState(() => _index -= 1);
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final answers = ref.watch(onboardingProvider);
    final selected = answers[_q.id];
    final isLast = _index == kOnboardingQuestions.length - 1;
    final isMulti = _q.isMulti;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: MirraSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IosStatusSpacer(height: 12),
                _Header(progress: _progress, onBack: _back),
                const SizedBox(height: MirraSpace.xl),
                Text(
                  _q.title,
                  style: MirraType.carmenSans(size: 32, height: 1.15),
                ),
                if (_q.subtitle != null) ...[
                  const SizedBox(height: MirraSpace.sm),
                  Text(
                    _q.subtitle!,
                    style: MirraType.carmenSans(
                      size: 14,
                      color: MirraColors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: MirraSpace.xl),
                Expanded(
                  child: SingleChildScrollView(
                    child: AnswerChips(
                      question: _q,
                      // Single-choice questions auto-advance on tap (no button).
                      onSingleSelect: isMulti
                          ? null
                          : () => Future.delayed(
                                const Duration(milliseconds: 220),
                                () {
                                  if (mounted) _next();
                                },
                              ),
                    ),
                  ),
                ),
                // Only multi-select questions keep a confirm button.
                if (isMulti) ...[
                  PrimaryButton(
                    label: isLast ? 'Start Mirra' : 'Continue',
                    onPressed: selected == null ? null : _next,
                    gradient: isLast,
                  ),
                  const SizedBox(height: MirraSpace.md),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.progress, required this.onBack});
  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MirraBackButton(onTap: onBack),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: MirraColors.chip,
              valueColor: const AlwaysStoppedAnimation(MirraColors.ink),
            ),
          ),
        ),
      ],
    );
  }
}
