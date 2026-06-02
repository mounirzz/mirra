import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/mirra_chrome.dart';

/// Language picker (`mirra-preferences.jsx` → LanguageScreen). Selection is
/// kept locally for now; persistence lands with the i18n work in Phase 2.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const _languages = [
    'English',
    'Español',
    'Français',
    'Deutsch',
    'Italiano',
    'Português',
    '日本語',
    '한국어',
    '中文 (简体)',
    'العربية',
  ];

  String _selected = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirraColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MirraHeader(onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
            child: Text('Language', style: MirraType.serif(size: 26)),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              itemCount: _languages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, i) {
                final lang = _languages[i];
                final selected = lang == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = lang),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: MirraColors.tile,
                      borderRadius: BorderRadius.circular(MirraRadius.sm),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            lang,
                            style: MirraType.ui(size: 14),
                          ),
                        ),
                        if (selected)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: MirraColors.ink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
