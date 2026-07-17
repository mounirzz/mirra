import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Uppercase section label (PREMIUM, MAKE IT YOURS…), like Motivation's.
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: MirraType.carmenSans(
          size: 11,
          color: MirraColors.muted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// One tappable settings row: icon, label, chevron — soft rounded card.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Optional value shown before the chevron (e.g. current language).
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F2F8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: MirraColors.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: MirraType.cochin(size: 15, weight: FontWeight.w700),
                ),
              ),
              if (trailing != null) ...[
                Text(
                  trailing!,
                  style: MirraType.cochin(size: 13, color: MirraColors.muted),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: MirraColors.muted2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standard sub-screen scaffold: back row + big title + body.
class SettingsSubScreen extends StatelessWidget {
  const SettingsSubScreen({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.bottomBar,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: bottomBar!,
              ),
            ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: MirraColors.ink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Preferences',
                        style: MirraType.cochin(
                          size: 14,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                title,
                style: MirraType.cochin(size: 24, weight: FontWeight.w800),
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  subtitle!,
                  style: MirraType.cochin(
                    size: 14,
                    color: MirraColors.muted,
                    height: 1.35,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Full-width pill button (dark), used as bottom CTA on sub-screens.
class SettingsCta extends StatelessWidget {
  const SettingsCta({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MirraColors.ink,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: MirraType.carmenSans(size: 15, color: Colors.white),
        ),
      ),
    );
  }
}
