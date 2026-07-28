import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/language_provider.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/premium_provider.dart';

/// Full-screen Mirra+ paywall — "How does the free trial work?" with a dated
/// 4-step timeline, a reminder toggle, and a single annual free-trial offer.
/// Hard paywall from onboarding (no close). Mirra's light palette.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.fromOnboarding = false});

  final bool fromOnboarding;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  // Single offer: the annual plan, sold as a 3-day free trial.
  static const _plan = MirraPlan.annual;
  bool _remind = true;

  void _close() {
    if (widget.fromOnboarding) {
      ref.read(onboardingCompleteProvider.notifier).state = true;
      context.go('/home');
    } else {
      context.pop();
    }
  }

  Future<void> _buy() async {
    await ref.read(premiumProvider.notifier).buy(_plan);
    if (!mounted) return;
    if (ref.read(isPremiumProvider)) _close();
  }

  static const _monthsFr = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];
  static const _monthsEn = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _fmtDate(DateTime d, String lang) {
    final m = (lang == 'fr' ? _monthsFr : _monthsEn)[d.month - 1];
    return lang == 'fr' ? '${d.day} $m' : '$m ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumProvider);
    final lang = ref.watch(languageProvider).code;

    if (premium.isPremium && !premium.purchasing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _close();
      });
    }

    final now = DateTime.now();
    final reminderDate = _fmtDate(now.add(const Duration(days: 2)), lang);
    final memberDate = _fmtDate(now.add(const Duration(days: 3)), lang);
    final price = premium.priceOf(_plan);
    final pricingLine = lang == 'fr'
        ? '3,30 €/mois, facturé annuellement à $price/an'
        : '€3.30/month, billed annually at $price/year';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDE7F6), Color(0xFFFAF7F2), Color(0xFFFBE7DE)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Close — hidden during onboarding (hard paywall: must subscribe).
              if (widget.fromOnboarding)
                const SizedBox(height: 14)
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 0, 0),
                    child: GestureDetector(
                      onTap: _close,
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close_rounded,
                            size: 24, color: MirraColors.muted),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 1),
                      Text(
                        ref.tr('How does the\nfree trial work?'),
                        textAlign: TextAlign.center,
                        style: MirraType.carmenSans(size: 30, height: 1.12),
                      ),
                      const Spacer(flex: 1),
                      _TrialSteps(
                        reminderDate: reminderDate,
                        memberDate: memberDate,
                      ),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
              // Pinned pay area.
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ReminderToggle(
                      value: _remind,
                      onChanged: (v) => setState(() => _remind = v),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: premium.purchasing
                          ? ref.tr('One moment…')
                          : ref.tr('Try for €0.00'),
                      gradient: true,
                      onPressed: premium.purchasing ? null : _buy,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pricingLine,
                      textAlign: TextAlign.center,
                      style: MirraType.carmenSans(
                        size: 12,
                        color: MirraColors.muted,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _LegalRow(),
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

// ─── Dated 4-step trial timeline ─────────────────────────────────────────────
class _TrialSteps extends ConsumerWidget {
  const _TrialSteps({required this.reminderDate, required this.memberDate});

  final String reminderDate;
  final String memberDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = <(IconData, String, String, bool)>[
      (
        Icons.check_rounded,
        ref.tr('Install the app'),
        ref.tr('Set it up for your goals'),
        true,
      ),
      (
        Icons.lock_open_rounded,
        '${ref.tr('Today')} · ${ref.tr('Trial starts')}',
        ref.tr('Completely free for your first 3 days'),
        false,
      ),
      (
        Icons.notifications_none_rounded,
        '$reminderDate · ${ref.tr('Reminder')}',
        ref.tr('When your trial is about to end'),
        false,
      ),
      (
        Icons.workspace_premium_outlined,
        '$memberDate · ${ref.tr('Become a member')}',
        ref.tr('Your trial ends unless you cancel'),
        false,
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 16,
            bottom: 30,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFB79DE8),
                    Color(0xFFE0AECB),
                    Color(0xFFF0B2A3),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Column(
            children: [
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == steps.length - 1 ? 8 : 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: MirraColors.grad,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        alignment: Alignment.center,
                        child:
                            Icon(steps[i].$1, size: 17, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              steps[i].$2,
                              style: MirraType.cochin(
                                size: 17,
                                weight: FontWeight.w800,
                              ).copyWith(
                                decoration: steps[i].$4
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: steps[i].$4
                                    ? MirraColors.muted
                                    : MirraColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              steps[i].$3,
                              style: MirraType.carmenSans(
                                size: 13,
                                color: MirraColors.muted,
                                height: 1.3,
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
        ],
      ),
    );
  }
}

// ─── Reminder toggle ─────────────────────────────────────────────────────────
class _ReminderToggle extends ConsumerWidget {
  const _ReminderToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              ref.tr('Reminder before trial ends'),
              style: MirraType.carmenSans(size: 14),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient: value ? MirraColors.grad : null,
                color: value ? null : MirraColors.line2,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
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

// ─── Legal row ───────────────────────────────────────────────────────────────
class _LegalRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget dot() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: MirraColors.muted2,
              shape: BoxShape.circle,
            ),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegalLink(
          ref.tr('Restore'),
          () => ref.read(premiumProvider.notifier).restore(),
        ),
        dot(),
        _LegalLink(ref.tr('Terms'), () {}),
        dot(),
        _LegalLink(ref.tr('Privacy'), () {}),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: MirraType.carmenSans(size: 12, color: MirraColors.muted),
      ),
    );
  }
}
