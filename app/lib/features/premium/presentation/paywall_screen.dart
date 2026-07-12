import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/palette_provider.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../providers/premium_provider.dart';

/// Full-screen Mirra+ paywall. Reached from every gate (daily stack, 6th
/// favorite, locked theme, 4th own affirmation) and once, skippable, right
/// after onboarding — the highest-converting placement of this category.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.fromOnboarding = false});

  final bool fromOnboarding;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  MirraPlan _selected = MirraPlan.monthly;

  void _close() {
    if (widget.fromOnboarding) {
      context.go('/home');
    } else {
      context.pop();
    }
  }

  Future<void> _buy() async {
    await ref.read(premiumProvider.notifier).buy(_selected);
    if (!mounted) return;
    if (ref.read(isPremiumProvider)) _close();
  }

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumProvider);
    final palette = ref.watch(themePaletteProvider).paletteOrFallback;

    // Already premium (e.g. after restore): nothing to sell.
    if (premium.isPremium && !premium.purchasing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _close();
      });
    }

    return Scaffold(
      backgroundColor: MirraColors.bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              palette.accentA.withValues(alpha: 0.25),
              MirraColors.bg,
              palette.accentB.withValues(alpha: 0.28),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TapIcon(
                  icon: Icons.close_rounded,
                  semanticLabel: 'Close',
                  color: MirraColors.muted,
                  onTap: _close,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MirraSpace.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Mirra+',
                        textAlign: TextAlign.center,
                        style: MirraType.carmenSans(size: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Every affirmation.\nEvery day. Yours.',
                        textAlign: TextAlign.center,
                        style: MirraType.serif(size: 34, height: 1.15),
                      ),
                      const SizedBox(height: MirraSpace.lg),
                      for (final perk in const [
                        (
                          'All affirmations, no daily limit',
                          Icons.all_inclusive_rounded,
                        ),
                        ('Unlimited favorites', Icons.favorite_rounded),
                        ('Every theme & background', Icons.palette_rounded),
                        ('Unlimited personal affirmations', Icons.edit_rounded),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(perk.$2, size: 20, color: MirraColors.ink),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  perk.$1,
                                  style: MirraType.cochin(
                                    size: 15,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: MirraSpace.md),
                      _PlanCard(
                        plan: MirraPlan.annual,
                        price: premium.priceOf(MirraPlan.annual),
                        selected: _selected == MirraPlan.annual,
                        onTap: () =>
                            setState(() => _selected = MirraPlan.annual),
                      ),
                      const SizedBox(height: MirraSpace.sm),
                      _PlanCard(
                        plan: MirraPlan.monthly,
                        price: premium.priceOf(MirraPlan.monthly),
                        selected: _selected == MirraPlan.monthly,
                        badge: 'BEST VALUE',
                        onTap: () =>
                            setState(() => _selected = MirraPlan.monthly),
                      ),
                      const SizedBox(height: MirraSpace.sm),
                      _PlanCard(
                        plan: MirraPlan.weekly,
                        price: premium.priceOf(MirraPlan.weekly),
                        selected: _selected == MirraPlan.weekly,
                        onTap: () =>
                            setState(() => _selected = MirraPlan.weekly),
                      ),
                      const SizedBox(height: MirraSpace.lg),
                      PrimaryButton(
                        label: premium.purchasing ? 'One moment…' : 'Continue',
                        gradient: true,
                        onPressed: premium.purchasing ? null : _buy,
                      ),
                      const SizedBox(height: MirraSpace.sm),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              ref.read(premiumProvider.notifier).restore(),
                          child: Text(
                            'Restore purchases',
                            style: MirraType.cochin(
                              size: 13,
                              color: MirraColors.muted,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Auto-renewable. Cancel anytime in Settings.',
                        textAlign: TextAlign.center,
                        style: MirraType.cochin(
                          size: 11,
                          color: MirraColors.muted2,
                        ),
                      ),
                      const SizedBox(height: MirraSpace.lg),
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
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.price,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final MirraPlan plan;
  final String price;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(MirraSpace.md),
        decoration: BoxDecoration(
          color: MirraColors.surface.withValues(alpha: selected ? 1 : 0.75),
          borderRadius: BorderRadius.circular(MirraRadius.lg),
          border: Border.all(
            color: selected ? MirraColors.ink : MirraColors.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? MirraColors.ink : MirraColors.muted2,
              size: 22,
            ),
            const SizedBox(width: MirraSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.label,
                        style: MirraType.cochin(
                          size: 16,
                          weight: FontWeight.w700,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: MirraColors.ink,
                            borderRadius: BorderRadius.circular(
                              MirraRadius.pill,
                            ),
                          ),
                          child: Text(
                            badge!,
                            style: MirraType.carmenSans(
                              size: 9,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: MirraColors.danger,
                          borderRadius: BorderRadius.circular(MirraRadius.pill),
                        ),
                        child: Text(
                          plan.discountBadge,
                          style: MirraType.carmenSans(
                            size: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.period,
                    style: MirraType.cochin(size: 12, color: MirraColors.muted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.originalPrice,
                  style: MirraType.cochin(
                    size: 12,
                    color: MirraColors.muted2,
                  ).copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: MirraColors.muted2,
                  ),
                ),
                Text(
                  price,
                  style: MirraType.cochin(size: 17, weight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
