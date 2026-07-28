import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/palette_provider.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/i18n/language_provider.dart';
import '../../../data/seed_quotes_fr.dart';
import '../../../shared/models/quote.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/glass.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../flames/flame_api.dart';
import '../../premium/providers/premium_provider.dart';
import '../../voice/voice_service.dart';
import '../../premium/upsell_sheet.dart';
import '../../share/share_card.dart';
import '../../streak/providers/streak_provider.dart';
import '../../theme/app_theme_provider.dart';
import '../../theme/theme_catalog.dart';
import '../providers/quotes_provider.dart';
import 'nav_asset_icon.dart';
import 'nav_glyphs.dart';
import 'quote_boosts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _controller = PageController();
  late bool _showSwipeHint = !MirraBoxes.current.seenSwipeHint;

  void _onPageChanged(int i) {
    HapticFeedback.selectionClick();
    ref.read(currentQuoteIndexProvider.notifier).state = i;
    if (_showSwipeHint) {
      setState(() => _showSwipeHint = false);
      MirraBoxes.updatePrefs((p) => p.copyWith(seenSwipeHint: true));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotes = ref.watch(filteredQuotesProvider);
    final favs = ref.watch(favoritesProvider);
    final hasEndCard = ref.watch(feedHasEndCardProvider);

    return Scaffold(
      body: AppBackground(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              scrollDirection: Axis.vertical,
              itemCount: quotes.length + (hasEndCard ? 1 : 0),
              onPageChanged: _onPageChanged,
              itemBuilder: (context, i) {
                if (i == quotes.length) return const _EndOfFeedCard();
                final q = quotes[i];
                return _QuoteCard(
                  quote: q,
                  isFavorite: favs.contains(q.id),
                  onFavorite: () async {
                    final added = await ref
                        .read(favoritesProvider.notifier)
                        .toggle(q.id);
                    if (!added && context.mounted) {
                      await showUpsellSheet(
                        context,
                        title: ref.tr('Your favorites are full'),
                        subtitle: ref.tr(
                          'The free plan keeps your 2 favorites.\n'
                          'Go unlimited with Mirra+.',
                        ),
                      );
                    }
                    return added;
                  },
                );
              },
            ),
            const _TopBar(),
            const _BottomNav(),
            if (_showSwipeHint) const _SwipeHint(),
            const _StreakCelebration(),
          ],
        ),
      ),
    );
  }
}

/// Closing card at the end of the daily stack: the free batch is done, the
/// upgrade is the way to keep going today.
class _EndOfFeedCard extends StatelessWidget {
  const _EndOfFeedCard();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 100, 40, 140),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🌙',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'You’ve seen it all for now',
              textAlign: TextAlign.center,
              style: MirraType.serif(size: 30, height: 1.2),
            ),
            const SizedBox(height: 10),
            Text(
              'Come back tomorrow — or go unlimited with Mirra+.',
              textAlign: TextAlign.center,
              style: MirraType.cochin(size: 15, color: MirraColors.muted),
            ),
            const SizedBox(height: 36),
            PrimaryButton(
              label: 'Get Mirra+',
              gradient: true,
              onPressed: () => context.push('/paywall'),
            ),
          ],
        ),
      ),
    );
  }
}

