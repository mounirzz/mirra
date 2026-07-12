import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/theme_selection.dart';
import '../../core/theme/typography.dart';
import '../../shared/models/quote.dart';

/// The image people actually receive when a quote is shared: a full-bleed
/// story-format card (9:16) in the user's active theme, with a discreet
/// Mirra wordmark. Rendered off-screen and captured to PNG.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.quote, required this.selection});

  final Quote quote;
  final ThemeSelection selection;

  static const double width = 405;
  static const double height = 720;

  @override
  Widget build(BuildContext context) {
    final palette = selection.paletteOrFallback;
    final onPhoto = selection.isPhoto;
    final textColor = onPhoto ? Colors.white : MirraColors.ink;
    final mutedColor = onPhoto
        ? Colors.white.withValues(alpha: 0.8)
        : MirraColors.muted;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          image: onPhoto
              ? DecorationImage(
                  image: selection.imageProvider!,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.35),
                    BlendMode.darken,
                  ),
                )
              : null,
          gradient: onPhoto
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    palette.accentA.withValues(alpha: 0.30),
                    MirraColors.bg,
                    palette.accentB.withValues(alpha: 0.32),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quote.category.label.toUpperCase(),
              style: MirraType.eyebrow.copyWith(color: mutedColor),
            ),
            const Spacer(),
            Text(
              quote.text,
              style: MirraType.serif(size: 36, height: 1.2, color: textColor),
            ),
            const SizedBox(height: 24),
            Text(
              '—  ${quote.author}',
              style: MirraType.cochin(
                size: 15,
                color: mutedColor,
                weight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                'Mirra',
                style: MirraType.serif(
                  size: 20,
                  color: mutedColor,
                  style: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
