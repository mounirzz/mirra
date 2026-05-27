import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/chip_option.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/onboarding_provider.dart';
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
    if (_index < kOnboardingQuestions.length - 1) {
      setState(() => _index += 1);
    } else {
      await ref.read(onboardingProvider.notifier).persist();
      ref.read(onboardingCompleteProvider.notifier).state = true;
      if (mounted) context.go('/home');
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

    return Scaffold(
      backgroundColor: MirraColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MirraSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IosStatusSpacer(height: 12),
              _Header(progress: _progress, onBack: _back),
              const SizedBox(height: MirraSpace.xl),
              Text(_q.title, style: MirraType.title.copyWith(height: 1.15)),
              if (_q.subtitle != null) ...[
                const SizedBox(height: MirraSpace.sm),
                Text(_q.subtitle!,
                    style: MirraType.ui(size: 14, color: MirraColors.muted)),
              ],
              const SizedBox(height: MirraSpace.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final opt in _q.options)
                        ChipOption(
                          label: opt,
                          selected: selected == opt,
                          onTap: () => ref
                              .read(onboardingProvider.notifier)
                              .answer(_q.id, opt),
                        ),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                label: isLast ? 'Start Mirra' : 'Continue',
                onPressed: selected == null ? null : _next,
                gradient: isLast,
              ),
              const SizedBox(height: MirraSpace.md),
            ],
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
        GestureDetector(
          onTap: onBack,
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: MirraColors.ink),
          ),
        ),
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
