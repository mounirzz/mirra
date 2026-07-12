import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/palette_provider.dart';

/// Wraps a screen body so it renders either the flat app background color
/// or the user's chosen photo theme (with a scrim so foreground text and
/// controls stay legible on top of it).
class AppBackground extends ConsumerWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(themePaletteProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (selection.isPhoto)
          Image(image: selection.imageProvider!, fit: BoxFit.cover)
        else
          const ColoredBox(color: MirraColors.bg),
        if (selection.isPhoto)
          Container(color: Colors.white.withValues(alpha: 0.72)),
        child,
      ],
    );
  }
}
