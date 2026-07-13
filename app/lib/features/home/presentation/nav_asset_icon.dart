// Loads a navbar icon from an asset the user drops into assets/icons/.
// Tries <base>.svg then <base>.png; tints it to the nav ink colour. Until the
// file exists it renders [fallback] (the hand-drawn vector), so the build never
// breaks and the icon appears automatically once the file is added.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

class NavAssetIcon extends StatelessWidget {
  const NavAssetIcon({
    super.key,
    required this.base,
    required this.size,
    required this.color,
    required this.fallback,
  });

  final String base; // e.g. 'theme' or 'user'
  final double size;
  final Color color;
  final Widget fallback;

  Future<_Resolved?> _resolve() async {
    for (final ext in const ['svg', 'png']) {
      final path = 'assets/icons/$base.$ext';
      try {
        await rootBundle.load(path);
        return _Resolved(path, ext == 'svg');
      } catch (_) {
        // not present, try next
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Resolved?>(
      future: _resolve(),
      builder: (context, snap) {
        final r = snap.data;
        if (r == null) return fallback;
        if (r.isSvg) {
          return SvgPicture.asset(
            r.path,
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          );
        }
        return Image.asset(
          r.path,
          width: size,
          height: size,
          color: color,
        );
      },
    );
  }
}

class _Resolved {
  const _Resolved(this.path, this.isSvg);
  final String path;
  final bool isSvg;
}
