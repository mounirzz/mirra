import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../onboarding/presentation/answer_chips.dart';
import '../../onboarding/presentation/onboarding_questions.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../premium/providers/premium_provider.dart';
import '../../streak/providers/streak_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Opens the same chips as the onboarding for this question; persisting on
  /// close also reschedules notifications when time/frequency changed.
  Future<void> _editAnswer(
    BuildContext context,
    WidgetRef ref,
    OnbQuestion question,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MirraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          MirraSpace.lg,
          MirraSpace.lg,
          MirraSpace.lg,
          MediaQuery.of(sheetContext).viewInsets.bottom + MirraSpace.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.title,
              style: MirraType.cochin(size: 20, weight: FontWeight.w700),
            ),
            if (question.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                question.subtitle!,
                style: MirraType.cochin(size: 13, color: MirraColors.muted),
              ),
            ],
            const SizedBox(height: MirraSpace.md),
            AnswerChips(question: question),
          ],
        ),
      ),
    );
    await ref.read(onboardingProvider.notifier).persist();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoritesProvider);
    final answers = ref.watch(onboardingProvider);
    final streak = ref.watch(streakProvider).count;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IosStatusSpacer(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: MirraSpace.lg),
                child: Row(
                  children: [
                    MirraBackButton(onTap: () => context.pop()),
                    const SizedBox(width: 8),
                    Text(
                      'Profile',
                      style: MirraType.cochin(
                        size: 26,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MirraSpace.md),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    MirraSpace.lg,
                    0,
                    MirraSpace.lg,
                    40,
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Day streak',
                            value: '$streak',
                          ),
                        ),
                        const SizedBox(width: MirraSpace.sm),
                        Expanded(
                          child: _StatCard(
                            label: 'Favorites',
                            value: '${favs.length}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: MirraSpace.sm),
                    if (ref.watch(isPremiumProvider))
                      Container(
                        padding: const EdgeInsets.all(MirraSpace.md),
                        decoration: BoxDecoration(
                          gradient: MirraColors.gradSoft,
                          borderRadius: BorderRadius.circular(MirraRadius.lg),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              color: MirraColors.ink,
                            ),
                            const SizedBox(width: MirraSpace.sm),
                            Text(
                              'Mirra+ member',
                              style: MirraType.cochin(
                                size: 15,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => context.push('/paywall'),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(MirraSpace.md),
                          decoration: BoxDecoration(
                            gradient: MirraColors.gradSoft,
                            borderRadius: BorderRadius.circular(MirraRadius.lg),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                color: MirraColors.ink,
                              ),
                              const SizedBox(width: MirraSpace.sm),
                              Expanded(
                                child: Text(
                                  'Get Mirra+ — go unlimited',
                                  style: MirraType.cochin(
                                    size: 15,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: MirraColors.muted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: MirraSpace.lg),
                    Text(
                      'Your answers',
                      style: MirraType.cochin(
                        size: 18,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: MirraSpace.sm),
                    for (final q in kOnboardingQuestions)
                      if (answers[q.id] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: MirraSpace.sm),
                          child: GestureDetector(
                            onTap: () => _editAnswer(context, ref, q),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.all(MirraSpace.md),
                              decoration: BoxDecoration(
                                color: MirraColors.surface,
                                borderRadius: BorderRadius.circular(
                                  MirraRadius.md,
                                ),
                                border: Border.all(color: MirraColors.line),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          q.title,
                                          style: MirraType.cochin(
                                            size: 13,
                                            color: MirraColors.muted,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.edit_outlined,
                                        size: 15,
                                        color: MirraColors.muted2,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    answers[q.id]!,
                                    style: MirraType.cochin(
                                      size: 15,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MirraSpace.md),
      decoration: BoxDecoration(
        color: MirraColors.surface,
        borderRadius: BorderRadius.circular(MirraRadius.lg),
        border: Border.all(color: MirraColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: MirraType.cochin(size: 28, weight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: MirraType.cochin(size: 13, color: MirraColors.muted),
          ),
        ],
      ),
    );
  }
}
