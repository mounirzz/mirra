import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/hive_boxes.dart';

class AppLanguage {
  const AppLanguage(this.code, this.label, this.flag);

  final String code;
  final String label;
  final String flag;

  static const english = AppLanguage('en', 'English', '🇬🇧');
  static const french = AppLanguage('fr', 'Français', '🇫🇷');

  static const all = [english, french];

  static AppLanguage byCode(String code) =>
      all.firstWhere((l) => l.code == code, orElse: () => english);
}

/// The chosen UI language, persisted. Feeds MaterialApp.locale — screens
/// pick up their translations from it as localization lands (task #20).
class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier()
    : super(AppLanguage.byCode(MirraBoxes.current.languageCode));

  Future<void> select(AppLanguage language) async {
    state = language;
    await MirraBoxes.updatePrefs(
      (p) => p.copyWith(languageCode: language.code),
    );
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>(
  (ref) => LanguageNotifier(),
);
