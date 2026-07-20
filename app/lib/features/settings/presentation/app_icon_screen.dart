import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// App-icon picker. Choosing highlights an option; actually swapping the iOS
/// home-screen icon needs the alternate-icon assets added in Xcode (a quick
/// setup — the picker is ready to drive it once they're in).
class AppIconScreen extends StatefulWidget {
  const AppIconScreen({super.key});

  @override
  State<AppIconScreen> createState() => _AppIconScreenState();
}

class _AppIconScreenState extends State<AppIconScreen> {
  static const _icons = <(String, List<Color>)>[
    ('Lavender', [Color(0xFFB79DE8), Color(0xFFE86A5E)]),
    ('Sunset', [Color(0xFFF7B267), Color(0xFFEA5455)]),
    ('Ocean', [Color(0xFF5AA9E6), Color(0xFF6C5CE7)]),
    ('Forest', [Color(0xFF43C59E), Color(0xFF157A6E)]),
    ('Ink', [Color(0xFF2A2F40), Color(0xFF1A1A1A)]),
    ('Cream', [Color(0xFFF3ECDD), Color(0xFFE0D6BF)]),
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Icon(Icons.close_rounded, size: 22, color: MirraColors.ink),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
              child: Text('App icon',
                  style: MirraType.cochin(size: 24, weight: FontWeight.w800)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Text('Pick the look that fits your vibe.',
                  style: MirraType.cochin(size: 14, color: MirraColors.muted)),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 0.82,
                ),
                itemCount: _icons.length,
                itemBuilder: (_, i) {
                  final (name, colors) = _icons[i];
                  final selected = i == _selected;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? MirraColors.ink : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          padding: const EdgeInsets.all(3),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: colors,
                                ),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.local_fire_department_rounded,
                                size: 34,
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(name,
                            style: MirraType.cochin(
                                size: 12,
                                weight: selected ? FontWeight.w800 : FontWeight.w600)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F2F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'To apply your pick to the real Home-screen icon, the alternate '
                  'icon assets need to be added to the iOS project (a quick, '
                  'one-time setup).',
                  style: MirraType.cochin(size: 13, color: MirraColors.muted, height: 1.35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
