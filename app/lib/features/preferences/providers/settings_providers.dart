import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';

/// First name used to personalize content (Preferences > Name).
class DisplayNameNotifier extends StateNotifier<String?> {
  DisplayNameNotifier() : super(MirraBoxes.current.displayName);

  Future<void> set(String name) async {
    final trimmed = name.trim();
    state = trimmed.isEmpty ? null : trimmed;
    await MirraBoxes.updatePrefs((p) => p.copyWith(displayName: trimmed));
  }
}

final displayNameProvider = StateNotifierProvider<DisplayNameNotifier, String?>(
  (ref) => DisplayNameNotifier(),
);

/// Theme sound volume (Preferences > Sound), 0..1.
class ThemeVolumeNotifier extends StateNotifier<double> {
  ThemeVolumeNotifier() : super(MirraBoxes.current.themeVolume);

  Future<void> set(double value) async {
    state = value;
    await MirraBoxes.updatePrefs((p) => p.copyWith(themeVolume: value));
  }
}

final themeVolumeProvider = StateNotifierProvider<ThemeVolumeNotifier, double>(
  (ref) => ThemeVolumeNotifier(),
);

/// Category ids muted from the feed (Preferences > Muted content).
class MutedCategoriesNotifier extends StateNotifier<List<String>> {
  MutedCategoriesNotifier() : super(MirraBoxes.current.mutedCategories);

  Future<void> mute(String categoryId) async {
    if (state.contains(categoryId)) return;
    state = [...state, categoryId];
    await MirraBoxes.updatePrefs((p) => p.copyWith(mutedCategories: state));
  }

  Future<void> unmute(String categoryId) async {
    state = state.where((c) => c != categoryId).toList();
    await MirraBoxes.updatePrefs((p) => p.copyWith(mutedCategories: state));
  }
}

final mutedCategoriesProvider =
    StateNotifierProvider<MutedCategoriesNotifier, List<String>>(
      (ref) => MutedCategoriesNotifier(),
    );
