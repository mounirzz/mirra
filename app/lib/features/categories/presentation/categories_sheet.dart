import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/quote.dart';
import '../../home/providers/quotes_provider.dart';

Future<void> showCategoriesSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CategoriesSheet(),
  );
}

class _CategoriesSheet extends ConsumerWidget {
  const _CategoriesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: MirraColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MirraColors.chipLine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: MirraSpace.lg, vertical: 6),
                child: Row(
                  children: [
                    Text('Mix', style: MirraType.title.copyWith(fontSize: 24)),
                    const Spacer(),
                    if (selected != null)
                      GestureDetector(
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).state =
                              null;
                          Navigator.pop(context);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text('Clear',
                            style: MirraType.ui(
                              size: 13,
                              color: MirraColors.danger,
                              weight: FontWeight.w600,
                            )),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                      MirraSpace.lg, 8, MirraSpace.lg, 24),
                  children: [
                    _CategoryTile(
                      category: null,
                      selected: selected == null,
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            null;
                        Navigator.pop(context);
                      },
                    ),
                    for (final c in QuoteCategory.all)
                      _CategoryTile(
                        category: c,
                        selected: selected == c.id,
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).state =
                              c.id;
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final QuoteCategory? category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = category?.label ?? 'All quotes';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? MirraColors.ink : MirraColors.surface,
          borderRadius: BorderRadius.circular(MirraRadius.md),
          border: Border.all(
            color: selected ? MirraColors.ink : MirraColors.line,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: MirraType.ui(
                size: 15,
                weight: FontWeight.w500,
                color: selected ? Colors.white : MirraColors.ink,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
