import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/user_prefs.dart';
import '../../settings/providers/settings_provider.dart';

Future<void> showCustomizeQuoteSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CustomizeSheet(),
  );
}

class _CustomizeSheet extends ConsumerWidget {
  const _CustomizeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(settingsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: MirraColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(
          MirraSpace.lg, MirraSpace.md, MirraSpace.lg, MirraSpace.xl),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MirraColors.chipLine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Customize', style: MirraType.title.copyWith(fontSize: 22)),
            const SizedBox(height: 22),

            _SectionLabel('Quote text size'),
            const SizedBox(height: 6),
            Slider(
              value: prefs.quoteFontSize,
              min: 22,
              max: 44,
              divisions: 11,
              activeColor: MirraColors.ink,
              inactiveColor: MirraColors.chipLine,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setQuoteFontSize(v),
            ),
            const SizedBox(height: 12),

            _SectionLabel('Theme'),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final mode in ThemeModePref.values)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: mode == ThemeModePref.values.last ? 0 : 8,
                      ),
                      child: _ModeChip(
                        label: switch (mode) {
                          ThemeModePref.system => 'System',
                          ThemeModePref.light => 'Light',
                          ThemeModePref.dark => 'Dark',
                        },
                        selected: prefs.themeMode == mode,
                        onTap: () => ref
                            .read(settingsProvider.notifier)
                            .setThemeMode(mode),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: MirraType.eyebrow.copyWith(color: MirraColors.muted),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? MirraColors.ink : MirraColors.surface,
          border: Border.all(
              color: selected ? MirraColors.ink : MirraColors.line),
          borderRadius: BorderRadius.circular(MirraRadius.pill),
        ),
        child: Text(
          label,
          style: MirraType.ui(
            size: 13,
            weight: FontWeight.w600,
            color: selected ? Colors.white : MirraColors.ink,
          ),
        ),
      ),
    );
  }
}
