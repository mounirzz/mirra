import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/quote.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../../home/providers/quotes_provider.dart';
import '../../premium/upsell_sheet.dart';

/// Shared category-picker interface (the Content-preferences look: a white
/// screen with a 2-column grid of card chips), used by BOTH the Mix screen and
/// Content preferences. Both bind to [selectedCategoriesProvider], so a pick in
/// one reflects in the other and shapes the feed. Free users are capped at 2.
class CategoryPickerView extends ConsumerWidget {
  const CategoryPickerView({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoriesProvider);

    void toggle(String categoryId) {
      final ok =
          ref.read(selectedCategoriesProvider.notifier).toggle(categoryId);
      if (!ok) {
        showUpsellSheet(
          context,
          title: ref.tr('Unlock all categories'),
          subtitle: ref.tr(
            'The free plan lets you pick 2 categories.\n'
            'Go unlimited with Mirra+.',
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: MirraBackButton(onTap: () => context.pop()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                title,
                style: MirraType.cochin(size: 24, weight: FontWeight.w800),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                subtitle,
                style: MirraType.cochin(
                  size: 14,
                  color: MirraColors.muted,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _TopicChip(
                    label: ref.tr('All'),
                    selected: selected.isEmpty,
                    onTap: () =>
                        ref.read(selectedCategoriesProvider.notifier).clear(),
                  ),
                  for (final category in QuoteCategory.all)
                    _TopicChip(
                      label: ref.tr(category.label),
                      selected: selected.contains(category.id),
                      onTap: () => toggle(category.id),
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

/// Card-style chip from the original Content-preferences grid.
class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? MirraColors.chip : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? MirraColors.ink : MirraColors.line,
            width: selected ? 1.6 : 1.2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: MirraType.cochin(
            size: 15,
            weight: selected ? FontWeight.w800 : FontWeight.w600,
            color: MirraColors.ink,
          ),
        ),
      ),
    );
  }
}
