import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../data/seed_quotes.dart';
import '../../../shared/models/quote.dart';
import '../../affirmations/daily_affirmations_provider.dart';
import '../../my_quotes/providers/own_quotes_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../preferences/providers/content_topics_provider.dart';
import '../../preferences/providers/settings_providers.dart';
import '../../premium/providers/premium_provider.dart';

/// The user's own affirmations lead the feed, followed by the day's catalog.
/// That catalog is the backend's AI-personalized affirmations once they've
/// loaded; until then (loading / signed out / offline) it falls back to the
/// static seed catalog, so the feed is never empty and the UI never changes.
final allQuotesProvider = Provider<List<Quote>>((ref) {
  final own = ref.watch(ownQuotesProvider);
  final ai = ref.watch(dailyAffirmationsProvider);
  final catalog = ai.isNotEmpty ? ai : kSeedQuotes;
  return [...own, ...catalog];
});

/// Categories picked in the Mix / Content preferences screens (both share this
/// one selection — pick in one, it reflects in the other and shapes the feed).
/// Empty set = everything.
class SelectedCategoriesNotifier extends StateNotifier<Set<String>> {
  SelectedCategoriesNotifier() : super({});

  /// Free-plan cap on how many categories can be selected at once.
  static const freeLimit = 2;

  /// Toggles a category. Returns false when the add was blocked by the
  /// free-plan limit, so the caller can show the upsell. Removing is allowed.
  bool toggle(String categoryId) {
    final next = {...state};
    if (next.remove(categoryId)) {
      state = next;
      return true;
    }
    if (!MirraBoxes.current.isPremium && state.length >= freeLimit) {
      return false;
    }
    next.add(categoryId);
    state = next;
    return true;
  }

  void clear() => state = {};
}

final selectedCategoriesProvider =
    StateNotifierProvider<SelectedCategoriesNotifier, Set<String>>(
  (ref) => SelectedCategoriesNotifier(),
);

/// Which categories to surface first, from the onboarding answers.
const _improveBoosts = <String, List<String>>{
  'Confidence': ['confidence', 'women'],
  'Focus': ['productivity', 'success'],
  'Calm': ['mindfulness', 'stress'],
  'Discipline': ['motivation', 'workout'],
};

/// Free-plan daily stack: 3 affirmations, then the end card sells Mirra+.
/// The batch rotates every day, so "come back tomorrow" is a real promise.
const _dailyBatchSize = 3;

final filteredQuotesProvider = Provider<List<Quote>>((ref) {
  final all = ref.watch(allQuotesProvider);
  final cats = ref.watch(selectedCategoriesProvider);
  final answers = ref.watch(onboardingProvider);

  // An explicit category selection (Mix / Content preferences) wins over
  // everything else. Free users still get only the daily batch; Mirra+ is
  // unlimited.
  if (cats.isNotEmpty) {
    final own = all.where((q) => q.categoryId == 'personal').toList();
    final matching = all
        .where((q) => q.categoryId != 'personal' && cats.contains(q.categoryId))
        .toList();
    final isPremium = ref.watch(isPremiumProvider);
    return [...own, ...(isPremium ? matching : matching.take(_dailyBatchSize))];
  }

  // The user's own affirmations always lead and don't count in the batch.
  final own = all.where((q) => q.categoryId == 'personal').toList();
  var quotes = all.where((q) => q.categoryId != 'personal').toList();

  // Someone who said faith-based affirmations don't resonate shouldn't get
  // them (they can still opt back in through Mix).
  if (answers['religion'] == 'No') {
    quotes = quotes.where((q) => q.categoryId != 'faith').toList();
  }

  // Muted topics (Preferences > Muted content) never show in the feed.
  final mutedCats = ref.watch(mutedCategoriesProvider);
  if (mutedCats.isNotEmpty) {
    quotes =
        quotes.where((q) => !mutedCats.contains(q.categoryId)).toList();
  }

  // The topics chosen in Content preferences → feed categories (used below to
  // lead the feed with those topics).
  final contentCats = ref
      .watch(contentTopicsProvider)
      .map((t) => kContentTopicCategory[t])
      .whereType<String>()
      .toSet();

  // Deterministic daily shuffle: same order all day, fresh stack tomorrow.
  final today = DateTime.now();
  final daySeed = today.year * 10000 + today.month * 100 + today.day;
  quotes.shuffle(Random(daySeed));

  // Surface the categories matching their stated goals (and calming content
  // for anxious moods) first. 'improve' is multi-select, so cumulate the
  // boosts of every picked goal.
  final boosted = <String>{
    for (final goal in OnboardingNotifier.splitMulti(answers['improve']))
      ...?_improveBoosts[goal],
    if (answers['mood'] == 'Anxious') ...['stress', 'mindfulness'],
  };
  if (boosted.isNotEmpty) {
    quotes = [
      ...quotes.where((q) => boosted.contains(q.categoryId)),
      ...quotes.where((q) => !boosted.contains(q.categoryId)),
    ];
  }

  // Content preferences take precedence: lead the feed with the chosen topics.
  // Show only them when there's enough on-topic content (the AI generates a
  // full set); otherwise lead with them and top up so the feed is never tiny.
  if (contentCats.isNotEmpty) {
    final matching =
        quotes.where((q) => contentCats.contains(q.categoryId)).toList();
    final rest =
        quotes.where((q) => !contentCats.contains(q.categoryId)).toList();
    quotes = matching.length >= _dailyBatchSize
        ? matching
        : [...matching, ...rest];
  }

  // Mirra+ removes the daily cap entirely.
  final isPremium = ref.watch(isPremiumProvider);
  return [...own, ...(isPremium ? quotes : quotes.take(_dailyBatchSize))];
});

/// Whether the feed should end with the upsell card (free plan only).
final feedHasEndCardProvider = Provider<bool>(
  (ref) => !ref.watch(isPremiumProvider),
);

final currentQuoteIndexProvider = StateProvider<int>((ref) => 0);
