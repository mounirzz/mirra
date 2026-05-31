import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/quote.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import '../../home/providers/quotes_provider.dart';
import '../../library/presentation/_quote_tile.dart';
import '../../library/providers/own_quotes_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Quote> _results(List<Quote> pool) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return pool
        .where((quote) =>
            quote.text.toLowerCase().contains(q) ||
            quote.author.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allQuotesProvider);
    final own = ref.watch(ownQuotesProvider);
    final pool = [...all, ...own];
    final results = _results(pool);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const IosStatusSpacer(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  MirraSpace.lg, 0, MirraSpace.lg, MirraSpace.sm),
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: MirraColors.surface,
                        borderRadius: BorderRadius.circular(MirraRadius.pill),
                        border: Border.all(color: MirraColors.line),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              size: 18, color: MirraColors.muted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search quotes or authors',
                                hintStyle: MirraType.ui(
                                    size: 14, color: MirraColors.muted),
                              ),
                              style: MirraType.ui(size: 14),
                              onChanged: (v) => setState(() => _query = v),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                              child: const Icon(Icons.close_rounded,
                                  size: 18, color: MirraColors.muted),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _query.isEmpty
                  ? _Suggestions(
                      pool: pool,
                      onPick: (text) {
                        _controller.text = text;
                        setState(() => _query = text);
                      },
                    )
                  : results.isEmpty
                      ? const LibraryEmpty(
                          title: 'Nothing found',
                          subtitle: 'Try a different word or author.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              MirraSpace.lg, MirraSpace.sm, MirraSpace.lg, 40),
                          itemCount: results.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: MirraSpace.sm),
                          itemBuilder: (context, i) =>
                              LibraryQuoteTile(quote: results[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.pool, required this.onPick});
  final List<Quote> pool;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final authors = <String>{};
    for (final q in pool) {
      authors.add(q.author);
      if (authors.length >= 8) break;
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          MirraSpace.lg, MirraSpace.sm, MirraSpace.lg, 40),
      children: [
        Text('Try',
            style: MirraType.ui(
                size: 12,
                color: MirraColors.muted,
                weight: FontWeight.w600)),
        const SizedBox(height: MirraSpace.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in authors)
              GestureDetector(
                onTap: () => onPick(a),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: MirraColors.chip,
                    borderRadius: BorderRadius.circular(MirraRadius.pill),
                    border: Border.all(color: MirraColors.chipLine),
                  ),
                  child: Text(a,
                      style: MirraType.ui(
                          size: 12, weight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
