import 'package:flutter/material.dart';

class MirraColors {
  const MirraColors._();

  static const bg = Color(0xFFFAF7F2);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF171B2A);
  static const ink2 = Color(0xFF2A2F40);
  static const muted = Color(0xFF6B6F7E);
  static const muted2 = Color(0xFF9AA0AE);
  static const chip = Color(0xFFECE9F5);
  static const chipLine = Color(0xFFDDD8EC);
  // Lavender surface used by profile/settings tiles & rows (prototype #E9E6F2).
  static const tile = Color(0xFFE9E6F2);
  static const line = Color(0xFFECE7DE);
  static const line2 = Color(0xFFE5DFD3);
  static const accentA = Color(0xFFB79DE8);
  static const accentB = Color(0xFFF0B2A3);
  static const accentC = Color(0xFFF8D2A8);
  static const ok = Color(0xFF2BB673);
  static const danger = Color(0xFFE25C5C);

  static const grad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB79DE8), Color(0xFFE0AECB), Color(0xFFF0B2A3)],
    stops: [0.0, 0.5, 1.0],
  );

  static const gradSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEDE3F8), Color(0xFFFBE2D9)],
  );
}
