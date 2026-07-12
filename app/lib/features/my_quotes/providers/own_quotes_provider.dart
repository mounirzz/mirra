import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../shared/models/quote.dart';

/// The user's own affirmations, persisted in the `ownQuotes` Hive box and
/// mixed into the feed ahead of the seed quotes.
class OwnQuotesNotifier extends StateNotifier<List<Quote>> {
  OwnQuotesNotifier() : super(MirraBoxes.ownQuotes.values.toList());

  Future<void> add(String text) async {
    final quote = Quote(
      id: 'own_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      author: 'You',
      categoryId: 'personal',
    );
    await MirraBoxes.ownQuotes.put(quote.id, quote);
    state = MirraBoxes.ownQuotes.values.toList();
  }

  Future<void> edit(String id, String newText) async {
    final existing = MirraBoxes.ownQuotes.get(id);
    if (existing == null) return;
    await MirraBoxes.ownQuotes.put(
      id,
      Quote(
        id: id,
        text: newText.trim(),
        author: existing.author,
        categoryId: existing.categoryId,
      ),
    );
    state = MirraBoxes.ownQuotes.values.toList();
  }

  Future<void> remove(String id) async {
    await MirraBoxes.ownQuotes.delete(id);
    state = MirraBoxes.ownQuotes.values.toList();
  }
}

final ownQuotesProvider = StateNotifierProvider<OwnQuotesNotifier, List<Quote>>(
  (ref) => OwnQuotesNotifier(),
);
