import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// Icon button that guarantees Apple's 44pt minimum touch target and a
/// VoiceOver label, while keeping the app's flat no-ripple look.
class TapIcon extends StatelessWidget {
  const TapIcon({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.size = 22,
    this.color = MirraColors.ink,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}

/// The standard back chevron used across screens.
class MirraBackButton extends StatelessWidget {
  const MirraBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapIcon(
      icon: Icons.arrow_back_ios_new_rounded,
      size: 18,
      onTap: onTap,
      semanticLabel: 'Back',
    );
  }
}
