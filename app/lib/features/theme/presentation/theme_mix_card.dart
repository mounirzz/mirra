// A theme-mix category card (ANIMATED, Most popular, Seasonal, …) — a photo or
// solid tile with the mix label rendered in its own styled font.

import 'package:flutter/material.dart';

import '../theme_catalog.dart';

class ThemeMixCard extends StatelessWidget {
  const ThemeMixCard({
    super.key,
    required this.mix,
    required this.onTap,
    this.radius = 14,
    this.labelSize = 15,
  });

  final ThemeMix mix;
  final VoidCallback onTap;
  final double radius;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = mix.bgImage != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: mix.solid,
          borderRadius: BorderRadius.circular(radius),
          image: hasPhoto
              ? DecorationImage(
                  image: mix.bgImage!,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasPhoto)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.4),
                      ],
                      stops: const [0.3, 1],
                    ),
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    mix.label,
                    textAlign: TextAlign.center,
                    style: mix.labelStyle(labelSize).copyWith(
                      shadows: hasPhoto
                          ? const [
                              Shadow(
                                color: Color(0x66000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
