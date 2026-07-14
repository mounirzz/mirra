import 'package:flutter/material.dart';

import 'colors.dart';

/// App-wide typography. All UI text renders in **Carmen Sans** — the
/// `serif`/`ui`/`mono`/`cochin` helpers are kept only for call-site
/// compatibility and now all delegate to Carmen Sans.
///
/// NOTE: the feed affirmation and theme previews do NOT go through here — they
/// build their font directly from the selected theme (see
/// `features/theme/theme_catalog.dart`), so per-theme fonts (serif / mono /
/// italic) are preserved.
class MirraType {
  const MirraType._();

  static TextStyle _carmen({
    required double size,
    required Color color,
    double? height,
    double? letterSpacing,
    FontStyle style = FontStyle.normal,
  }) {
    return TextStyle(
      fontFamily: 'CarmenSans',
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w800,
      fontStyle: style,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle carmenSans({
    double size = 16,
    Color color = MirraColors.ink,
    double? height,
    double? letterSpacing,
  }) =>
      _carmen(size: size, color: color, height: height, letterSpacing: letterSpacing);

  static TextStyle serif({
    double size = 28,
    Color color = MirraColors.ink,
    FontWeight weight = FontWeight.w400,
    double? height,
    FontStyle style = FontStyle.normal,
  }) =>
      _carmen(size: size, color: color, height: height, style: style);

  static TextStyle ui({
    double size = 15,
    Color color = MirraColors.ink,
    FontWeight weight = FontWeight.w400,
    double? height,
    double? letterSpacing,
  }) =>
      _carmen(size: size, color: color, height: height, letterSpacing: letterSpacing);

  static TextStyle mono({
    double size = 12,
    Color color = MirraColors.muted,
    FontWeight weight = FontWeight.w400,
  }) =>
      _carmen(size: size, color: color);

  static TextStyle cochin({
    double size = 15,
    Color color = MirraColors.ink,
    FontWeight weight = FontWeight.w400,
    FontStyle style = FontStyle.normal,
    double? height,
    double? letterSpacing,
  }) =>
      _carmen(
        size: size,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        style: style,
      );

  static TextStyle hero = serif(size: 44, height: 1.05);
  static TextStyle title = serif(size: 32, height: 1.1);
  static TextStyle quoteCard = serif(size: 30, height: 1.18);
  static TextStyle bodyUi = ui(size: 15, color: MirraColors.ink, height: 1.4);
  static TextStyle labelUi = ui(
    size: 13,
    color: MirraColors.muted,
    letterSpacing: 0.4,
  );
  static TextStyle eyebrow = cochin(
    size: 11,
    letterSpacing: 1.4,
  );
}
