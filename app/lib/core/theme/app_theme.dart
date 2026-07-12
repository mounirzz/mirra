import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class MirraTheme {
  const MirraTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: MirraColors.bg,
      colorScheme: const ColorScheme.light(
        primary: MirraColors.ink,
        onPrimary: Colors.white,
        secondary: MirraColors.accentA,
        surface: MirraColors.surface,
        onSurface: MirraColors.ink,
        error: MirraColors.danger,
      ),
      textTheme: GoogleFonts.interTextTheme(
        base.textTheme,
      ).apply(bodyColor: MirraColors.ink, displayColor: MirraColors.ink),
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
