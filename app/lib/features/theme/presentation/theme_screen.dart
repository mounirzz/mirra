// Themes screen — matches the Mirra design: tabs, Theme mixes carousel,
// and a "For you" grid of theme tiles (each previews its background + "Aa" in
// the theme's own font). Selecting a tile applies the theme to the feed.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../app_theme_provider.dart';
import '../my_themes_provider.dart';
import '../theme_api.dart';
import '../theme_catalog.dart';
import 'theme_mix_card.dart';
import 'theme_tile.dart';

class ThemeScreen extends ConsumerStatefulWidget {
  const ThemeScreen({super.key});

  @override
  ConsumerState<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends ConsumerState<ThemeScreen> {
  static const _tabs = ['+ Create', 'All', 'New', 'Seasonal', 'Most popular', 'Recent'];
  String _tab = 'All';

  List<AppTheme> get _filtered {
    switch (_tab) {
      case 'New':
        return kAppThemes.where((t) => t.tags.contains('new')).toList();
      case 'Seasonal':
        return kAppThemes.where((t) => t.tags.contains('seasonal')).toList();
      case 'Most popular':
        return kAppThemes.where((t) => t.tags.contains('popular')).toList();
      default:
        return kAppThemes;
    }
  }

  /// The signed-in user's saved custom themes, shown above "For you".
  /// Hidden when signed out or the account has no saved themes.
  List<Widget> _myThemesSection() {
    final signedIn = ref.watch(isSignedInProvider);
    final mine = ref.watch(myThemesProvider);
    final isEmpty = mine.maybeWhen(data: (l) => l.isEmpty, orElse: () => false);
    if (!signedIn || isEmpty) return const [];
    return [
      const SizedBox(height: 22),
      Text('My themes',
          style: MirraType.cochin(size: 17, weight: FontWeight.w800)),
      const SizedBox(height: 12),
      SizedBox(
        height: 150,
        child: mine.when(
          data: (list) => ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _myThemeTile(list[i]),
          ),
          loading: () => const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, _) => Align(
            alignment: Alignment.centerLeft,
            child: Text('Couldn’t load your themes',
                style: MirraType.cochin(size: 13, color: MirraColors.muted)),
          ),
        ),
      ),
    ];
  }

  Widget _myThemeTile(RemoteTheme rt) {
    final font = ThemeFont.values.firstWhere(
      (f) => f.name == rt.font,
      orElse: () => ThemeFont.serif,
    );
    final textColor = Color(int.tryParse(rt.textColor, radix: 16) ?? 0xFFFFFFFF);
    final theme = AppTheme(
      id: 'custom',
      label: 'My theme',
      photoUrl: rt.imageUrl,
      font: font,
      textColor: textColor,
      dark: rt.dark,
      custom: true,
    );
    final active = ref.watch(appThemeProvider);
    final selected = active.custom && active.photoUrl == rt.imageUrl;
    return SizedBox(
      width: 108,
      child: GestureDetector(
        onTap: () {
          ref.read(appThemeProvider.notifier).applyRemoteTheme(rt);
          context.pop();
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Container(
              decoration:
                  theme.tileDecoration(BorderRadius.circular(14)).copyWith(
                        border: selected
                            ? Border.all(color: MirraColors.ink, width: 2.5)
                            : null,
                      ),
              alignment: Alignment.center,
              child: Text('Aa', style: theme.quoteStyle(26)),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () =>
                    ref.read(myThemesProvider.notifier).delete(rt.themeId),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.close_rounded,
                          size: 22, color: MirraColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                'Themes',
                style: MirraType.cochin(size: 24, weight: FontWeight.w800),
              ),
            ),
            // Tabs
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final t = _tabs[i];
                  final on = t == _tab;
                  return GestureDetector(
                    onTap: () {
                      if (t == '+ Create') {
                        context.push('/theme/create');
                      } else {
                        setState(() => _tab = t);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: on ? MirraColors.ink : const Color(0xFFE9E6F2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t,
                        style: MirraType.cochin(
                          size: 13,
                          weight: FontWeight.w500,
                          color: on ? Colors.white : MirraColors.ink,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Theme mixes',
                        style:
                            MirraType.cochin(size: 17, weight: FontWeight.w800),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/theme/mixes'),
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          'See all',
                          style: MirraType.cochin(
                            size: 13,
                            weight: FontWeight.w500,
                            color: MirraColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 76,
                    child: Row(
                      children: [
                        Expanded(
                          child: ThemeMixCard(
                            mix: kThemeMixes[2],
                            onTap: () => context.push('/theme/mixes'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push('/theme/mixes'),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFD7DBE8),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '+ ${kThemeMixes.length - 1}',
                                style: MirraType.cochin(
                                  size: 18,
                                  weight: FontWeight.w600,
                                  color: MirraColors.ink,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._myThemesSection(),
                  const SizedBox(height: 22),
                  Text(
                    'For you',
                    style: MirraType.cochin(size: 17, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final t = _filtered[i];
                      return ThemeTile(
                        theme: t,
                        selected: selected.id == t.id,
                        onTap: () {
                          ref.read(appThemeProvider.notifier).select(t);
                          context.pop();
                        },
                        onEdit: () => context.push('/theme/create'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
