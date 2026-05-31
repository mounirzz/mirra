import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/quote.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../providers/quotes_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotes = ref.watch(filteredQuotesProvider);
    final favs = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: MirraColors.bg,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            itemCount: quotes.length,
            onPageChanged: (i) =>
                ref.read(currentQuoteIndexProvider.notifier).state = i,
            itemBuilder: (context, i) {
              final q = quotes[i];
              return _QuoteCard(
                quote: q,
                isFavorite: favs.contains(q.id),
                onFavorite: () =>
                    ref.read(favoritesProvider.notifier).toggle(q.id),
              );
            },
          ),
          const _TopBar(),
          const _BottomNav(),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.isFavorite,
    required this.onFavorite,
  });

  final Quote quote;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MirraColors.accentA.withValues(alpha: 0.18),
            MirraColors.bg,
            MirraColors.accentB.withValues(alpha: 0.20),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 100, 28, 140),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quote.category.label.toUpperCase(),
                style: MirraType.eyebrow.copyWith(color: MirraColors.muted),
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
                '\u2014  ${quote.author}',
                style: MirraType.ui(
                  size: 13,
                  color: MirraColors.muted,
                  weight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _CircleAction(
                    icon: isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border_rounded,
                    iconColor: isFavorite ? MirraColors.danger : MirraColors.ink,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onFavorite();
                    },
                  ),
                  const Spacer(),
                  _CircleAction(
                    icon: Icons.copy_rounded,
                    onTap: () => Clipboard.setData(
                      ClipboardData(text: '${quote.text}\n— ${quote.author}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CircleAction(
                    icon: Icons.ios_share_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    this.iconColor = MirraColors.ink,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.tune_rounded,
                    color: MirraColors.ink, size: 22),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/favorites'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(MirraRadius.pill),
                    border: Border.all(color: MirraColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_border_rounded,
                          size: 16, color: MirraColors.ink),
                      const SizedBox(width: 6),
                      Text(
                        '${favs.length}/5',
                        style: MirraType.ui(
                          size: 12,
                          weight: FontWeight.w600,
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
              const _NavIcon(icon: Icons.auto_awesome_rounded, label: 'Mix'),
              const _NavIcon(icon: Icons.palette_outlined, label: 'Theme'),
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
  const _NavIcon({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

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
          Text(label,
              style: MirraType.ui(
                size: 10,
                color: MirraColors.muted,
                weight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}
