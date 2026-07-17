import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/quote.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../../home/providers/quotes_provider.dart';

class MixScreen extends ConsumerWidget {
  const MixScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoriesProvider);

    void toggle(String categoryId) {
      final next = {...selected};
      if (!next.add(categoryId)) next.remove(categoryId);
      ref.read(selectedCategoriesProvider.notifier).state = next;
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
                      ref.tr('Mix'),
                      style: MirraType.cochin(
                        size: 26,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: MirraSpace.lg),
                child: Text(
                  ref.tr('Pick one or more categories to shape your feed.'),
                  style: MirraType.cochin(size: 14, color: MirraColors.muted),
                ),
              ),
              const SizedBox(height: MirraSpace.md),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MirraSpace.lg,
                    vertical: 4,
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MixChip(
                        label: ref.tr('All'),
                        selected: selected.isEmpty,
                        onTap: () =>
                            ref
                                    .read(selectedCategoriesProvider.notifier)
                                    .state =
                                {},
                      ),
                      for (final category in QuoteCategory.all)
                        _MixChip(
                          label: ref.tr(category.label),
                          selected: selected.contains(category.id),
                          onTap: () => toggle(category.id),
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
}

class _MixChip extends StatelessWidget {
  const _MixChip({
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
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? MirraColors.ink : MirraColors.chip,
          borderRadius: BorderRadius.circular(MirraRadius.pill),
          border: Border.all(
            color: selected ? MirraColors.ink : MirraColors.chipLine,
          ),
        ),
        child: Text(
          label,
          style: MirraType.cochin(
            size: 14,
            weight: FontWeight.w700,
            color: selected ? Colors.white : MirraColors.ink,
          ),
        ),
      ),
    );
  }
}
