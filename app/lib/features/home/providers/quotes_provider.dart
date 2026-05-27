import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/seed_quotes.dart';
import '../../../shared/models/quote.dart';

final allQuotesProvider = Provider<List<Quote>>((ref) => kSeedQuotes);

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredQuotesProvider = Provider<List<Quote>>((ref) {
  final all = ref.watch(allQuotesProvider);
  final cat = ref.watch(selectedCategoryProvider);
  if (cat == null) return all;
  return all.where((q) => q.categoryId == cat).toList();
});

final currentQuoteIndexProvider = StateProvider<int>((ref) => 0);
