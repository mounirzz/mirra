import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/palette_provider.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme_selection.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../../premium/providers/premium_provider.dart';

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themePaletteProvider);
    final notifier = ref.read(themePaletteProvider.notifier);
    final isPremium = ref.watch(isPremiumProvider);

    Widget sectionTitle(String label) => Padding(
      padding: const EdgeInsets.only(bottom: MirraSpace.sm),
      child: Text(
        label,
        style: MirraType.cochin(size: 15, weight: FontWeight.w700),
      ),
    );

    Widget grid(List<Widget> tiles) => GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: MirraSpace.sm,
      crossAxisSpacing: MirraSpace.sm,
      childAspectRatio: 0.78,
      children: tiles,
    );

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IosStatusSpacer(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: MirraSpace.lg),
                child: Row(
                  children: [
                    MirraBackButton(onTap: () => context.pop()),
                    const SizedBox(width: 8),
                    Text(
                      'Theme',
                      style: MirraType.cochin(
                        size: 26,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MirraSpace.md),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    MirraSpace.lg,
                    0,
                    MirraSpace.lg,
                    40,
                  ),
                  children: [
                    sectionTitle('Your photo'),
                    grid([
                      _ThemeTile(
                        label: current.kind == ThemeKind.customPhoto
                            ? 'Change'
                            : 'Import',
                        selected: current.kind == ThemeKind.customPhoto,
                        // Camera-roll backgrounds are a Mirra+ perk.
                        locked: !isPremium,
                        onTap: () {
                          if (!isPremium) {
                            context.push('/paywall');
                          } else {
                            notifier.pickCustomPhoto();
                          }
                        },
                        preview: current.kind == ThemeKind.customPhoto
                            ? Image(
                                image: current.imageProvider!,
                                fit: BoxFit.cover,
                              )
                            : const ColoredBox(
                                color: MirraColors.chip,
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: MirraColors.ink,
                                  size: 28,
                                ),
                              ),
                      ),
                    ]),
                    const SizedBox(height: MirraSpace.lg),
                    sectionTitle('Colors'),
                    grid([
                      for (final palette in MirraPalette.all)
                        _ThemeTile(
                          label: palette.label,
                          selected:
                              current.kind == ThemeKind.color &&
                              current.palette?.id == palette.id,
                          onTap: () => notifier.selectPalette(palette),
                          preview: DecoratedBox(
                            decoration: BoxDecoration(gradient: palette.grad),
                          ),
                        ),
                    ]),
                    const SizedBox(height: MirraSpace.lg),
                    sectionTitle('Photos'),
                    grid([
                      for (final photo in ThemePhoto.all)
                        _ThemeTile(
                          label: photo.label,
                          selected:
                              current.kind == ThemeKind.presetPhoto &&
                              current.presetPhoto?.id == photo.id,
                          locked: photo.premium && !isPremium,
                          onTap: () {
                            if (photo.premium && !isPremium) {
                              context.push('/paywall');
                            } else {
                              notifier.selectPresetPhoto(photo);
                            }
                          },
                          preview: Image.asset(photo.asset, fit: BoxFit.cover),
                        ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Square visual preview + name, with an ink border and a check badge when
/// selected — the whole catalog is scannable at a glance.
class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.preview,
    required this.label,
    required this.selected,
    required this.onTap,
    this.locked = false,
  });

  final Widget preview;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Mirra+ theme shown with a lock badge; tapping opens the paywall.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MirraRadius.md),
                border: Border.all(
                  color: selected ? MirraColors.ink : MirraColors.line,
                  width: selected ? 2.5 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(MirraRadius.md - 2),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    preview,
                    if (locked)
                      Container(
                        color: Colors.black.withValues(alpha: 0.25),
                        alignment: Alignment.center,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.lock_rounded,
                              color: MirraColors.ink,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    if (selected)
                      const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: MirraColors.ink,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MirraType.cochin(
              size: 12,
              weight: FontWeight.w700,
              color: selected ? MirraColors.ink : MirraColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
