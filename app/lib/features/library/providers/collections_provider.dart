import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../shared/models/collection.dart';

class CollectionsNotifier extends StateNotifier<List<Collection>> {
  CollectionsNotifier() : super(MirraBoxes.collections.values.toList());

  Future<void> create(String name) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final c = Collection(id: id, name: name);
    await MirraBoxes.collections.put(id, c);
    state = [...state, c];
  }

  Future<void> rename(String id, String name) async {
    final box = MirraBoxes.collections;
    final c = box.get(id);
    if (c == null) return;
    final updated = c.copyWith(name: name);
    await box.put(id, updated);
    state = state.map((e) => e.id == id ? updated : e).toList();
  }

  Future<void> delete(String id) async {
    await MirraBoxes.collections.delete(id);
    state = state.where((e) => e.id != id).toList();
  }

  Future<void> toggleQuote(String collectionId, String quoteId) async {
    final box = MirraBoxes.collections;
    final c = box.get(collectionId);
    if (c == null) return;
    final next = [...c.quoteIds];
    if (next.contains(quoteId)) {
      next.remove(quoteId);
    } else {
      next.add(quoteId);
    }
    final updated = c.copyWith(quoteIds: next);
    await box.put(collectionId, updated);
    state = state.map((e) => e.id == collectionId ? updated : e).toList();
  }
}

final collectionsProvider =
    StateNotifierProvider<CollectionsNotifier, List<Collection>>(
  (ref) => CollectionsNotifier(),
);
