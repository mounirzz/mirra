import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../shared/widgets/primary_button.dart';

/// Shown when a free-plan limit is hit (6th favorite, end of the daily
/// stack…). Payments aren't wired yet, so the CTA is an honest "coming
/// soon" placeholder.
Future<void> showUpsellSheet(
  BuildContext context, {
  String title = 'Your favorites are full',
  String subtitle =
      'The free plan keeps your 5 dearest quotes.\nGo unlimited with Mirra+.',
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: MirraColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(
        MirraSpace.lg,
        MirraSpace.lg,
        MirraSpace.lg,
        MirraSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: MirraType.serif(size: 26, height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: MirraType.cochin(
              size: 14,
              color: MirraColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: MirraSpace.lg),
          for (final perk in const [
            'Unlimited favorites',
            'All themes & backgrounds',
            'Exclusive affirmation packs',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: MirraColors.ok,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    perk,
                    style: MirraType.cochin(size: 15, weight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          const SizedBox(height: MirraSpace.md),
          PrimaryButton(
            label: 'See plans',
            gradient: true,
            onPressed: () {
              Navigator.of(sheetContext).pop();
              context.push('/paywall');
            },
          ),
        ],
      ),
    ),
  );
}
