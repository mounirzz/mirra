import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../shared/models/quote.dart';
import '../home/providers/quotes_provider.dart';

/// Shares the current affirmations with the iOS home/lock-screen widget via the
/// App Group, and asks the widget to refresh. All calls are best-effort: before
/// the widget extension / App Group exist they simply no-op, so the app never
/// breaks.
class WidgetService {
  const WidgetService._();

  static const _appGroupId = 'group.com.mirra.affirmations.shared';
  static const _iosWidgetName = 'MirraWidget';

  // Maps our content categories onto the Siri "affirmation type" the
  // MotivateMeIntent understands, so "Give me a love affirmation" finds one.
  static const _siriTypeByCategoryId = <String, String>{
    'love': 'love',
    'workout': 'workout',
    'sports': 'sports',
    'business': 'work',
    'productivity': 'work',
    'success': 'work',
    'motivation': 'morning',
    'gratitude': 'morning',
    'mindfulness': 'morning',
    'happiness': 'positive',
    'confidence': 'positive',
  };

  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
    } catch (_) {}
  }

  /// Pushes up to 12 affirmations (the widget rotates through them) + the lead
  /// category, then refreshes the widget. Also feeds Siri's per-type store.
  static Future<void> push(List<Quote> quotes) async {
    if (quotes.isEmpty) return;
    final texts = quotes.map((q) => q.text).take(12).toList();
    try {
      await HomeWidget.saveWidgetData<String>('affirmations', jsonEncode(texts));
      await HomeWidget.saveWidgetData<String>('category', quotes.first.category.label);
      await _mergeSiriTypes(quotes);
      await HomeWidget.updateWidget(iOSName: _iosWidgetName);
    } catch (_) {}
  }

  /// Accumulates affirmations by Siri type across the categories the user
  /// browses, so Siri can answer type-specific requests. Best-effort.
  static Future<void> _mergeSiriTypes(List<Quote> quotes) async {
    var map = <String, List<String>>{};
    try {
      final raw = await HomeWidget.getWidgetData<String>('affirmations_by_category');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        map = decoded.map((k, v) => MapEntry(k, (v as List).cast<String>()));
      }
    } catch (_) {}
    for (final q in quotes) {
      final type = _siriTypeByCategoryId[q.categoryId];
      if (type == null) continue;
      final list = map.putIfAbsent(type, () => <String>[]);
      if (!list.contains(q.text)) list.add(q.text);
      if (list.length > 20) list.removeRange(0, list.length - 20);
    }
    await HomeWidget.saveWidgetData<String>('affirmations_by_category', jsonEncode(map));
  }
}

/// Keeps the widget in sync with the feed: whenever the shown affirmations
/// change, they're written to the shared store. Keep alive from the app root.
final widgetSyncProvider = Provider<void>((ref) {
  ref.listen<List<Quote>>(
    filteredQuotesProvider,
    (_, quotes) => unawaited(WidgetService.push(quotes)),
    fireImmediately: true,
  );
});
