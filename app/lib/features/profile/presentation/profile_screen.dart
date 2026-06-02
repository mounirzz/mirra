import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/mirra_chrome.dart';
import '../providers/profile_provider.dart';

/// The "Mirra" profile hub — streak overview, quick library shortcuts, and the
/// "Customize the app" tile grid. Mirrors `mirra-profile.jsx`'s ProfileScreen.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: MirraColors.ink,
          content: Text(
            '$label — coming soon',
            style: MirraType.ui(size: 14, color: Colors.white),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: MirraColors.surface,
      body: Column(
        children: [
          MirraHeader(
            onBack: () => context.pop(),
            backIsClose: true,
            trailing: HeaderTextAction(
              label: 'Settings',
              onTap: () => context.push('/settings'),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 30),
              children: [
                Text('Mirra', style: MirraType.serif(size: 28)),
                const SizedBox(height: 16),
                _StreakHero(streak: streak),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.3,
                  children: [
                    _QuickTile(
                      label: 'My favorites',
                      icon: Icons.favorite_border_rounded,
                      onTap: () => context.push('/favorites'),
                    ),
                    _QuickTile(
                      label: 'My collections',
                      icon: Icons.bookmark_border_rounded,
                      onTap: () => _comingSoon(context, 'Collections'),
                    ),
                    _QuickTile(
                      label: 'My own quotes',
                      icon: Icons.edit_outlined,
                      onTap: () => _comingSoon(context, 'Your own quotes'),
                    ),
                    _QuickTile(
                      label: 'Recent quotes',
                      icon: Icons.refresh_rounded,
                      onTap: () => _comingSoon(context, 'History'),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Customize the app',
                  style: MirraType.ui(size: 18, weight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.18,
                  children: [
                    _CustomizeTile(
                      label: 'Topics you follow',
                      icon: Icons.tag_rounded,
                      onTap: () => _comingSoon(context, 'Topics you follow'),
                    ),
                    _CustomizeTile(
                      label: 'Reminders',
                      icon: Icons.notifications_none_rounded,
                      onTap: () => _comingSoon(context, 'Reminders'),
                    ),
                    _CustomizeTile(
                      label: 'App icon',
                      icon: Icons.apps_rounded,
                      onTap: () => _comingSoon(context, 'App icon'),
                    ),
                    _CustomizeTile(
                      label: 'Widgets',
                      icon: Icons.widgets_outlined,
                      onTap: () => _comingSoon(context, 'Widgets'),
                    ),
                    _CustomizeTile(
                      label: 'Watch',
                      icon: Icons.watch_outlined,
                      onTap: () => _comingSoon(context, 'Watch'),
                    ),
                    _CustomizeTile(
                      label: 'Self-Growth bundle',
                      icon: Icons.auto_awesome_rounded,
                      onTap: () => _comingSoon(context, 'Self-Growth bundle'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.streak});

  final int streak;

  static const _days = ['Fr', 'Sa', 'Su', 'Mo', 'Tu', 'We', 'Th'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: MirraColors.tile,
        borderRadius: BorderRadius.circular(MirraRadius.md),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (rect) =>
                      MirraColors.grad.createShader(rect),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '$streak',
                    style: MirraType.serif(size: 16, color: Colors.white)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your streak',
                  style: MirraType.ui(size: 14, weight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < _days.length; i++)
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _days[i],
                              style: MirraType.ui(
                                size: 9,
                                color: MirraColors.muted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: i < streak ? MirraColors.grad : null,
                                color: i < streak
                                    ? null
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                              child: i < streak
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 10,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: const [
              Icon(Icons.ios_share_rounded, size: 18, color: MirraColors.ink),
              SizedBox(height: 8),
              Icon(Icons.more_vert_rounded, size: 18, color: MirraColors.ink),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MirraColors.tile,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                label,
                style: MirraType.ui(size: 13, weight: FontWeight.w600),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(icon, size: 18, color: MirraColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomizeTile extends StatelessWidget {
  const _CustomizeTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MirraColors.tile,
          borderRadius: BorderRadius.circular(MirraRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: MirraType.ui(size: 14, weight: FontWeight.w600),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: MirraColors.grad,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
