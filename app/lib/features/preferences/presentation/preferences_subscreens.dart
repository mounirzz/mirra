import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/i18n/language_provider.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/storage/hive_boxes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/quote.dart';
import '../../../shared/widgets/chip_option.dart';
import '../../mix/presentation/category_picker.dart';
import '../../onboarding/presentation/onboarding_questions.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../premium/providers/premium_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/settings_providers.dart';
import 'settings_widgets.dart';

// ─── Manage subscription ────────────────────────────────────────────────

class ManageSubscriptionScreen extends ConsumerWidget {
  const ManageSubscriptionScreen({super.key});

  static const _renewalDays = {'Weekly': 7, 'Monthly': 30, 'Annual': 365};

  String _fmt(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    if (!isPremium) {
      return const _UpgradePitch();
    }

    final prefs = MirraBoxes.current;
    final plan = prefs.premiumPlan ?? 'Mirra+';
    final started =
        DateTime.tryParse(prefs.premiumSince ?? '') ?? DateTime.now();
    final renewal = started.add(Duration(days: _renewalDays[plan] ?? 30));

    return SettingsSubScreen(
      title: ref.tr('Manage subscription'),
      bottomBar: SettingsCta(
        label: ref.tr('Cancel or change subscription'),
        onTap: () => launchUrl(
          Uri.parse('https://apps.apple.com/account/subscriptions'),
          mode: LaunchMode.externalApplication,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ref.tr('You are subscribed to:'),
              style: MirraType.cochin(size: 15, color: MirraColors.muted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: MirraColors.ink,
                ),
                const SizedBox(width: 10),
                Text(
                  'Mirra+ $plan',
                  style: MirraType.cochin(size: 17, weight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _TimelineRow(
              filled: true,
              label: ref.tr('Started:'),
              value: _fmt(started),
              connect: true,
            ),
            _TimelineRow(
              filled: false,
              label: ref.tr('Renewal:'),
              value: _fmt(renewal),
            ),
            const SizedBox(height: 12),
            Text(
              'You can cancel or change your subscription plan. If you '
              'cancel, you can keep using the subscription until the next '
              'billing date.',
              style: MirraType.cochin(
                size: 12,
                color: MirraColors.muted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Conversion-focused pitch shown to free users who open Manage
/// subscription: emotional hook, benefits, social proof, 3-day free trial
/// framing on the best-value plan, and a strong CTA into the paywall.
class _UpgradePitch extends ConsumerWidget {
  const _UpgradePitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumProvider);
    final annual = premium.priceOf(MirraPlan.annual);
    final perMonth = premium.priceOf(MirraPlan.monthly);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => context.push('/paywall'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB79DE8), Color(0xFFE86A5E)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB79DE8).withValues(alpha: 0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    ref.tr('Start 3-day free trial'),
                    style: MirraType.carmenSans(size: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Then $annual/year ($perMonth/mo). Cancel anytime.',
                style: MirraType.cochin(size: 11, color: MirraColors.muted2),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: GestureDetector(
                onTap: () => context.pop(),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: MirraColors.ink,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  // Hero
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFB79DE8), Color(0xFFE86A5E)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ref.tr('Become your\nbest self with Mirra+'),
                          textAlign: TextAlign.center,
                          style: MirraType.serif(size: 30, height: 1.15),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          ref.tr('Join thousands reshaping their mindset, one affirmation at a time.'),
                          textAlign: TextAlign.center,
                          style: MirraType.cochin(
                            size: 14,
                            color: MirraColors.muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Rating strip (social proof)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F2F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Proof(value: '4.9★', label: 'App Store'),
                        _Proof(value: '50k+', label: 'happy users'),
                        _Proof(value: '1M+', label: 'affirmations'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Benefits
                  for (final b in [
                    (
                      Icons.all_inclusive_rounded,
                      ref.tr('Unlimited affirmations'),
                      ref.tr('No daily limit — read as much as you need.'),
                    ),
                    (
                      Icons.palette_rounded,
                      ref.tr('Every theme & background'),
                      ref.tr('Make Mirra truly yours, including your own photos.'),
                    ),
                    (
                      Icons.favorite_rounded,
                      ref.tr('Unlimited favorites'),
                      ref.tr('Keep every quote that speaks to you.'),
                    ),
                    (
                      Icons.edit_rounded,
                      ref.tr('Unlimited personal affirmations'),
                      ref.tr('Write the words only you can write.'),
                    ),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0E9FA),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(b.$1, size: 20, color: MirraColors.ink),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.$2,
                                  style: MirraType.cochin(
                                    size: 15,
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  b.$3,
                                  style: MirraType.cochin(
                                    size: 13,
                                    color: MirraColors.muted,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Testimonial
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F2F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '“Mirra is the first app that actually changed how '
                          'I talk to myself. I open it every morning.”',
                          style: MirraType.serif(size: 16, height: 1.35),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '★★★★★  — Léa, Mirra+ member',
                          style: MirraType.cochin(
                            size: 12,
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
          ],
        ),
      ),
    );
  }
}

class _Proof extends StatelessWidget {
  const _Proof({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: MirraType.cochin(size: 18, weight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: MirraType.cochin(size: 11, color: MirraColors.muted),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.filled,
    required this.label,
    required this.value,
    this.connect = false,
  });

  final bool filled;
  final String label;
  final String value;
  final bool connect;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: filled ? MirraColors.ink : const Color(0xFFB8B4C2),
                  shape: BoxShape.circle,
                ),
                child: filled
                    ? const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      )
                    : Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B6F7E),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
              ),
              if (connect)
                Container(width: 2, height: 22, color: const Color(0xFFD5D2DD)),
            ],
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: MirraType.cochin(size: 14, weight: FontWeight.w700),
            ),
          ),
          Text(value, style: MirraType.cochin(size: 14)),
        ],
      ),
    );
  }
}

