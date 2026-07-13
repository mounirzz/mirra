// Create your own theme — pick a background (a colour, or a photo from the
// gallery), a font and a text colour, with a live preview. Saves as the active
// custom theme.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../app_theme_provider.dart';
import '../theme_catalog.dart';

class CreateThemeScreen extends ConsumerStatefulWidget {
  const CreateThemeScreen({super.key});

  @override
  ConsumerState<CreateThemeScreen> createState() => _CreateThemeScreenState();
}

class _CreateThemeScreenState extends ConsumerState<CreateThemeScreen> {
  static const _bgColors = [
    Color(0xFF1A1A1A),
    Color(0xFF4226A8),
    Color(0xFF0E3B2E),
    Color(0xFF7A2E2E),
    Color(0xFFEDE6DA),
    Color(0xFFB79DE8),
    Color(0xFFF0B2A3),
    Color(0xFF2A2F40),
  ];
  static const _textColors = [
    Colors.white,
    Color(0xFF1A1A1A),
    Color(0xFFF0B2A3),
    Color(0xFFF8D2A8),
    Color(0xFFB79DE8),
  ];

  Color _bg = const Color(0xFF1A1A1A);
  Color _text = Colors.white;
  ThemeFont _font = ThemeFont.serif;

  AppTheme get _preview => AppTheme(
        id: 'custom',
        label: 'My theme',
        solid: _bg,
        font: _font,
        textColor: _text,
        dark: _bg.computeLuminance() < 0.5,
        custom: true,
      );

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
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.chevron_left_rounded,
                            size: 26, color: MirraColors.ink),
                      ),
                    ),
                  ),
                  Text(
                    'Create theme',
                    style: MirraType.cochin(size: 16, weight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  // Live preview
                  AspectRatio(
                    aspectRatio: 3 / 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'You are exactly where\nyou need to be.',
                        textAlign: TextAlign.center,
                        style: _preview.quoteStyle(24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _label('Background'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _photoButton(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final c in _bgColors)
                              _swatch(
                                color: c,
                                selected: _bg == c,
                                onTap: () => setState(() => _bg = c),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _label('Font'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _fontChip('Serif', ThemeFont.serif),
                      const SizedBox(width: 8),
                      _fontChip('Sans', ThemeFont.sans),
                      const SizedBox(width: 8),
                      _fontChip('Mono', ThemeFont.mono),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _label('Text color'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final c in _textColors) ...[
                        _swatch(
                          color: c,
                          selected: _text == c,
                          onTap: () => setState(() => _text = c),
                          ring: true,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GestureDetector(
                onTap: () async {
                  await ref.read(appThemeProvider.notifier).setCustomColor(
                        background: _bg,
                        font: _font,
                        textColor: _text,
                      );
                  if (!context.mounted) return;
                  context.go('/home');
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: MirraColors.ink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Use this theme',
                    style: MirraType.cochin(
                      size: 16,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String s) =>
      Text(s, style: MirraType.cochin(size: 15, weight: FontWeight.w700));

  Widget _photoButton() {
    return GestureDetector(
      onTap: () async {
        final router = GoRouter.of(context);
        final ok = await ref.read(appThemeProvider.notifier).setCustomPhoto(
              font: _font,
              textColor: _text,
            );
        if (!ok) return;
        router.go('/home');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFE9E6F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.add_photo_alternate_outlined,
            color: MirraColors.ink, size: 24),
      ),
    );
  }

  Widget _swatch({
    required Color color,
    required bool selected,
    required VoidCallback onTap,
    bool ring = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? MirraColors.ink
                : (ring ? const Color(0x33000000) : const Color(0x22000000)),
            width: selected ? 2.5 : 1,
          ),
        ),
      ),
    );
  }

  Widget _fontChip(String label, ThemeFont font) {
    final on = _font == font;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _font = font),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? const Color(0xFFE9E6F2) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: on ? MirraColors.ink : const Color(0xFFE5E0D2),
              width: on ? 1.5 : 1.2,
            ),
          ),
          child: Text(
            label,
            style: _fontSample(font),
          ),
        ),
      ),
    );
  }

  TextStyle _fontSample(ThemeFont font) {
    final t = AppTheme(
      id: 'x',
      label: 'x',
      font: font,
      textColor: MirraColors.ink,
    );
    return t.quoteStyle(16);
  }
}
