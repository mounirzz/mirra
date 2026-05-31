import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../shared/models/mood_entry.dart';

class MoodNotifier extends StateNotifier<List<MoodEntry>> {
  MoodNotifier() : super(MirraBoxes.mood.values.toList());

  MoodEntry? get today {
    final now = DateTime.now();
    for (final m in state) {
      if (m.date.year == now.year &&
          m.date.month == now.month &&
          m.date.day == now.day) {
        return m;
      }
    }
    return null;
  }

  Future<void> log(int score) async {
    final entry = MoodEntry(score: score);
    await MirraBoxes.mood.add(entry);
    state = [...state, entry];
  }
}

final moodProvider =
    StateNotifierProvider<MoodNotifier, List<MoodEntry>>(
  (ref) => MoodNotifier(),
);
