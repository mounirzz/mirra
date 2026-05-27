import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier()
      : super(MirraBoxes.favorites.values.toSet());

  bool isFavorite(String quoteId) => state.contains(quoteId);

  Future<void> toggle(String quoteId) async {
    final box = MirraBoxes.favorites;
    if (state.contains(quoteId)) {
      final key = box.toMap().entries
          .firstWhere((e) => e.value == quoteId)
          .key;
      await box.delete(key);
      state = {...state}..remove(quoteId);
    } else {
      await box.add(quoteId);
      state = {...state, quoteId};
    }
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) => FavoritesNotifier(),
);
