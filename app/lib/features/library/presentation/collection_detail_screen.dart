import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/quote.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import '../../home/providers/quotes_provider.dart';
import '../providers/collections_provider.dart';
import '../providers/own_quotes_provider.dart';
import '_quote_tile.dart';

class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({super.key, required this.collectionId});

  final String collectionId;

  Future<void> _renameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MirraColors.surface,
        title: Text('Rename collection', style: MirraType.serif(size: 22)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                Navigator.pop(ctx);
                return;
              }
              await ref
                  .read(collectionsProvider.notifier)
                  .rename(collectionId, name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MirraColors.surface,
        title: Text('Delete collection?', style: MirraType.serif(size: 22)),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: MirraColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(collectionsProvider.notifier).delete(collectionId);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    final all = ref.watch(allQuotesProvider);
    final own = ref.watch(ownQuotesProvider);
    final collection = collections.firstWhere(
      (c) => c.id == collectionId,
      orElse: () => collections.isEmpty
          ? throw StateError('missing')
          : collections.first,
    );

    final byId = {for (final q in [...all, ...own]) q.id: q};
    final quotes = <Quote>[
      for (final id in collection.quoteIds)
        if (byId[id] != null) byId[id]!,
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const IosStatusSpacer(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MirraSpace.lg),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(collection.name,
                        style: MirraType.title.copyWith(fontSize: 26),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () =>
                        _renameDialog(context, ref, collection.name),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 20, color: MirraColors.danger),
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  MirraSpace.lg, MirraSpace.xs, MirraSpace.lg, MirraSpace.sm),
              child: Row(
                children: [
                  Text('${quotes.length} quotes',
                      style: MirraType.ui(
                          size: 12,
                          color: MirraColors.muted,
                          weight: FontWeight.w500)),
                ],
              ),
            ),
            Expanded(
              child: quotes.isEmpty
                  ? const LibraryEmpty(
                      title: 'Empty collection',
                      subtitle:
                          'Add quotes from Favorites or My quotes (coming soon).',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          MirraSpace.lg, 0, MirraSpace.lg, 40),
                      itemCount: quotes.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: MirraSpace.sm),
                      itemBuilder: (context, i) {
                        final q = quotes[i];
                        return LibraryQuoteTile(
                          quote: q,
                          trailing: GestureDetector(
                            onTap: () => ref
                                .read(collectionsProvider.notifier)
                                .toggleQuote(collectionId, q.id),
                            child: const Icon(Icons.remove_circle_outline,
                                color: MirraColors.muted2, size: 20),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
