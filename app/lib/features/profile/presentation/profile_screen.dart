import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../library/providers/history_provider.dart';
import '../../library/providers/own_quotes_provider.dart';
import '../../themes/presentation/customize_quote_sheet.dart';
import '../providers/mood_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoritesProvider);
    final history = ref.watch(historyProvider);
    final own = ref.watch(ownQuotesProvider);
    final mood = ref.watch(moodProvider.notifier).today;
    final streak = MirraBoxes.current.streak;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              MirraSpace.lg, 0, MirraSpace.lg, 40),
          children: [
            const IosStatusSpacer(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Profile',
                    style: MirraType.title.copyWith(fontSize: 26)),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child:
                        Icon(Icons.settings_outlined, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: MirraSpace.lg),
            _StreakHero(streak: streak),
            const SizedBox(height: MirraSpace.lg),
            _MoodCard(
              currentScore: mood?.score,
              onSelect: (s) => ref.read(moodProvider.notifier).log(s),
            ),
            const SizedBox(height: MirraSpace.lg),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Favorites',
                    value: '${favs.length}',
                    icon: Icons.favorite_border_rounded,
                  ),
                ),
                const SizedBox(width: MirraSpace.sm),
                Expanded(
                  child: _StatTile(
                    label: 'Viewed',
                    value: '${history.length}',
                    icon: Icons.visibility_outlined,
                  ),
                ),
                const SizedBox(width: MirraSpace.sm),
                Expanded(
                  child: _StatTile(
                    label: 'My quotes',
                    value: '${own.length}',
                    icon: Icons.edit_note_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: MirraSpace.lg),
            Text('Customize',
                style: MirraType.ui(
                    size: 12,
                    color: MirraColors.muted,
                    weight: FontWeight.w600)),
            const SizedBox(height: MirraSpace.sm),
            _ProfileRow(
              icon: Icons.palette_outlined,
              label: 'Quote appearance',
              subtitle: 'Font size & theme mode',
              onTap: () => showCustomizeQuoteSheet(context),
            ),
            _ProfileRow(
              icon: Icons.collections_bookmark_outlined,
              label: 'Library',
              subtitle: 'Favorites, collections, history',
              onTap: () => context.push('/library'),
            ),
            _ProfileRow(
              icon: Icons.search_rounded,
              label: 'Search',
              subtitle: 'Find quotes & authors',
              onTap: () => context.push('/search'),
            ),
            _ProfileRow(
              icon: Icons.settings_outlined,
              label: 'Settings',
              subtitle: 'Theme, language, subscription',
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MirraSpace.lg),
      decoration: BoxDecoration(
        gradient: MirraColors.gradSoft,
        borderRadius: BorderRadius.circular(MirraRadius.xl),
        border: Border.all(color: MirraColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: MirraColors.grad,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: MirraSpace.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$streak day streak',
                  style: MirraType.serif(size: 26, height: 1.0)),
              const SizedBox(height: 4),
              Text('Show up. Read one quote.',
                  style: MirraType.ui(
                      size: 12, color: MirraColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({required this.currentScore, required this.onSelect});
  final int? currentScore;
  final ValueChanged<int> onSelect;

  static const _emoji = ['😣', '😐', '🙂', '😊', '✨'];
  static const _labels = ['Anxious', 'Flat', 'Okay', 'Good', 'Glowing'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MirraSpace.md),
      decoration: BoxDecoration(
        color: MirraColors.surface,
        borderRadius: BorderRadius.circular(MirraRadius.lg),
        border: Border.all(color: MirraColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How are you today?',
              style: MirraType.ui(size: 14, weight: FontWeight.w600)),
          if (currentScore != null) ...[
            const SizedBox(height: 4),
            Text('Logged: ${_labels[currentScore!]}',
                style: MirraType.ui(
                    size: 11, color: MirraColors.muted)),
          ],
          const SizedBox(height: MirraSpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final selected = currentScore == i;
              return GestureDetector(
                onTap: () => onSelect(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected ? MirraColors.chip : Colors.transparent,
                    border: Border.all(
                        color: selected
                            ? MirraColors.chipLine
                            : MirraColors.line),
                    borderRadius: BorderRadius.circular(MirraRadius.md),
                  ),
                  child: Center(
                    child:
                        Text(_emoji[i], style: const TextStyle(fontSize: 22)),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MirraSpace.md),
      decoration: BoxDecoration(
        color: MirraColors.surface,
        borderRadius: BorderRadius.circular(MirraRadius.lg),
        border: Border.all(color: MirraColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MirraColors.ink, size: 18),
          const SizedBox(height: 10),
          Text(value, style: MirraType.serif(size: 22)),
          Text(label,
              style: MirraType.ui(
                  size: 11, color: MirraColors.muted)),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MirraSpace.sm),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(MirraSpace.md),
          decoration: BoxDecoration(
            color: MirraColors.surface,
            borderRadius: BorderRadius.circular(MirraRadius.lg),
            border: Border.all(color: MirraColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: MirraColors.gradSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: MirraColors.ink, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: MirraType.ui(
                            size: 14, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: MirraType.ui(
                            size: 12, color: MirraColors.muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: MirraColors.muted2),
            ],
          ),
        ),
      ),
    );
  }
}
