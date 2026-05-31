import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../home/providers/quotes_provider.dart';
import '_quote_tile.dart';

class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoritesProvider);
    final all = ref.watch(allQuotesProvider);
    final items = all.where((q) => favs.contains(q.id)).toList();

    if (items.isEmpty) {
      return const LibraryEmpty(
        title: 'No favorites yet',
        subtitle: 'Tap the heart on a quote to keep it here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
          MirraSpace.lg, MirraSpace.md, MirraSpace.lg, 80),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: MirraSpace.sm),
      itemBuilder: (context, i) {
        final q = items[i];
        return LibraryQuoteTile(
          quote: q,
          trailing: GestureDetector(
            onTap: () => ref.read(favoritesProvider.notifier).toggle(q.id),
            child:
                const Icon(Icons.favorite, color: MirraColors.danger, size: 18),
          ),
        );
      },
    );
  }
}
