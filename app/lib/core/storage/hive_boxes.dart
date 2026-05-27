import 'package:hive_flutter/hive_flutter.dart';

import '../../shared/models/quote.dart';
import '../../shared/models/user_prefs.dart';

class MirraBoxes {
  const MirraBoxes._();

  static const String favoritesBoxName = 'favorites';
  static const String ownQuotesBoxName = 'own_quotes';
  static const String collectionsBoxName = 'collections';
  static const String historyBoxName = 'history';
  static const String prefsBoxName = 'user_prefs';

  static late Box<String> favorites;
  static late Box<Quote> ownQuotes;
  static late Box<List<String>> collections;
  static late Box<String> history;
  static late Box<UserPrefs> prefs;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(QuoteAdapter());
    Hive.registerAdapter(UserPrefsAdapter());

    favorites = await Hive.openBox<String>(favoritesBoxName);
    ownQuotes = await Hive.openBox<Quote>(ownQuotesBoxName);
    collections = await Hive.openBox<List<String>>(collectionsBoxName);
    history = await Hive.openBox<String>(historyBoxName);
    prefs = await Hive.openBox<UserPrefs>(prefsBoxName);

    if (prefs.get('main') == null) {
      await prefs.put('main', UserPrefs());
    }
  }

  static UserPrefs get current => prefs.get('main')!;

  static Future<void> updatePrefs(UserPrefs Function(UserPrefs) update) async {
    final next = update(current);
    await prefs.put('main', next);
  }
}