// ─── Content preferences (affirmation topics) ───────────────────────────

class ContentPrefsScreen extends ConsumerWidget {
  const ContentPrefsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Same interface and backend selection as the Mix screen.
    return CategoryPickerView(
      title: ref.tr('Content preferences'),
      subtitle: ref.tr('Pick one or more categories to shape your feed.'),
    );
  }
}

// ─── Gender identity ────────────────────────────────────────────────────

class GenderScreen extends ConsumerWidget {
  const GenderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = kOnboardingQuestions.firstWhere((q) => q.id == 'gender');
    final selected = ref.watch(onboardingProvider)['gender'];

    return SettingsSubScreen(
      title: ref.tr('Gender identity'),
      subtitle: ref.tr('Your gender identity is used to personalize your content'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          for (final opt in question.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () async {
                  ref.read(onboardingProvider.notifier).answer('gender', opt);
                  await ref.read(onboardingProvider.notifier).persist();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == opt
                        ? const Color(0xFFF4F2F8)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected == opt
                          ? MirraColors.ink
                          : const Color(0xFFE0DDE8),
                      width: selected == opt ? 1.6 : 1,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: MirraType.cochin(size: 15, weight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Muted content ──────────────────────────────────────────────────────

class MutedContentScreen extends ConsumerWidget {
  const MutedContentScreen({super.key});

  Future<void> _addMuted(BuildContext context, WidgetRef ref) async {
    final muted = ref.read(mutedCategoriesProvider);
    final available = QuoteCategory.all
        .where((c) => c.id != 'personal' && !muted.contains(c.id))
        .toList();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ref.tr('Mute a topic'),
                style: MirraType.cochin(size: 20, weight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final c in available)
                    ChipOption(
                      label: c.label,
                      selected: false,
                      onTap: () {
                        ref.read(mutedCategoriesProvider.notifier).mute(c.id);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = ref.watch(mutedCategoriesProvider);

    return SettingsSubScreen(
      title: ref.tr('Muted content'),
      bottomBar: SettingsCta(
        label: ref.tr('Add muted content'),
        onTap: () => _addMuted(context, ref),
      ),
      child: muted.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔇', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 20),
                    Text(
                      ref.tr('You haven’t muted\nanything yet'),
                      textAlign: TextAlign.center,
                      style: MirraType.cochin(
                        size: 20,
                        weight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      ref.tr('When you mute a topic, you won’t see it in your feed or notifications'),
                      textAlign: TextAlign.center,
                      style: MirraType.cochin(
                        size: 14,
                        color: MirraColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                for (final id in muted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F2F8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              QuoteCategory.byId(id).label,
                              style: MirraType.cochin(
                                size: 15,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref
                                .read(mutedCategoriesProvider.notifier)
                                .unmute(id),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                ref.tr('Unmute'),
                                style: MirraType.cochin(
                                  size: 13,
                                  color: MirraColors.muted,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

// ─── Language ───────────────────────────────────────────────────────────

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageProvider);

    return SettingsSubScreen(
      title: ref.tr('Language'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          for (final language in AppLanguage.all)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () =>
                    ref.read(languageProvider.notifier).select(language),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F2F8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(language.flag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          language.label,
                          style: MirraType.cochin(
                            size: 15,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        current.code == language.code
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_off_rounded,
                        size: 20,
                        color: current.code == language.code
                            ? MirraColors.ink
                            : MirraColors.muted2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Name ───────────────────────────────────────────────────────────────

class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(displayNameProvider) ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSubScreen(
      title: ref.tr('Name'),
      subtitle: ref.tr('Your name is used to personalize your content'),
      bottomBar: SettingsCta(
        label: ref.tr('Save'),
        onTap: () async {
          await ref.read(displayNameProvider.notifier).set(_controller.text);
          if (context.mounted) context.pop();
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: MirraType.cochin(size: 16, weight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: ref.tr('Your first name'),
            hintStyle: MirraType.cochin(size: 16, color: MirraColors.muted2),
            filled: true,
            fillColor: const Color(0xFFF4F2F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sound ──────────────────────────────────────────────────────────────

class SoundScreen extends ConsumerWidget {
  const SoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(themeVolumeProvider);

    return SettingsSubScreen(
      title: ref.tr('Sound'),
      subtitle: ref.tr('Set the volume you’d like'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              ref.tr('THEME SOUND'),
              style: MirraType.carmenSans(
                size: 11,
                color: MirraColors.muted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFBFC4DE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: MirraColors.ink,
                  inactiveTrackColor: Colors.white,
                  thumbColor: Colors.white,
                  trackHeight: 3,
                ),
                child: Slider(
                  value: volume,
                  onChanged: (v) =>
                      ref.read(themeVolumeProvider.notifier).set(v),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reminders (moved from the old Preferences body) ────────────────────

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

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

    return SettingsSubScreen(
      title: ref.tr('Reminders'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F2F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ref.tr('Daily reminders'),
                    style: MirraType.cochin(size: 15, weight: FontWeight.w700),
                  ),
                ),
                Switch.adaptive(
                  value: ref.watch(notificationsEnabledProvider),
                  activeTrackColor: MirraColors.ink,
                  onChanged: (v) =>
                      ref.read(notificationsEnabledProvider.notifier).set(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            timeQuestion.title,
            style: MirraType.cochin(size: 16, weight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 22),
          Text(
            frequencyQuestion.title,
            style: MirraType.cochin(size: 16, weight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
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
        ],
      ),
    );
  }
}
