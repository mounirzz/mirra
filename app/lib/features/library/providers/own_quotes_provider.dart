import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../shared/models/quote.dart';

class OwnQuotesNotifier extends StateNotifier<List<Quote>> {
  OwnQuotesNotifier() : super(MirraBoxes.ownQuotes.values.toList());

  Future<void> add({required String text, required String author}) async {
    final id = 'own_${DateTime.now().millisecondsSinceEpoch}';
    final q = Quote(
      id: id,
      text: text,
      author: author.isEmpty ? 'You' : author,
      categoryId: 'motivation',
    );
    await MirraBoxes.ownQuotes.put(id, q);
    state = [...state, q];
  }

  Future<void> remove(String id) async {
    await MirraBoxes.ownQuotes.delete(id);
    state = state.where((e) => e.id != id).toList();
  }
}

final ownQuotesProvider =
    StateNotifierProvider<OwnQuotesNotifier, List<Quote>>(
  (ref) => OwnQuotesNotifier(),
);
