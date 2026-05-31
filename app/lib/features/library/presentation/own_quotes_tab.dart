import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../providers/own_quotes_provider.dart';
import '_quote_tile.dart';

class OwnQuotesTab extends ConsumerWidget {
  const OwnQuotesTab({super.key});

  Future<void> _addDialog(BuildContext context, WidgetRef ref) async {
    final textController = TextEditingController();
    final authorController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MirraColors.surface,
        title: Text('New quote', style: MirraType.serif(size: 22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              autofocus: true,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Quote text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: MirraSpace.sm),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                hintText: 'Author (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final text = textController.text.trim();
              if (text.isEmpty) {
                Navigator.pop(ctx);
                return;
              }
              await ref.read(ownQuotesProvider.notifier).add(
                    text: text,
                    author: authorController.text.trim(),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final own = ref.watch(ownQuotesProvider);

    return Stack(
      children: [
        if (own.isEmpty)
          const LibraryEmpty(
            title: 'No quotes of your own',
            subtitle: 'Add a line that resonates. Tap + to write one.',
          )
        else
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                MirraSpace.lg, MirraSpace.md, MirraSpace.lg, 80),
            itemCount: own.length,
            separatorBuilder: (_, _) => const SizedBox(height: MirraSpace.sm),
            itemBuilder: (context, i) {
              final q = own[i];
              return LibraryQuoteTile(
                quote: q,
                trailing: GestureDetector(
                  onTap: () =>
                      ref.read(ownQuotesProvider.notifier).remove(q.id),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: MirraColors.muted2, size: 20),
                ),
              );
            },
          ),
        Positioned(
          right: 20,
          bottom: 90,
          child: FloatingActionButton(
            onPressed: () => _addDialog(context, ref),
            backgroundColor: MirraColors.ink,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
