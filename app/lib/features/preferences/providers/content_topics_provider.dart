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

/// Maps a content topic token to an existing feed category id, so the selection
/// can also filter the seed catalog (the fallback when AI affirmations aren't
/// loaded, e.g. signed out / offline).
const Map<String, String> kContentTopicCategory = {
  'hard_times': 'healing',
  'workout': 'workout',
  'productivity': 'productivity',
  'self_esteem': 'confidence',
  'success': 'success',
  'inspiration': 'motivation',
  'letting_go': 'healing',
  'love': 'love',
  'relationships': 'love',
  'faith': 'faith',
  'positivity': 'happiness',
  'stress': 'stress',
  // Extra tokens used by the "Topics you follow" screen.
  'confidence': 'confidence',
  'motivation': 'motivation',
  'gratitude': 'gratitude',
  'happiness': 'happiness',
  'discipline': 'motivation',
  'calm': 'stress',
  'mindfulness': 'mindfulness',
  'healing': 'healing',
  'health': 'happiness',
  'growth': 'life',
};

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

  /// Follow (or unfollow) a whole bundle of topics at once.
  Future<void> followBundle(Iterable<String> ids, bool follow) async {
    final next = {...state};
    if (follow) {
      next.addAll(ids);
    } else {
      next.removeAll(ids);
    }
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
