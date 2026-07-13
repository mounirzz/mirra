// Rich theme catalog — each theme changes the feed background AND the quote
// text (font family, weight, case, colour). Backgrounds are hosted on S3
// (bucket mirra-affirmation-bucket, /themes/bg01..bg35.jpg) so they are NOT
// bundled in the app. `dark` is set from each photo's measured brightness so
// the glass controls flip white/ink automatically.
//
// Re-upload the source images with app/scripts/upload_themes_s3.sh.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ThemeFont { serif, sans, mono }

/// Public S3 base URL for theme backgrounds.
const kThemeS3Base =
    'https://mirra-affirmation-bucket.s3.us-east-1.amazonaws.com/themes';

String _bg(int n) => '$kThemeS3Base/bg${n.toString().padLeft(2, '0')}.jpg';

class AppTheme {
  const AppTheme({
    required this.id,
    required this.label,
    this.photoUrl,
    this.gradient,
    this.solid,
    this.dark = false,
    this.font = ThemeFont.serif,
    this.italic = false,
    this.caps = false,
    this.weight = FontWeight.w400,
    this.textColor = Colors.white,
    this.tags = const [],
    this.premium = false,
    this.custom = false,
  });

  final String id;
  final String label;
  final String? photoUrl; // S3 (network) image
  final List<Color>? gradient;
  final Color? solid;
  final bool dark;
  final ThemeFont font;
  final bool italic;
  final bool caps;
  final FontWeight weight;
  final Color textColor;
  final List<String> tags; // 'new' | 'seasonal' | 'popular'
  final bool premium;
  final bool custom;

  bool get isPhoto => photoUrl != null;

  // Disk-cached: downloaded once, then read from local iOS storage.
  ImageProvider? get bgImage =>
      photoUrl != null ? CachedNetworkImageProvider(photoUrl!) : null;

