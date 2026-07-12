import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/palette_provider.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../../home/providers/quotes_provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoritesProvider);
    final all = ref.watch(allQuotesProvider);
    final items = all.where((q) => favs.contains(q.id)).toList();

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
                      'Favorites',
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
                child: items.isEmpty
                    ? _EmptyFavorites(
                        palette: ref
                            .watch(themePaletteProvider)
                            .paletteOrFallback,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          MirraSpace.lg,
                          0,
                          MirraSpace.lg,
                          80,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (context, i) =>
                            const SizedBox(height: MirraSpace.sm),
                        itemBuilder: (context, i) {
                          final q = items[i];
                          return Container(
                            padding: const EdgeInsets.all(MirraSpace.md),
                            decoration: BoxDecoration(
                              color: MirraColors.surface,
                              borderRadius: BorderRadius.circular(
                                MirraRadius.lg,
                              ),
                              border: Border.all(color: MirraColors.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q.text,
                                  style: MirraType.serif(size: 18, height: 1.3),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '— ${q.author}',
                                      style: MirraType.cochin(
                                        size: 12,
                                        color: MirraColors.muted,
                                      ),
                                    ),
                                    TapIcon(
                                      icon: Icons.favorite,
                                      color: MirraColors.danger,
                                      size: 18,
                                      semanticLabel: 'Remove from favorites',
                                      onTap: () => ref
                                          .read(favoritesProvider.notifier)
                                          .toggle(q.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.palette});

  final MirraPalette palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: palette.gradSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 32,
                color: MirraColors.ink,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No favorites yet',
              style: MirraType.cochin(
                size: 24,
                weight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart on a quote to keep it here.',
              textAlign: TextAlign.center,
              style: MirraType.cochin(size: 14, color: MirraColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
