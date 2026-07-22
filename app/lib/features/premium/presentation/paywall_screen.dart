import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/premium_provider.dart';

/// Full-screen Mirra+ paywall, framed as a 3-day free trial with a clear
/// "how it works" timeline (today → reminder → charge). Reached from every gate
/// and once, skippable, right after onboarding.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.fromOnboarding = false});

  final bool fromOnboarding;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  // The trial converts to the annual plan (best value).
  static const _plan = MirraPlan.annual;
  bool _remind = true;

  void _close() {
    if (widget.fromOnboarding) {
      // Onboarding is truly done here. Flipping this rebuilds the router
      // with initialLocation '/home', landing the user on the feed.
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

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumProvider);
    final price = premium.priceOf(_plan);

    if (premium.isPremium && !premium.purchasing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _close();
      });
    }

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
              // Close
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Brand eyebrow
                      Center(
                        child: ShaderMask(
                          shaderCallback: (b) => MirraColors.grad.createShader(b),
                          child: Text(
                            'MIRRA+',
                            style: MirraType.carmenSans(
                              size: 13,
                              color: Colors.white,
                              letterSpacing: 2.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'How your free\ntrial works',
                        textAlign: TextAlign.center,
                        style: MirraType.carmenSans(size: 32, height: 1.12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You won't be charged anything today",
                        textAlign: TextAlign.center,
                        style: MirraType.carmenSans(
                          size: 14,
                          color: MirraColors.muted,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _TrialTimeline(),
                      const SizedBox(height: 16),
                      _ReminderToggle(
                        value: _remind,
                        onChanged: (v) => setState(() => _remind = v),
                      ),
                      const SizedBox(height: 22),
                      PrimaryButton(
                        label: premium.purchasing
                            ? 'One moment…'
                            : 'Start 3-day free trial',
                        gradient: true,
                        onPressed: premium.purchasing ? null : _buy,
                      ),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          text: 'Unlimited free access for 3 days, then ',
                          style: MirraType.carmenSans(
                            size: 12,
                            color: MirraColors.ink2,
                          ),
                          children: [
                            TextSpan(
                              text: '$price/year',
                              style: MirraType.carmenSans(
                                size: 12,
                                color: MirraColors.ink,
                              ),
                            ),
                            TextSpan(
                              text: '  (3,75 €/mo)',
                              style: MirraType.carmenSans(
                                size: 12,
                                color: MirraColors.muted,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegalLink(
                            'Restore',
                            () => ref.read(premiumProvider.notifier).restore(),
                          ),
                          _dot(),
                          _LegalLink('Terms & Conditions', () {}),
                          _dot(),
                          _LegalLink('Privacy Policy', () {}),
                        ],
                      ),
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

  Widget _dot() => Padding(
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
}

// ─── Timeline card ─────────────────────────────────────────────────────────
class _TrialTimeline extends StatelessWidget {
  const _TrialTimeline();

  static const _steps = [
    (
      Icons.lock_outline_rounded,
      'Today',
      'Get full access and see your mindset start to change.',
    ),
    (
      Icons.notifications_none_rounded,
      'Day 2',
      "Get a reminder that your trial ends in 24 hours.",
    ),
    (
      Icons.workspace_premium_outlined,
      'After day 3',
      "Your free trial ends. Cancel anytime before — no charge.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB79DE8).withValues(alpha: 0.14),
            blurRadius: 30,
            spreadRadius: -6,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // gradient spine behind the icons
          Positioned(
            left: 18,
            top: 20,
            bottom: 34,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB79DE8), Color(0xFFE0AECB), Color(0xFFF0B2A3)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Column(
            children: [
              for (var i = 0; i < _steps.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == _steps.length - 1 ? 14 : 22,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: MirraColors.grad,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Icon(_steps[i].$1,
                            size: 19, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              _steps[i].$2,
                              style: MirraType.carmenSans(size: 17),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _steps[i].$3,
                              style: MirraType.carmenSans(
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
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Reminder toggle ───────────────────────────────────────────────────────
class _ReminderToggle extends StatelessWidget {
  const _ReminderToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
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
              'Reminder before trial ends',
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
              alignment:
                  value ? Alignment.centerRight : Alignment.centerLeft,
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
