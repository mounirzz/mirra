// A single theme tile in the "For you" grid: previews the theme background and
// shows "Aa" in the theme's own font/colour. Selected tiles get a ring, an
// "Edit" pill and a play badge (for animated ones).

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../theme_catalog.dart';

class ThemeTile extends StatelessWidget {
  const ThemeTile({
    super.key,
    required this.theme,
    required this.selected,
    required this.onTap,
    required this.onEdit,
  });

  final AppTheme theme;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final animated = theme.tags.contains('new') || theme.id == 'cabin';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: theme.tileDecoration(BorderRadius.circular(14)).copyWith(
              border: Border.all(
                color: selected ? MirraColors.ink : const Color(0x14000000),
                width: selected ? 2 : 1,
              ),
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (theme.isPhoto)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.35),
                      ],
                      stops: const [0.4, 1],
                    ),
                  ),
                ),
              Center(
                child: Text('Aa', style: theme.quoteStyle(26)),
              ),
              if (animated)
                Positioned(
                  top: 6,
                  left: 6,
                  child: _badge(
                    const Icon(Icons.play_arrow_rounded,
                        size: 12, color: Colors.white),
                  ),
                ),
              if (selected) ...[
                Positioned(
                  top: 6,
                  right: 6,
                  child: _badge(
                    const Icon(Icons.check_rounded,
                        size: 12, color: Colors.white),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: GestureDetector(
                    onTap: onEdit,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Edit',
                        style: MirraType.cochin(
                          size: 11,
                          weight: FontWeight.w600,
                          color: MirraColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(Widget child) => Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      );
}
