import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class MirraType {
  const MirraType._();

  static TextStyle serif({
    double size = 28,
    Color color = MirraColors.ink,
    FontWeight weight = FontWeight.w400,
    double? height,
    FontStyle style = FontStyle.normal,
  }) {
    return GoogleFonts.instrumentSerif(
      fontSize: size,
      color: color,
      fontWeight: weight,
      fontStyle: style,
      height: height,
      letterSpacing: 0.005 * size,
    );
  }

  static TextStyle ui({
    double size = 15,
    Color color = MirraColors.ink,
    FontWeight weight = FontWeight.w400,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle mono({
    double size = 12,
    Color color = MirraColors.muted,
    FontWeight weight = FontWeight.w400,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      color: color,
      fontWeight: weight,
    );
  }

  static TextStyle carmenSans({
    double size = 16,
    Color color = MirraColors.ink,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'CarmenSans',
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w800,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle cochin({
    double size = 15,
    Color color = MirraColors.ink,
    FontWeight weight = FontWeight.w400,
    FontStyle style = FontStyle.normal,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Cochin',
      fontSize: size,
      color: color,
      fontWeight: weight,
      fontStyle: style,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle hero = serif(size: 44, height: 1.05);
  static TextStyle title = serif(size: 32, height: 1.1);
  static TextStyle quoteCard = serif(size: 30, height: 1.18);
  static TextStyle bodyUi = ui(size: 15, color: MirraColors.ink, height: 1.4);
  static TextStyle labelUi = ui(
    size: 13,
    color: MirraColors.muted,
    weight: FontWeight.w500,
    letterSpacing: 0.4,
  );
  static TextStyle eyebrow = cochin(
    size: 11,
    weight: FontWeight.w500,
    letterSpacing: 1.4,
  );
}
