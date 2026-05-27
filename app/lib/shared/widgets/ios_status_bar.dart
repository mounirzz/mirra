import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// Lightweight status-bar spacer that mirrors the prototype's 50px safe area.
class IosStatusSpacer extends StatelessWidget {
  const IosStatusSpacer({super.key, this.height = 50});
  final double height;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SizedBox(height: top > 0 ? top : height);
  }
}

class IosHomeIndicator extends StatelessWidget {
  const IosHomeIndicator({super.key, this.dark = false});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Center(
        child: Container(
          width: 134,
          height: 5,
          decoration: BoxDecoration(
            color: dark ? Colors.white : MirraColors.ink,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
