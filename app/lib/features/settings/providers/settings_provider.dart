import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../shared/models/user_prefs.dart';

class SettingsNotifier extends StateNotifier<UserPrefs> {
  SettingsNotifier() : super(MirraBoxes.current);

  Future<void> setThemeMode(ThemeModePref mode) async {
    await MirraBoxes.updatePrefs((p) {
      p.themeMode = mode;
      return p;
    });
    state = MirraBoxes.current;
  }

  Future<void> setLanguage(String code) async {
    await MirraBoxes.updatePrefs((p) {
      p.language = code;
      return p;
    });
    state = MirraBoxes.current;
  }

  Future<void> setQuoteFontSize(double size) async {
    await MirraBoxes.updatePrefs((p) {
      p.quoteFontSize = size;
      return p;
    });
    state = MirraBoxes.current;
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserPrefs>(
  (ref) => SettingsNotifier(),
);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final mode = ref.watch(settingsProvider).themeMode;
  switch (mode) {
    case ThemeModePref.system:
      return ThemeMode.system;
    case ThemeModePref.light:
      return ThemeMode.light;
    case ThemeModePref.dark:
      return ThemeMode.dark;
  }
});
