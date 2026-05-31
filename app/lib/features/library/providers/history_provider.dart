import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../shared/models/history_entry.dart';

class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  HistoryNotifier()
      : super(MirraBoxes.history.values.toList().reversed.toList());

  Future<void> track(String quoteId) async {
    // Skip if same quoteId was the most recent entry.
    if (state.isNotEmpty && state.first.quoteId == quoteId) return;
    final entry = HistoryEntry(quoteId: quoteId);
    await MirraBoxes.history.add(entry);
    state = [entry, ...state].take(200).toList();
  }

  Future<void> clear() async {
    await MirraBoxes.history.clear();
    state = [];
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>(
  (ref) => HistoryNotifier(),
);
