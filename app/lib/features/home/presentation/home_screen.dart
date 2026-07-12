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
import '../../../shared/models/quote.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../premium/providers/premium_provider.dart';
import '../../premium/upsell_sheet.dart';
import '../../share/share_card.dart';
import '../../streak/providers/streak_provider.dart';
import '../providers/quotes_provider.dart';
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
                      await showUpsellSheet(context);
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

  Future<void> _onDoubleTap() async {
    HapticFeedback.mediumImpact();
    // Instagram rule: double-tap always likes, never unlikes.
    if (!isFavorite) {
      final added = await widget.onFavorite();
      if (!added) return; // blocked → upsell is showing, skip the heart
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
  }

  void _copyQuote(BuildContext context) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: '${quote.text}\n— ${quote.author}'));
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
    final selection = ref.watch(themePaletteProvider);
    final palette = selection.paletteOrFallback;
    return Container(
      decoration: BoxDecoration(
        image: selection.isPhoto
            ? DecorationImage(
                image: selection.imageProvider!,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.28),
                  BlendMode.darken,
                ),
              )
            : null,
        gradient: selection.isPhoto
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.accentA.withValues(alpha: 0.18),
                  MirraColors.bg,
                  palette.accentB.withValues(alpha: 0.20),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
      ),
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
                      quote.category.label.toUpperCase(),
                      style: MirraType.eyebrow.copyWith(
                        color: MirraColors.muted,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      quote.text,
                      style: MirraType.serif(
                        size: 34,
                        height: 1.18,
                        color: MirraColors.ink,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      boostFor(quote),
                      style: MirraType.cochin(
                        size: 17,
                        color: MirraColors.ink2,
                        weight: FontWeight.w700,
                        style: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // TikTok-style action rail: like / copy / share stacked on the
            // right edge, vertically centered like TikTok's.
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CircleAction(
                        icon: isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border_rounded,
                        iconColor: isFavorite
                            ? MirraColors.danger
                            : MirraColors.ink,
                        semanticLabel: isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onFavorite();
                        },
                      ),
                      const SizedBox(height: 14),
                      _CircleAction(
                        icon: Icons.copy_rounded,
                        semanticLabel: 'Copy quote',
                        onTap: () => _copyQuote(context),
                      ),
                      const SizedBox(height: 14),
                      Builder(
                        builder: (context) => _CircleAction(
                          icon: Icons.ios_share_rounded,
                          semanticLabel: 'Share quote',
                          onTap: () => _shareQuote(context),
                        ),
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
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(color: MirraColors.line),
          ),
          child: Icon(icon, color: iconColor, size: 22),
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
                semanticLabel: 'Reminder preferences',
                onTap: () => context.push('/preferences'),
              ),
              TapIcon(
                icon: Icons.add_circle_outline_rounded,
                semanticLabel: 'My affirmations',
                onTap: () => context.push('/my-quotes'),
              ),
              const Spacer(),
              const _StreakBadge(),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => context.push('/favorites'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(MirraRadius.pill),
                    border: Border.all(color: MirraColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite_border_rounded,
                        size: 16,
                        color: MirraColors.ink,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ref.watch(isPremiumProvider)
                            ? '${favs.length}'
                            : '${favs.length}/5',
                        style: MirraType.cochin(
                          size: 12,
                          weight: FontWeight.w700,
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider).count;

    return GestureDetector(
      onTap: () => context.push('/profile'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(MirraRadius.pill),
          border: Border.all(color: MirraColors.line),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = Curves.easeInOut.transform(_controller.value);
                return Transform.rotate(
                  angle: (t - 0.5) * 0.22,
                  child: Transform.scale(scale: 0.92 + 0.18 * t, child: child),
                );
              },
              child: const Text('🔥', style: TextStyle(fontSize: 15)),
            ),
            const SizedBox(width: 5),
            Text(
              '$streak',
              style: MirraType.cochin(size: 13, weight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 28,
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(MirraRadius.pill),
            border: Border.all(color: MirraColors.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavIcon(
                icon: Icons.auto_awesome_rounded,
                label: 'Mix',
                onTap: () => context.push('/mix'),
              ),
              _NavIcon(
                icon: Icons.palette_outlined,
                label: 'Theme',
                onTap: () => context.push('/theme'),
              ),
              _NavIcon(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                onTap: () => context.push('/profile'),
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
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: MirraColors.ink, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: MirraType.cochin(
              size: 10,
              color: MirraColors.muted,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
