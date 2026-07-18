import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';

/// Topics the user can pick in "Content preferences". First value = the token
/// sent to the affirmation model (drives what it writes about); second = the
/// display label.
const List<(String, String)> kContentTopics = [
  ('hard_times', 'Hard times'),
  ('workout', 'Working out'),
  ('productivity', 'Productivity'),
  ('self_esteem', 'Self-esteem'),
  ('success', 'Achieving goals'),
  ('inspiration', 'Inspiration'),
  ('letting_go', 'Letting go'),
  ('love', 'Love'),
  ('relationships', 'Relationships'),
  ('faith', 'Faith & Spirituality'),
  ('positivity', 'Positive thinking'),
  ('stress', 'Stress & Anxiety'),
];

/// The user's chosen content topics (persisted in prefs.selectedTopics). These
/// become the primary `preferredTopics` for affirmation generation, so the
/// feed adapts to exactly what the user selects here.
class ContentTopicsNotifier extends StateNotifier<Set<String>> {
  ContentTopicsNotifier() : super({...MirraBoxes.current.selectedTopics});

  Future<void> toggle(String id) async {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
    await MirraBoxes.updatePrefs(
      (p) => p.copyWith(selectedTopics: next.toList()),
    );
  }
}

final contentTopicsProvider =
    StateNotifierProvider<ContentTopicsNotifier, Set<String>>(
  (ref) => ContentTopicsNotifier(),
);
