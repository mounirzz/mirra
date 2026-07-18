import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Categories picked in the Mix screen. Empty set = everything.
final selectedCategoriesProvider = StateProvider<Set<String>>((ref) => {});

/// Which categories to surface first, from the onboarding answers.
const _improveBoosts = <String, List<String>>{
  'Confidence': ['confidence', 'women'],
  'Focus': ['productivity', 'success'],
  'Calm': ['mindfulness', 'stress'],
  'Discipline': ['motivation', 'workout'],
};

/// Free-plan daily stack: 5 affirmations, then the end card sells Mirra+.
/// The batch rotates every day, so "come back tomorrow" is a real promise.
const _dailyBatchSize = 5;

final filteredQuotesProvider = Provider<List<Quote>>((ref) {
  final all = ref.watch(allQuotesProvider);
  final cats = ref.watch(selectedCategoriesProvider);
  final answers = ref.watch(onboardingProvider);

  // An explicit Mix selection wins over everything else and shows the full
  // matching catalog (the user is deliberately exploring).
  if (cats.isNotEmpty) {
    return all.where((q) => cats.contains(q.categoryId)).toList();
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

  // Content preferences: restrict the catalog to the chosen topics' categories
  // (applies to the seed fallback and the AI feed alike). Guarded so it never
  // empties the feed if nothing matches.
  final contentCats = ref
      .watch(contentTopicsProvider)
      .map((t) => kContentTopicCategory[t])
      .whereType<String>()
      .toSet();
  if (contentCats.isNotEmpty) {
    final narrowed =
        quotes.where((q) => contentCats.contains(q.categoryId)).toList();
    if (narrowed.isNotEmpty) quotes = narrowed;
  }

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

  // Mirra+ removes the daily cap entirely.
  final isPremium = ref.watch(isPremiumProvider);
  return [...own, ...(isPremium ? quotes : quotes.take(_dailyBatchSize))];
});

/// Whether the feed should end with the upsell card (free plan only).
final feedHasEndCardProvider = Provider<bool>(
  (ref) => !ref.watch(isPremiumProvider),
);

final currentQuoteIndexProvider = StateProvider<int>((ref) => 0);