  TextStyle quoteStyle(double size) {
    final base = switch (font) {
      ThemeFont.serif => GoogleFonts.instrumentSerif(
          fontSize: size,
          fontWeight: weight,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      ThemeFont.sans => GoogleFonts.inter(
          fontSize: size,
          fontWeight: weight,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      ThemeFont.mono => GoogleFonts.jetBrainsMono(
          fontSize: size,
          fontWeight: weight,
        ),
    };
    return base.copyWith(
      color: textColor,
      height: 1.2,
      letterSpacing: caps ? size * 0.04 : 0,
      shadows: dark || isPhoto
          ? const [
              Shadow(
                color: Color(0x66000000),
                blurRadius: 16,
                offset: Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  BoxDecoration tileDecoration(BorderRadius radius) => BoxDecoration(
        borderRadius: radius,
        color: solid ??
            (gradient == null && !isPhoto ? const Color(0xFFEFE9DC) : null),
        gradient: gradient != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient!,
              )
            : null,
        image: isPhoto
            ? DecorationImage(image: bgImage!, fit: BoxFit.cover)
            : null,
      );

  AppTheme copyWith({String? id, String? label, bool? custom}) => AppTheme(
        id: id ?? this.id,
        label: label ?? this.label,
        photoUrl: photoUrl,
        gradient: gradient,
        solid: solid,
        dark: dark,
        font: font,
        italic: italic,
        caps: caps,
        weight: weight,
        textColor: textColor,
        tags: tags,
        premium: premium,
        custom: custom ?? this.custom,
      );
}

final kAppThemes = <AppTheme>[
  AppTheme(id: 'city', label: 'City', photoUrl: _bg(1), dark: true, font: ThemeFont.sans, weight: FontWeight.w700, tags: const ['popular']),
  AppTheme(id: 'falls', label: 'Falls', photoUrl: _bg(2), dark: true, font: ThemeFont.serif, tags: const ['new']),
  AppTheme(id: 'london', label: 'London', photoUrl: _bg(3), dark: false, font: ThemeFont.serif),
  AppTheme(id: 'coast', label: 'Coast', photoUrl: _bg(4), dark: true, font: ThemeFont.serif, italic: true, tags: const ['popular']),
  AppTheme(id: 'golden', label: 'Golden', photoUrl: _bg(5), dark: true, font: ThemeFont.serif, italic: true, tags: const ['seasonal']),
  AppTheme(id: 'harvest', label: 'Harvest', photoUrl: _bg(6), dark: true, font: ThemeFont.serif, tags: const ['seasonal']),
  AppTheme(id: 'marina', label: 'MARINA', photoUrl: _bg(7), dark: true, font: ThemeFont.mono, caps: true),
  AppTheme(id: 'calm', label: 'Calm', photoUrl: _bg(8), dark: false, font: ThemeFont.serif, italic: true, tags: const ['new']),
  AppTheme(id: 'forest', label: 'Forest', photoUrl: _bg(9), dark: true, font: ThemeFont.serif, tags: const ['seasonal']),
  AppTheme(id: 'bridge', label: 'Bridge', photoUrl: _bg(10), dark: true, font: ThemeFont.sans, weight: FontWeight.w700),
  AppTheme(id: 'explore', label: 'Explore', photoUrl: _bg(11), dark: true, font: ThemeFont.serif),
  AppTheme(id: 'jungle', label: 'Jungle', photoUrl: _bg(12), dark: true, font: ThemeFont.serif, italic: true),
  AppTheme(id: 'dusk', label: 'Dusk', photoUrl: _bg(13), dark: true, font: ThemeFont.serif, tags: const ['popular']),
  AppTheme(id: 'thames', label: 'Thames', photoUrl: _bg(14), dark: true, font: ThemeFont.serif),
  AppTheme(id: 'pier', label: 'Pier', photoUrl: _bg(15), dark: true, font: ThemeFont.serif, italic: true),
  AppTheme(id: 'riviera', label: 'Riviera', photoUrl: _bg(16), dark: false, font: ThemeFont.serif, tags: const ['new']),
  AppTheme(id: 'skyline', label: 'Skyline', photoUrl: _bg(17), dark: true, font: ThemeFont.sans, weight: FontWeight.w700, tags: const ['popular']),
  AppTheme(id: 'serene', label: 'Serene', photoUrl: _bg(18), dark: false, font: ThemeFont.serif, italic: true),
  AppTheme(id: 'shore', label: 'Shore', photoUrl: _bg(19), dark: false, font: ThemeFont.serif),
  AppTheme(id: 'rain', label: 'Rain', photoUrl: _bg(20), dark: true, font: ThemeFont.serif, italic: true),
  AppTheme(id: 'retreat', label: 'Retreat', photoUrl: _bg(21), dark: true, font: ThemeFont.serif),
  AppTheme(id: 'tropical', label: 'TROPICAL', photoUrl: _bg(22), dark: false, font: ThemeFont.mono, caps: true),
  AppTheme(id: 'horizon', label: 'Horizon', photoUrl: _bg(23), dark: true, font: ThemeFont.serif),
  AppTheme(id: 'bay', label: 'Bay', photoUrl: _bg(24), dark: false, font: ThemeFont.serif, italic: true),
  AppTheme(id: 'nights', label: 'NIGHTS', photoUrl: _bg(25), dark: true, font: ThemeFont.sans, weight: FontWeight.w800, caps: true, tags: const ['popular']),
  AppTheme(id: 'storm', label: 'STORM', photoUrl: _bg(26), dark: true, font: ThemeFont.mono, caps: true),
  AppTheme(id: 'ember', label: 'Ember', photoUrl: _bg(27), dark: true, font: ThemeFont.serif, tags: const ['seasonal']),
  AppTheme(id: 'cozy', label: 'Cozy', photoUrl: _bg(28), dark: true, font: ThemeFont.serif, tags: const ['seasonal']),
  AppTheme(id: 'fields', label: 'Fields', photoUrl: _bg(29), dark: true, font: ThemeFont.serif),
  AppTheme(id: 'metropolis', label: 'Metropolis', photoUrl: _bg(30), dark: true, font: ThemeFont.serif),
  AppTheme(id: 'grid', label: 'Grid', photoUrl: _bg(31), dark: true, font: ThemeFont.sans, weight: FontWeight.w700),
  AppTheme(id: 'palm', label: 'PALM', photoUrl: _bg(32), dark: false, font: ThemeFont.mono, caps: true, tags: const ['new']),
  AppTheme(id: 'neon', label: 'NEON', photoUrl: _bg(33), dark: true, font: ThemeFont.sans, weight: FontWeight.w800, caps: true, tags: const ['popular']),
  AppTheme(id: 'oasis', label: 'Oasis', photoUrl: _bg(34), dark: true, font: ThemeFont.serif, italic: true),
  AppTheme(id: 'journey', label: 'Journey', photoUrl: _bg(35), dark: true, font: ThemeFont.serif),
  // Solid-colour themes
  const AppTheme(id: 'plain', label: 'Plain', solid: Color(0xFFEDE6DA), font: ThemeFont.mono, textColor: Color(0xFF2A2F40)),
  const AppTheme(id: 'black', label: 'Easy to read', solid: Color(0xFF1A1A1A), dark: true, font: ThemeFont.sans, weight: FontWeight.w800, caps: true),
  const AppTheme(id: 'highvis', label: 'High visibility', solid: Color(0xFF4226A8), dark: true, font: ThemeFont.sans, weight: FontWeight.w800, caps: true),
];

AppTheme appThemeById(String id) =>
    kAppThemes.firstWhere((t) => t.id == id, orElse: () => kAppThemes.first);

// ─── Theme mixes (categories) ───────────────────────────────────────────────
class ThemeMix {
  const ThemeMix({
    required this.id,
    required this.label,
    this.photoUrl,
    this.solid,
    this.font = ThemeFont.serif,
    this.italic = false,
    this.caps = false,
    this.bold = false,
    this.textColor = Colors.white,
  });

  final String id;
  final String label;
  final String? photoUrl;
  final Color? solid;
  final ThemeFont font;
  final bool italic;
  final bool caps;
  final bool bold;
  final Color textColor;

  ImageProvider? get bgImage =>
      photoUrl != null ? CachedNetworkImageProvider(photoUrl!) : null;

  TextStyle labelStyle(double size) {
    final base = switch (font) {
      ThemeFont.serif => GoogleFonts.instrumentSerif(
          fontSize: size,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        ),
      ThemeFont.sans => GoogleFonts.inter(
          fontSize: size,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        ),
      ThemeFont.mono => GoogleFonts.jetBrainsMono(
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
    };
    return base.copyWith(
      color: textColor,
      letterSpacing: caps ? size * 0.06 : 0,
    );
  }
}

final kThemeMixes = <ThemeMix>[
  ThemeMix(id: 'animated', label: 'ANIMATED', photoUrl: _bg(29), caps: true),
  ThemeMix(id: 'popular', label: 'Most popular', photoUrl: _bg(13), italic: true),
  ThemeMix(id: 'seasonal', label: 'Seasonal', photoUrl: _bg(27)),
  const ThemeMix(id: 'plain', label: 'Plain', solid: Color(0xFFEDE6DA), font: ThemeFont.mono, textColor: Color(0xFF2A2F40)),
  ThemeMix(id: 'cities', label: 'CITIES', photoUrl: _bg(17), caps: true),
  const ThemeMix(id: 'easy', label: 'EASY TO READ', solid: Color(0xFF1A1A1A), bold: true, caps: true, font: ThemeFont.sans),
  ThemeMix(id: 'nature', label: 'Nature', photoUrl: _bg(9), italic: true),
  ThemeMix(id: 'beaches', label: 'Beaches', photoUrl: _bg(19)),
  ThemeMix(id: 'sunsets', label: 'SUNSETS', photoUrl: _bg(5), caps: true),
  const ThemeMix(id: 'highvis', label: 'HIGH VISIBILITY', solid: Color(0xFF4226A8), bold: true, caps: true, font: ThemeFont.sans),
  ThemeMix(id: 'urban', label: 'Urban', photoUrl: _bg(20), italic: true),
  ThemeMix(id: 'oceans', label: 'Oceans', photoUrl: _bg(16)),
  ThemeMix(id: 'tropical', label: 'TROPICAL', photoUrl: _bg(22), caps: true, font: ThemeFont.mono),
  ThemeMix(id: 'cozy', label: 'Cozy interiors', photoUrl: _bg(28)),
];
