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

  static const _appGroupId = 'group.com.mirra.affirmations';
  static const _iosWidgetName = 'MirraWidget';

  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
    } catch (_) {}
  }

  /// Pushes up to 12 affirmations (the widget rotates through them) + the lead
  /// category, then refreshes the widget.
  static Future<void> push(List<Quote> quotes) async {
    if (quotes.isEmpty) return;
    final texts = quotes.map((q) => q.text).take(12).toList();
    try {
      await HomeWidget.saveWidgetData<String>('affirmations', jsonEncode(texts));
      await HomeWidget.saveWidgetData<String>('category', quotes.first.category.label);
      await HomeWidget.updateWidget(iOSName: _iosWidgetName);
    } catch (_) {}
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
