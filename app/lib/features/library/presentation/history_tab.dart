import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../home/providers/quotes_provider.dart';
import '../providers/history_provider.dart';
import '_quote_tile.dart';

class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    if (isToday) {
      final h = d.hour.toString().padLeft(2, '0');
      final m = d.minute.toString().padLeft(2, '0');
      return 'Today, $h:$m';
    }
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final all = ref.watch(allQuotesProvider);

    if (history.isEmpty) {
      return const LibraryEmpty(
        title: 'No history yet',
        subtitle: 'Quotes you read will appear here.',
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(MirraSpace.lg, MirraSpace.sm,
              MirraSpace.lg, MirraSpace.xs),
          child: Row(
            children: [
              Text('${history.length} viewed',
                  style: MirraType.ui(
                      size: 12,
                      color: MirraColors.muted,
                      weight: FontWeight.w500)),
              const Spacer(),
              GestureDetector(
                onTap: () => ref.read(historyProvider.notifier).clear(),
                child: Text('Clear',
                    style: MirraType.ui(
                        size: 12,
                        color: MirraColors.danger,
                        weight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                MirraSpace.lg, MirraSpace.xs, MirraSpace.lg, 80),
            itemCount: history.length,
            separatorBuilder: (_, _) => const SizedBox(height: MirraSpace.sm),
            itemBuilder: (context, i) {
              final entry = history[i];
              final q = all.firstWhere(
                (q) => q.id == entry.quoteId,
                orElse: () => all.first,
              );
              return LibraryQuoteTile(
                quote: q,
                subtitle:
                    '${_formatDate(entry.viewedAt)} · ${q.author}',
              );
            },
          ),
        ),
      ],
    );
  }
}
