import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/chip_option.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../../../core/i18n/language_provider.dart';
import '../../onboarding/presentation/onboarding_questions.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../premium/providers/premium_provider.dart';
import '../providers/notifications_provider.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  OnbQuestion _question(String id) =>
      kOnboardingQuestions.firstWhere((q) => q.id == id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(onboardingProvider);
    final timeQuestion = _question('time');
    final frequencyQuestion = _question('frequency');

    void select(String questionId, String value) {
      ref.read(onboardingProvider.notifier).answer(questionId, value);
      ref.read(onboardingProvider.notifier).persist();
    }

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
                      'Preferences',
                      style: MirraType.cochin(
                        size: 26,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MirraSpace.lg),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MirraSpace.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: MirraSpace.md,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: MirraColors.surface,
                          borderRadius: BorderRadius.circular(MirraRadius.lg),
                          border: Border.all(color: MirraColors.line),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              color: MirraColors.ink,
                            ),
                            const SizedBox(width: MirraSpace.sm),
                            Expanded(
                              child: Text(
                                'Daily reminders',
                                style: MirraType.cochin(
                                  size: 15,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              value: ref.watch(notificationsEnabledProvider),
                              activeTrackColor: MirraColors.ink,
                              onChanged: (v) => ref
                                  .read(notificationsEnabledProvider.notifier)
                                  .set(v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: MirraSpace.sm),
                      if (!ref.watch(isPremiumProvider))
                        GestureDetector(
                          onTap: () => context.push('/paywall'),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(MirraSpace.md),
                            decoration: BoxDecoration(
                              gradient: MirraColors.gradSoft,
                              borderRadius: BorderRadius.circular(
                                MirraRadius.lg,
                              ),
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
                      const SizedBox(height: MirraSpace.xl),
                      Text(
                        timeQuestion.title,
                        style: MirraType.cochin(
                          size: 16,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: MirraSpace.sm),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final opt in timeQuestion.options)
                            ChipOption(
                              label: opt,
                              selected: answers['time'] == opt,
                              onTap: () => select('time', opt),
                            ),
                        ],
                      ),
                      const SizedBox(height: MirraSpace.xl),
                      Text(
                        frequencyQuestion.title,
                        style: MirraType.cochin(
                          size: 16,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: MirraSpace.sm),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final opt in frequencyQuestion.options)
                            ChipOption(
                              label: opt,
                              selected: answers['frequency'] == opt,
                              onTap: () => select('frequency', opt),
                            ),
                        ],
                      ),
                      const SizedBox(height: MirraSpace.xl),
                      GestureDetector(
                        onTap: () => context.push('/theme'),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(MirraSpace.md),
                          decoration: BoxDecoration(
                            color: MirraColors.surface,
                            borderRadius: BorderRadius.circular(MirraRadius.lg),
                            border: Border.all(color: MirraColors.line),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.palette_outlined,
                                color: MirraColors.ink,
                              ),
                              const SizedBox(width: MirraSpace.sm),
                              Expanded(
                                child: Text(
                                  'App theme',
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
                      const SizedBox(height: MirraSpace.sm),
                      GestureDetector(
                        onTap: () => _pickLanguage(context, ref),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(MirraSpace.md),
                          decoration: BoxDecoration(
                            color: MirraColors.surface,
                            borderRadius: BorderRadius.circular(MirraRadius.lg),
                            border: Border.all(color: MirraColors.line),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.language_rounded,
                                color: MirraColors.ink,
                              ),
                              const SizedBox(width: MirraSpace.sm),
                              Expanded(
                                child: Text(
                                  'Language',
                                  style: MirraType.cochin(
                                    size: 15,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '${ref.watch(languageProvider).flag}  '
                                '${ref.watch(languageProvider).label}',
                                style: MirraType.cochin(
                                  size: 13,
                                  color: MirraColors.muted,
                                  weight: FontWeight.w700,
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
                      const SizedBox(height: MirraSpace.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: MirraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MirraSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Language',
                style: MirraType.cochin(size: 20, weight: FontWeight.w700),
              ),
              const SizedBox(height: MirraSpace.md),
              for (final language in AppLanguage.all)
                Consumer(
                  builder: (context, sheetRef, _) {
                    final selected =
                        sheetRef.watch(languageProvider).code == language.code;
                    return GestureDetector(
                      onTap: () {
                        sheetRef
                            .read(languageProvider.notifier)
                            .select(language);
                        Navigator.of(sheetContext).pop();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              language.flag,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: MirraSpace.sm),
                            Expanded(
                              child: Text(
                                language.label,
                                style: MirraType.cochin(
                                  size: 16,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: MirraColors.ink,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
