// Selected-theme state for the feed. Persists into UserPrefs.themeChoice as
// `app:<id>` for catalog themes, or `custom:<font>;<colorHex>;<bg>` for a
// user-created theme (bg = `photo` → use customPhotoPath, or `color:<hex>`).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/storage/hive_boxes.dart';
import 'theme_catalog.dart';

class AppThemeNotifier extends StateNotifier<AppTheme> {
  AppThemeNotifier() : super(_load());

  static AppTheme _load() {
    final raw = MirraBoxes.current.themeChoice;
    if (raw.startsWith('app:')) {
      return appThemeById(raw.substring(4));
    }
    if (raw.startsWith('custom:')) {
      final custom = _decodeCustom(raw.substring(7));
      if (custom != null) return custom;
    }
    // Legacy values ('color:cabin', 'photo:*') → nearest catalog theme.
    if (raw.contains(':')) {
      final id = raw.split(':').last;
      final match = kAppThemes.where((t) => t.id == id);
      if (match.isNotEmpty) return match.first;
    }
    return kAppThemes.first;
  }

  static AppTheme? _decodeCustom(String spec) {
    // font;colorHex;bg   where bg is 'photo' or 'color:AARRGGBB'
    final parts = spec.split(';');
    if (parts.length < 3) return null;
    final font = ThemeFont.values.firstWhere(
      (f) => f.name == parts[0],
      orElse: () => ThemeFont.serif,
    );
    final textColor = Color(int.tryParse(parts[1], radix: 16) ?? 0xFFFFFFFF);
    final bg = parts.sublist(2).join(';');
    final path = MirraBoxes.current.customPhotoPath;
    if (bg == 'photo' && path != null && File(path).existsSync()) {
      return AppTheme(
        id: 'custom',
        label: 'My theme',
        photoUrl: null,
        gradient: null,
        solid: null,
        font: font,
        textColor: textColor,
        dark: true,
        custom: true,
      );
    }
    if (bg.startsWith('color:')) {
      final c = Color(int.tryParse(bg.substring(6), radix: 16) ?? 0xFF1A1A1A);
      return AppTheme(
        id: 'custom',
        label: 'My theme',
        solid: c,
        font: font,
        textColor: textColor,
        dark: c.computeLuminance() < 0.5,
        custom: true,
      );
    }
    return null;
  }

  Future<void> select(AppTheme theme) async {
    state = theme;
    await MirraBoxes.updatePrefs(
      (p) => p.copyWith(themeChoice: 'app:${theme.id}'),
    );
  }

  /// Custom theme from a solid colour background.
  Future<void> setCustomColor({
    required Color background,
    required ThemeFont font,
    required Color textColor,
  }) async {
    final t = AppTheme(
      id: 'custom',
      label: 'My theme',
      solid: background,
      font: font,
      textColor: textColor,
      dark: background.computeLuminance() < 0.5,
      custom: true,
    );
    state = t;
    final hex = textColor.toARGB32().toRadixString(16).padLeft(8, '0');
    final bgHex = background.toARGB32().toRadixString(16).padLeft(8, '0');
    await MirraBoxes.updatePrefs(
      (p) => p.copyWith(themeChoice: 'custom:${font.name};$hex;color:$bgHex'),
    );
  }

  /// Custom theme from a photo picked in the gallery.
  Future<bool> setCustomPhoto({
    required ThemeFont font,
    required Color textColor,
  }) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return false;

    final dir = await getApplicationDocumentsDirectory();
    final ext = picked.path.contains('.')
        ? picked.path.substring(picked.path.lastIndexOf('.'))
        : '.jpg';
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final dest = File('${dir.path}/theme_photo_$stamp$ext');
    await File(picked.path).copy(dest.path);

    final t = AppTheme(
      id: 'custom',
      label: 'My theme',
      font: font,
      textColor: textColor,
      dark: true,
      custom: true,
    );
    state = t;
    final hex = textColor.toARGB32().toRadixString(16).padLeft(8, '0');
    await MirraBoxes.updatePrefs(
      (p) => p.copyWith(
        themeChoice: 'custom:${font.name};$hex;photo',
        customPhotoPath: dest.path,
      ),
    );
    return true;
  }
}

final appThemeProvider =
    StateNotifierProvider<AppThemeNotifier, AppTheme>(
  (ref) => AppThemeNotifier(),
);

/// The custom photo file (if the active theme is a custom photo).
File? activeCustomPhotoFile() {
  final path = MirraBoxes.current.customPhotoPath;
  if (path != null && File(path).existsSync()) return File(path);
  return null;
}
