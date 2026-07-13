// Theme mixes — full 2-column grid of category cards (capture 1).
// Header: back "Themes" / centered "Theme mixes" / "Create".

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../theme_catalog.dart';
import 'theme_mix_card.dart';

class ThemeMixesScreen extends StatelessWidget {
  const ThemeMixesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chevron_left_rounded,
                                size: 24, color: MirraColors.ink),
                            Text(
                              'Themes',
                              style: MirraType.cochin(
                                size: 16,
                                weight: FontWeight.w500,
                                color: MirraColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Theme mixes',
                    style: MirraType.cochin(size: 16, weight: FontWeight.w700),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.push('/theme/create'),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Create',
                          style: MirraType.cochin(
                            size: 15,
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
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.55,
                ),
                itemCount: kThemeMixes.length,
                itemBuilder: (_, i) => ThemeMixCard(
                  mix: kThemeMixes[i],
                  radius: 16,
                  labelSize: 16,
                  onTap: () => context.pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
