import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../providers/app_icon_provider.dart';

/// Motivation-style "which icon style do you like the most?" step, shown inside
/// onboarding right after the streak intro: a 3×3 grid of Mirra home-screen
/// icons the user can pick from. Rendered inline via [onContinue]/[onBack].
class AppIconPickerScreen extends ConsumerWidget {
  const AppIconPickerScreen({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  final VoidCallback onContinue;
  final VoidCallback onBack;

  /// Applies the picked logo as the real iOS home-screen icon. The nth tile
  /// maps to the alternate icon "AppIconAlt{n}" declared in Info.plist.
  ///
  /// Fire-and-forget on purpose: we do NOT await this from the Continue button,
  /// because the underlying platform call presents a system confirmation alert
  /// and, in silent mode, the plugin can leave its result callback pending.
  /// Blocking onboarding on it would trap the user on this screen. We use the
  /// public API (isSilent: false) which reliably invokes its completion.
  static Future<void> applyIcon(int index) async {
    try {
      final supported = await FlutterDynamicIconPlus.supportsAlternateIcons;
      if (!supported) return;
      await FlutterDynamicIconPlus.setAlternateIconName(
        iconName: 'AppIconAlt${index + 1}',
      );
    } catch (_) {
      // Unsupported platform or user cancelled — leave the icon unchanged.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedAppIconProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: PrimaryButton(
            label: ref.tr('Continue'),
            onPressed: () {
              // Fire-and-forget so the user is never blocked by the icon-swap
              // system alert; advance immediately.
              applyIcon(ref.read(selectedAppIconProvider));
              onContinue();
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: TapIcon(
                icon: Icons.arrow_back_ios_new_rounded,
                size: 18,
                semanticLabel: 'Back',
                onTap: onBack,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  ref.tr('Which icon style\ndo you like the most?'),
                  textAlign: TextAlign.center,
                  style: MirraType.cochin(
                    size: 26,
                    weight: FontWeight.w800,
                    height: 1.2,
                    color: MirraColors.ink,
                  ),
                ),
              ),
            ),
            // Grid sits low on the screen (like the reference), just above
            // the Continue button, with generous side padding so the tiles
            // stay compact.
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 48),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: kAppIconAssets.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, i) => _IconTile(
                      asset: kAppIconAssets[i],
                      index: i,
                      selected: selected == i,
                      onTap: () =>
                          ref.read(selectedAppIconProvider.notifier).state = i,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.asset,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final String asset;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected
                    ? MirraColors.accentA
                    : const Color(0xFFE9E6F1),
                width: selected ? 2.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                // Graceful placeholder until the real logos are dropped in.
                errorBuilder: (context, error, stack) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F2F8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: MirraType.cochin(
                      size: 22,
                      weight: FontWeight.w800,
                      color: MirraColors.muted2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (selected)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B6FD6), Color(0xFFE99BB0)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