/// One-time hint shown on the very first visit to the feed: a chevron that
/// drifts upward on loop, just above the bottom nav. Gone forever after the
/// first swipe.
class _SwipeHint extends StatefulWidget {
  const _SwipeHint();

  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 110,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_controller.value);
            return Opacity(
              opacity: (1 - t) * 0.85,
              child: Transform.translate(
                offset: Offset(0, -22 * t),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 34,
                      color: MirraColors.ink,
                    ),
                    Text(
                      'Swipe up',
                      style: MirraType.cochin(
                        size: 13,
                        weight: FontWeight.w700,
                        color: MirraColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Full-screen transient overlay that plays once when the daily streak goes
/// up: a flame + count scales in over a dim scrim, holds, and fades away.
class _StreakCelebration extends ConsumerStatefulWidget {
  const _StreakCelebration();

  @override
  ConsumerState<_StreakCelebration> createState() => _StreakCelebrationState();
}

class _StreakCelebrationState extends ConsumerState<_StreakCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ref.read(streakProvider.notifier).dismissCelebration();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(streakProvider).justIncreased) {
        HapticFeedback.mediumImpact();
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider);
    if (!streak.justIncreased) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // Fade in over the first 15%, hold, fade out over the last 25%.
        final opacity = t < 0.15
            ? t / 0.15
            : t > 0.75
            ? (1 - t) / 0.25
            : 1.0;
        final scale =
            0.7 + 0.3 * Curves.elasticOut.transform((t / 0.4).clamp(0.0, 1.0));
        return IgnorePointer(
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
              alignment: Alignment.center,
              child: Transform.scale(
                scale: scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 72)),
                    const SizedBox(height: 8),
                    Text(
                      '${streak.count}',
                      style: MirraType.carmenSans(
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'day streak',
                      style: MirraType.cochin(
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.85),
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuoteCard extends ConsumerStatefulWidget {
  const _QuoteCard({
    required this.quote,
    required this.isFavorite,
    required this.onFavorite,
  });

  final Quote quote;
  final bool isFavorite;

  /// Returns whether the like went through (false = blocked by the
  /// free-plan limit, the upsell is shown by the caller).
  final Future<bool> Function() onFavorite;

  @override
  ConsumerState<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends ConsumerState<_QuoteCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heartController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  Quote get quote => widget.quote;
  bool get isFavorite => widget.isFavorite;

  /// Reads the current affirmation aloud with the selected voice.
  void _speak() {
    HapticFeedback.lightImpact();
    ref.read(voiceServiceProvider).speak(quote.text);
  }

  /// Records an engagement (earns flames + teaches the model what resonated).
  void _engage(String action) {
    // Instant, offline flame growth on the badge.
    ref.read(localFlamesProvider.notifier).bump(action);
    // Server-backed engagement level (best-effort, signed-in only).
    ref.read(flameProvider.notifier).record(
          action,
          text: quote.text,
          topic: quote.categoryId,
        );
  }

  Future<void> _onDoubleTap() async {
    HapticFeedback.mediumImpact();
    // Instagram rule: double-tap always likes, never unlikes.
    if (!isFavorite) {
      final added = await widget.onFavorite();
      if (!added) return; // blocked → upsell is showing, skip the heart
      _engage('like');
    }
    _heartController.forward(from: 0);
  }

  /// Renders the quote as a story-format image card in the active theme and
  /// opens the share sheet with it.
  Future<void> _shareQuote(BuildContext context) async {
    HapticFeedback.lightImpact();
    final selection = ref.read(themePaletteProvider);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    // Decode the background photo first so the off-screen render isn't blank.
    final provider = selection.imageProvider;
    if (provider != null) await precacheImage(provider, context);
    if (!mounted) return;

    final bytes = await ScreenshotController().captureFromWidget(
      ShareCard(quote: quote, selection: selection),
      delay: const Duration(milliseconds: 80),
      pixelRatio: 3,
      targetSize: const Size(ShareCard.width, ShareCard.height),
      context: this.context,
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/mirra_quote.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([
      XFile(file.path, mimeType: 'image/png'),
    ], sharePositionOrigin: origin);
    _engage('share');
  }

  void _copyQuote(BuildContext context) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: '${quote.text}\n— ${quote.author}'));
    _engage('copy');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Copied ✓',
            textAlign: TextAlign.center,
            style: MirraType.cochin(
              size: 14,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: MirraColors.ink.withValues(alpha: 0.92),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MirraRadius.pill),
          ),
          margin: const EdgeInsets.fromLTRB(120, 0, 120, 110),
          duration: const Duration(milliseconds: 1400),
          elevation: 0,
        ),
      );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final onDark = theme.dark || theme.isPhoto || theme.custom;
    // Glass-control foreground: white on dark backgrounds, ink on light ones.
    final navFg = theme.dark ? Colors.white : MirraColors.ink;
    final localized = localizedQuoteText(
      quote.id,
      quote.text,
      ref.watch(languageProvider).code,
    );
    final quoteText = theme.caps ? localized.toUpperCase() : localized;
    return Container(
      decoration: _themeBackground(theme),
      child: GestureDetector(
        onDoubleTap: _onDoubleTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                // Right padding clears the TikTok action rail (50px buttons
                // + 16px margin) so long lines never slide under it.
                padding: const EdgeInsets.fromLTRB(28, 100, 92, 140),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr(quote.category.label).toUpperCase(),
                      style: MirraType.eyebrow.copyWith(
                        color: onDark
                            ? Colors.white.withValues(alpha: 0.75)
                            : MirraColors.muted,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      quoteText,
                      style: theme.quoteStyle(34).copyWith(height: 1.18),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      ref.tr(boostFor(quote)),
                      style: MirraType.cochin(
                        size: 17,
                        color: onDark
                            ? Colors.white.withValues(alpha: 0.85)
                            : MirraColors.ink2,
                        weight: FontWeight.w700,
                        style: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action rail: like / copy / share as three separate glass buttons
            // stacked on the right edge, vertically centered.
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CircleAction(
                        icon: Icons.volume_up_rounded,
                        iconColor: navFg,
                        semanticLabel: 'Read aloud',
                        onTap: _speak,
                      ),
                      const SizedBox(height: 12),
                      _CircleAction(
                        icon: isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border_rounded,
                        iconColor: isFavorite
                            ? MirraColors.danger
                            : navFg,
                        semanticLabel: isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          final wasFavorite = isFavorite;
                          final added = await widget.onFavorite();
                          if (added && !wasFavorite) _engage('like');
                        },
                      ),
                      const SizedBox(height: 12),
                      _CircleAction(
                        icon: Icons.copy_rounded,
                        iconColor: navFg,
                        semanticLabel: 'Copy quote',
                        onTap: () => _copyQuote(context),
                      ),
                      const SizedBox(height: 12),
                      _CircleAction(
                        icon: Icons.ios_share_rounded,
                        iconColor: navFg,
                        semanticLabel: 'Share quote',
                        onTap: () => _shareQuote(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Big heart that pulses in the center on double-tap, then fades.
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _heartController,
                  builder: (context, _) {
                    final t = _heartController.value;
                    if (_heartController.isDismissed) {
                      return const SizedBox.shrink();
                    }
                    final scale = 0.4 + 0.6 * Curves.elasticOut.transform(t);
                    final opacity = t > 0.7
                        ? ((1 - t) / 0.3).clamp(0.0, 1.0)
                        : 1.0;
                    return Center(
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: Icon(
                            Icons.favorite,
                            size: 110,
                            color: MirraColors.danger.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Builds the feed background for the active theme: a custom photo file, a
/// network photo, a gradient, or a flat colour. Photos get a soft dark scrim
/// so light text and the glass controls stay legible.
BoxDecoration _themeBackground(AppTheme theme) {
  final customFile = theme.custom ? activeCustomPhotoFile() : null;
  final ImageProvider? image =
      customFile != null ? FileImage(customFile) : theme.bgImage;
  if (image != null) {
    return BoxDecoration(
      image: DecorationImage(
        image: image,
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: 0.28),
          BlendMode.darken,
        ),
      ),
    );
  }
  if (theme.gradient != null) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: theme.gradient!,
      ),
    );
  }
  return BoxDecoration(color: theme.solid ?? MirraColors.bg);
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.iconColor = MirraColors.ink,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Glass(
          radius: 999,
          width: 50,
          height: 50,
          child: Center(child: Icon(icon, color: iconColor, size: 22)),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoritesProvider);
    final theme = ref.watch(appThemeProvider);
    final fg = theme.dark ? Colors.white : MirraColors.ink;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              TapIcon(
                icon: Icons.tune_rounded,
                color: fg,
                semanticLabel: 'Reminder preferences',
                onTap: () => context.push('/preferences'),
              ),
              TapIcon(
                icon: Icons.add_circle_outline_rounded,
                color: fg,
                semanticLabel: 'My affirmations',
                onTap: () => context.push('/my-quotes'),
              ),
              const Spacer(),
              const _StreakBadge(),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => context.push('/favorites'),
                behavior: HitTestBehavior.opaque,
                child: Glass(
                  radius: MirraRadius.pill,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 16,
                        color: fg,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ref.watch(isPremiumProvider)
                            ? '${favs.length}'
                            : '${favs.length}/${FavoritesNotifier.freeLimit}',
                        style: MirraType.cochin(
                          size: 12,
                          weight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ],
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

/// Consecutive-days counter pinned to the top bar, with a flame that softly
/// pulses and sways in a loop. Tapping it opens the profile.
class _StreakBadge extends ConsumerStatefulWidget {
  const _StreakBadge();

  @override
  ConsumerState<_StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends ConsumerState<_StreakBadge>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  // One-shot "pop" played each time the flame count goes up.
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void dispose() {
    _controller.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider).count;
    // Interactive flames grow instantly on every like/share/copy (offline).
    // Fall back to the server engagement level, then the day streak.
    final localFlamesState = ref.watch(localFlamesProvider);
    final localFlames = localFlamesState.count;
    final flames = ref.watch(flameProvider).points;
    final display = localFlames > 0
        ? localFlames
        : (flames > 0 ? flames : streak);
    final theme = ref.watch(appThemeProvider);
    final fg = theme.dark ? Colors.white : MirraColors.ink;

    // When a bump lands, play the pop once and clear the flag.
    ref.listen<LocalFlamesState>(localFlamesProvider, (prev, next) {
      if (next.lastDelta > 0) {
        _pop.forward(from: 0);
        Future.microtask(
          () => ref.read(localFlamesProvider.notifier).clearDelta(),
        );
      }
    });

    return GestureDetector(
      onTap: () => context.push('/streak'),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _pop,
        builder: (context, child) {
          // A quick swell that settles back to normal size.
          final p = Curves.easeOut.transform(_pop.value);
          final swell = 1 + 0.28 * (p < 0.5 ? p * 2 : (1 - p) * 2);
          return Transform.scale(scale: swell, child: child);
        },
        child: Glass(
          radius: MirraRadius.pill,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = Curves.easeInOut.transform(_controller.value);
                  return Transform.rotate(
                    angle: (t - 0.5) * 0.22,
                    child:
                        Transform.scale(scale: 0.92 + 0.18 * t, child: child),
                  );
                },
                child: const Text('🔥', style: TextStyle(fontSize: 15)),
              ),
              const SizedBox(width: 5),
              Text(
                '$display',
                style: MirraType.cochin(
                  size: 13,
                  weight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Adapt the nav foreground to the active theme: white on dark backgrounds,
    // ink on light/near-white ones.
    final theme = ref.watch(appThemeProvider);
    final fg = theme.dark ? Colors.white : MirraColors.ink;
    return Positioned(
      left: 20,
      right: 20,
      bottom: 28,
      child: SafeArea(
        top: false,
        child: Glass(
          radius: MirraRadius.pill,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Expanded(
                child: _NavIcon(
                  iconBuilder: (c) => MixGridIcon(size: 28, color: c),
                  label: ref.tr('Mix'),
                  route: '/mix',
                  fg: fg,
                ),
              ),
              Expanded(
                child: _NavIcon(
                  iconBuilder: (c) => NavAssetIcon(
                    base: 'theme',
                    size: 28,
                    color: c,
                    fallback: ThemePaletteIcon(size: 28, color: c),
                  ),
                  label: ref.tr('Theme'),
                  route: '/theme',
                  fg: fg,
                ),
              ),
              Expanded(
                child: _NavIcon(
                  iconBuilder: (c) => NavAssetIcon(
                    base: 'user',
                    size: 28,
                    color: c,
                    fallback: ProfileUserIcon(size: 28, color: c),
                  ),
                  label: ref.tr('Profile'),
                  route: '/profile',
                  fg: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.iconBuilder,
    required this.label,
    required this.route,
    required this.fg,
  });
  final Widget Function(Color) iconBuilder;
  final String label;
  final String route;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(route),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconBuilder(fg),
          const SizedBox(height: 2),
          Text(
            label,
            style: MirraType.carmenSans(
              size: 11,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
