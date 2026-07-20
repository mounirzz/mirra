import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../preferences/providers/content_topics_provider.dart';

/// Topics the user can follow. Each maps to a token that drives the feed and
/// the AI generation (via contentTopicsProvider). Following a topic surfaces it
/// in the feed and teaches the model to write about it.
const List<(String, List<(String, String)>)> _sections = [
  ('Most popular', [
    ('Self-worth', 'self_esteem'),
    ('Love', 'love'),
    ('Confidence', 'confidence'),
    ('Motivation', 'motivation'),
    ('Gratitude', 'gratitude'),
    ('Happiness', 'happiness'),
  ]),
  ('Growth & goals', [
    ('Personal growth', 'growth'),
    ('New beginnings', 'letting_go'),
    ('Achieving goals', 'success'),
    ('Productivity', 'productivity'),
    ('Discipline', 'discipline'),
    ('Encouraging words', 'positivity'),
  ]),
  ('Calm & healing', [
    ('Calm', 'calm'),
    ('Stress & Anxiety', 'stress'),
    ('Mindfulness', 'mindfulness'),
    ('Healing', 'healing'),
  ]),
  ('Body & faith', [
    ('Working out', 'workout'),
    ('Health', 'health'),
    ('Faith & Spirituality', 'faith'),
    ('Hard times', 'hard_times'),
  ]),
];

class FollowTopicsScreen extends ConsumerStatefulWidget {
  const FollowTopicsScreen({super.key});

  @override
  ConsumerState<FollowTopicsScreen> createState() => _FollowTopicsScreenState();
}

class _FollowTopicsScreenState extends ConsumerState<FollowTopicsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final followed = ref.watch(contentTopicsProvider);
    final q = _query.trim().toLowerCase();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.close_rounded, size: 22, color: MirraColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
              child: Text(
                'Topics you follow',
                style: MirraType.cochin(size: 24, weight: FontWeight.w800),
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F2F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, size: 18, color: MirraColors.muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        style: MirraType.cochin(size: 15, weight: FontWeight.w600),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Search',
                          hintStyle:
                              MirraType.cochin(size: 15, color: MirraColors.muted),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                children: [
                  for (final (title, items) in _sections)
                    ..._section(title, items, followed, q),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _section(
    String title,
    List<(String, String)> items,
    Set<String> followed,
    String q,
  ) {
    final visible =
        q.isEmpty ? items : items.where((i) => i.$1.toLowerCase().contains(q)).toList();
    if (visible.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(title, style: MirraType.cochin(size: 17, weight: FontWeight.w800)),
      ),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F2F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE7E3F0)),
              _row(visible[i].$1, visible[i].$2, followed.contains(visible[i].$2)),
            ],
          ],
        ),
      ),
      const SizedBox(height: 18),
    ];
  }

  Widget _row(String label, String token, bool following) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: MirraType.cochin(size: 15, weight: FontWeight.w700)),
          ),
          GestureDetector(
            onTap: () => ref.read(contentTopicsProvider.notifier).toggle(token),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: following ? MirraColors.ink : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: following ? MirraColors.ink : const Color(0xFFDBD8E3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (following) ...[
                    const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    following ? 'Following' : 'Follow',
                    style: MirraType.cochin(
                      size: 13,
                      weight: FontWeight.w700,
                      color: following ? Colors.white : MirraColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
