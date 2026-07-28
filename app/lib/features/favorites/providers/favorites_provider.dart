import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super(MirraBoxes.favorites.values.toSet());

  /// Free-plan cap; going past it is the Mirra+ upsell moment.
  static const freeLimit = 2;

  bool isFavorite(String quoteId) => state.contains(quoteId);

  /// Returns false when the add was blocked by the free-plan limit, so the
  /// caller can show the upsell. Removing is always allowed.
  Future<bool> toggle(String quoteId) async {
    final box = MirraBoxes.favorites;
    if (state.contains(quoteId)) {
      final key = box.toMap().entries.firstWhere((e) => e.value == quoteId).key;
      await box.delete(key);
      state = {...state}..remove(quoteId);
      return true;
    }
    if (!MirraBoxes.current.isPremium && state.length >= freeLimit) {
      return false;
    }
    await box.add(quoteId);
    state = {...state, quoteId};
    return true;
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) => FavoritesNotifier(),
);
