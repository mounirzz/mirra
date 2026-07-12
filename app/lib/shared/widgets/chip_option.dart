import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';

class ChipOption extends StatelessWidget {
  const ChipOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? MirraColors.ink : MirraColors.chip,
          borderRadius: BorderRadius.circular(MirraRadius.pill),
          border: Border.all(
            color: selected ? MirraColors.ink : MirraColors.chipLine,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : MirraColors.ink2,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: MirraType.carmenSans(
                size: 14,
                color: selected ? Colors.white : MirraColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
