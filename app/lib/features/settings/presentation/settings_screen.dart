import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/user_prefs.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _languages = [
    ('en', 'English'),
    ('fr', 'Français'),
    ('es', 'Español'),
    ('de', 'Deutsch'),
    ('it', 'Italiano'),
    ('pt', 'Português'),
  ];

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final current = ref.read(settingsProvider).language;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: MirraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MirraColors.line2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text('Language', style: MirraType.serif(size: 22)),
            const SizedBox(height: 8),
            for (final lang in _languages)
              ListTile(
                title: Text(lang.$2,
                    style: MirraType.ui(
                        size: 15, weight: FontWeight.w500)),
                trailing: current == lang.$1
                    ? const Icon(Icons.check_rounded,
                        color: MirraColors.ink)
                    : null,
                onTap: () => Navigator.pop(ctx, lang.$1),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (picked != null) {
      await ref.read(settingsProvider.notifier).setLanguage(picked);
    }
  }

  String _languageLabel(String code) {
    final match =
        _languages.where((l) => l.$1 == code).cast<(String, String)?>().firstOrNull;
    return match?.$2 ?? code.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(settingsProvider);

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
                Text('Settings',
                    style: MirraType.title.copyWith(fontSize: 26)),
              ],
            ),
            const SizedBox(height: MirraSpace.lg),
            _SectionLabel(label: 'Appearance'),
            _Card(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.brightness_6_outlined,
                            size: 18),
                        const SizedBox(width: 10),
                        Text('Theme mode',
                            style: MirraType.ui(
                                size: 14, weight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: SegmentedButton<ThemeModePref>(
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        textStyle: WidgetStatePropertyAll(
                            MirraType.ui(
                                size: 12, weight: FontWeight.w600)),
                      ),
                      segments: const [
                        ButtonSegment(
                            value: ThemeModePref.system,
                            label: Text('System')),
                        ButtonSegment(
                            value: ThemeModePref.light,
                            label: Text('Light')),
                        ButtonSegment(
                            value: ThemeModePref.dark,
                            label: Text('Dark')),
                      ],
                      selected: {prefs.themeMode},
                      onSelectionChanged: (s) => ref
                          .read(settingsProvider.notifier)
                          .setThemeMode(s.first),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MirraSpace.lg),
            _SectionLabel(label: 'General'),
            _Card(
              child: Column(
                children: [
                  _Row(
                    icon: Icons.language_rounded,
                    label: 'Language',
                    value: _languageLabel(prefs.language),
                    onTap: () => _pickLanguage(context, ref),
                  ),
                  const Divider(
                      height: 1, color: MirraColors.line),
                  _Row(
                    icon: Icons.notifications_none_rounded,
                    label: 'Reminders',
                    value: 'Coming in Phase 3',
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: MirraSpace.lg),
            _SectionLabel(label: 'Mirra Plus'),
            _Card(
              child: Padding(
                padding: const EdgeInsets.all(MirraSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: MirraColors.grad,
                        borderRadius:
                            BorderRadius.circular(MirraRadius.pill),
                      ),
                      child: Text('PLUS',
                          style: MirraType.ui(
                              size: 10,
                              color: Colors.white,
                              weight: FontWeight.w700,
                              letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 10),
                    Text('Unlock the full library',
                        style: MirraType.serif(size: 22, height: 1.1)),
                    const SizedBox(height: 6),
                    Text(
                        'Widgets, all categories, custom themes, ad-free.',
                        style: MirraType.ui(
                            size: 13, color: MirraColors.muted)),
                    const SizedBox(height: MirraSpace.sm),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: MirraColors.ink,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                MirraRadius.pill),
                          ),
                        ),
                        onPressed: null,
                        child: Text('Subscription · Coming soon',
                            style: MirraType.ui(
                                size: 13,
                                color: Colors.white,
                                weight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: MirraSpace.lg),
            _SectionLabel(label: 'About'),
            _Card(
              child: Column(
                children: [
                  _Row(
                    icon: Icons.info_outline_rounded,
                    label: 'Version',
                    value: '0.1.0',
                    onTap: null,
                  ),
                  const Divider(
                      height: 1, color: MirraColors.line),
                  _Row(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy',
                    value: '',
                    onTap: null,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: MirraSpace.xs),
      child: Text(label.toUpperCase(),
          style: MirraType.ui(
              size: 11,
              color: MirraColors.muted,
              weight: FontWeight.w600,
              letterSpacing: 1.0)),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MirraColors.surface,
        borderRadius: BorderRadius.circular(MirraRadius.lg),
        border: Border.all(color: MirraColors.line),
      ),
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MirraRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: MirraSpace.md, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: MirraColors.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: MirraType.ui(
                      size: 14, weight: FontWeight.w500)),
            ),
            if (value.isNotEmpty)
              Text(value,
                  style: MirraType.ui(
                      size: 13, color: MirraColors.muted)),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: MirraColors.muted2, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
