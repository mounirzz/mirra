import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../providers/collections_provider.dart';
import '_quote_tile.dart';

class CollectionsTab extends ConsumerWidget {
  const CollectionsTab({super.key});

  Future<void> _createDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MirraColors.surface,
        title: Text('New collection',
            style: MirraType.serif(size: 22)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Morning push',
            border: OutlineInputBorder(),
          ),
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
              await ref.read(collectionsProvider.notifier).create(name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);

    return Stack(
      children: [
        if (collections.isEmpty)
          const LibraryEmpty(
            title: 'No collections yet',
            subtitle: 'Group quotes by theme. Tap + to create one.',
          )
        else
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                MirraSpace.lg, MirraSpace.md, MirraSpace.lg, 80),
            itemCount: collections.length,
            separatorBuilder: (_, _) => const SizedBox(height: MirraSpace.sm),
            itemBuilder: (context, i) {
              final c = collections[i];
              return GestureDetector(
                onTap: () => context.push('/library/collection/${c.id}'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(MirraSpace.md),
                  decoration: BoxDecoration(
                    color: MirraColors.surface,
                    borderRadius: BorderRadius.circular(MirraRadius.lg),
                    border: Border.all(color: MirraColors.line),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: MirraColors.gradSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.collections_bookmark_outlined,
                          color: MirraColors.ink,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name,
                                style: MirraType.ui(
                                    size: 15, weight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('${c.quoteIds.length} quotes',
                                style: MirraType.ui(
                                  size: 12,
                                  color: MirraColors.muted,
                                )),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: MirraColors.muted2),
                    ],
                  ),
                ),
              );
            },
          ),
        Positioned(
          right: 20,
          bottom: 90,
          child: FloatingActionButton(
            onPressed: () => _createDialog(context, ref),
            backgroundColor: MirraColors.ink,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
