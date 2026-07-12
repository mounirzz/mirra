import 'dart:io';

import 'package:flutter/material.dart';

import 'palette.dart';

enum ThemeKind { color, presetPhoto, customPhoto }

class ThemePhoto {
  const ThemePhoto({
    required this.id,
    required this.label,
    required this.asset,
    this.premium = false,
  });

  final String id;
  final String label;
  final String asset;

  /// Locked behind Mirra+ (the first few photos stay free as a taste).
  final bool premium;

  static const shells = ThemePhoto(
    id: 'shells',
    label: 'Shells',
    asset: 'assets/photos/shells.png',
  );
  static const clouds = ThemePhoto(
    id: 'clouds',
    label: 'Sky',
    asset: 'assets/photos/clouds.png',
  );
  static const heart = ThemePhoto(
    id: 'heart',
    label: 'Hearts',
    asset: 'assets/photos/heart.png',
  );
  static const chrome = ThemePhoto(
    id: 'chrome',
    label: 'Aurora',
    asset: 'assets/photos/chrome.png',
    premium: true,
  );
  static const meadow = ThemePhoto(
    id: 'meadow',
    label: 'Meadow',
    asset: 'assets/photos/cream_green.png',
    premium: true,
  );
  static const floral = ThemePhoto(
    id: 'floral',
    label: 'Blossom',
    asset: 'assets/photos/floral.png',
    premium: true,
  );
  static const galaxy = ThemePhoto(
    id: 'galaxy',
    label: 'Galaxy',
    asset: 'assets/photos/starry_violet.png',
    premium: true,
  );
  static const goldenHour = ThemePhoto(
    id: 'golden_hour',
    label: 'Golden Hour',
    asset: 'assets/photos/beige_gold.png',
    premium: true,
  );
  static const horizon = ThemePhoto(
    id: 'horizon',
    label: 'Horizon',
    asset: 'assets/photos/personal.png',
    premium: true,
  );
  static const dusk = ThemePhoto(
    id: 'dusk',
    label: 'Dusk',
    asset: 'assets/photos/nature.png',
    premium: true,
  );

  static const all = <ThemePhoto>[
    shells,
    clouds,
    heart,
    chrome,
    meadow,
    floral,
    galaxy,
    goldenHour,
    horizon,
    dusk,
  ];

  static ThemePhoto? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}

/// A user's chosen app theme: a flat color palette, one of the presets we
/// ship as background photos, or a photo they imported themselves.
class ThemeSelection {
  const ThemeSelection.color(this.palette)
    : kind = ThemeKind.color,
      presetPhoto = null,
      customPhotoPath = null;

  const ThemeSelection.presetPhoto(ThemePhoto photo)
    : kind = ThemeKind.presetPhoto,
      palette = null,
      presetPhoto = photo,
      customPhotoPath = null;

  const ThemeSelection.customPhoto(String path)
    : kind = ThemeKind.customPhoto,
      palette = null,
      presetPhoto = null,
      customPhotoPath = path;

  final ThemeKind kind;
  final MirraPalette? palette;
  final ThemePhoto? presetPhoto;
  final String? customPhotoPath;

  bool get isPhoto => kind != ThemeKind.color;

  /// The accent palette to fall back on for chrome (buttons, ambient glow)
  /// that always needs flat colors, even when a photo background is active.
  MirraPalette get paletteOrFallback => palette ?? MirraPalette.cabin;

  ImageProvider? get imageProvider {
    switch (kind) {
      case ThemeKind.presetPhoto:
        return AssetImage(presetPhoto!.asset);
      case ThemeKind.customPhoto:
        return FileImage(File(customPhotoPath!));
      case ThemeKind.color:
        return null;
    }
  }

  /// Encodes to the single string stored in [UserPrefs.themeChoice].
  String encode() {
    switch (kind) {
      case ThemeKind.color:
        return 'color:${palette!.id}';
      case ThemeKind.presetPhoto:
        return 'photo:${presetPhoto!.id}';
      case ThemeKind.customPhoto:
        return 'photo:custom';
    }
  }

  static ThemeSelection decode(String themeChoice, String? customPhotoPath) {
    if (!themeChoice.contains(':')) {
      // Legacy value written before photo themes existed (bare palette id).
      return ThemeSelection.color(MirraPalette.byId(themeChoice));
    }
    final parts = themeChoice.split(':');
    final type = parts.first;
    final value = parts.length > 1 ? parts[1] : '';
    if (type == 'photo') {
      if (value == 'custom' && customPhotoPath != null) {
        return ThemeSelection.customPhoto(customPhotoPath);
      }
      final preset = ThemePhoto.byId(value);
      if (preset != null) return ThemeSelection.presetPhoto(preset);
    }
    return ThemeSelection.color(MirraPalette.byId(value));
  }
}
