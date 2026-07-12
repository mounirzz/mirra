import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/palette_provider.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';

class PrimaryButton extends ConsumerWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool gradient;
  final bool fullWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(themePaletteProvider).paletteOrFallback;
    final isEnabled = onPressed != null;
    final child = Container(
      height: 56,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: gradient
            ? null
            : (isEnabled ? MirraColors.ink : MirraColors.muted2),
        gradient: gradient ? palette.grad : null,
        borderRadius: BorderRadius.circular(MirraRadius.pill),
      ),
      child: Text(
        label,
        style: MirraType.carmenSans(size: 16, color: Colors.white),
      ),
    );

    return Opacity(
      opacity: isEnabled ? 1 : 0.6,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: fullWidth
            ? SizedBox(width: double.infinity, child: child)
            : child,
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: MirraColors.chipLine),
          borderRadius: BorderRadius.circular(MirraRadius.pill),
        ),
        child: Text(label, style: MirraType.carmenSans(size: 15)),
      ),
    );
  }
}
