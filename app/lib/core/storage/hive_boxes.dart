import 'package:hive_flutter/hive_flutter.dart';

import '../../shared/models/collection.dart';
import '../../shared/models/history_entry.dart';
import '../../shared/models/mood_entry.dart';
import '../../shared/models/quote.dart';
import '../../shared/models/user_prefs.dart';

class MirraBoxes {
  const MirraBoxes._();

  static const String favoritesBoxName = 'favorites';
  static const String ownQuotesBoxName = 'own_quotes';
  static const String collectionsBoxName = 'collections';
  static const String historyBoxName = 'history';
  static const String moodBoxName = 'mood';
  static const String prefsBoxName = 'user_prefs';

  static late Box<String> favorites;
  static late Box<Quote> ownQuotes;
  static late Box<Collection> collections;
  static late Box<HistoryEntry> history;
  static late Box<MoodEntry> mood;
  static late Box<UserPrefs> prefs;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(QuoteAdapter());        // typeId 1
    Hive.registerAdapter(UserPrefsAdapter());    // typeId 2
    Hive.registerAdapter(CollectionAdapter());   // typeId 3
    Hive.registerAdapter(HistoryEntryAdapter()); // typeId 4
    Hive.registerAdapter(MoodEntryAdapter());    // typeId 5

    favorites = await Hive.openBox<String>(favoritesBoxName);
    ownQuotes = await Hive.openBox<Quote>(ownQuotesBoxName);
    collections = await Hive.openBox<Collection>(collectionsBoxName);
    history = await Hive.openBox<HistoryEntry>(historyBoxName);
    mood = await Hive.openBox<MoodEntry>(moodBoxName);
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
