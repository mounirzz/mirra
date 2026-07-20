import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// App-icon picker — actually swaps the iOS Home-screen icon via alternate app
/// icons (name = null → the default Mirra icon).
class AppIconScreen extends StatefulWidget {
  const AppIconScreen({super.key});

  @override
  State<AppIconScreen> createState() => _AppIconScreenState();
}

class _AppIconScreenState extends State<AppIconScreen> {
  // (label, alternate icon name or null for default, gradient preview)
  static const _icons = <(String, String?, List<Color>)>[
    ('Default', null, [Color(0xFFB79DE8), Color(0xFFE86A5E)]),
    ('Sunset', 'MirraSunset', [Color(0xFFF7B267), Color(0xFFEA5455)]),
    ('Ocean', 'MirraOcean', [Color(0xFF5AA9E6), Color(0xFF6C5CE7)]),
    ('Forest', 'MirraForest', [Color(0xFF43C59E), Color(0xFF157A6E)]),
    ('Ink', 'MirraInk', [Color(0xFF2A2F40), Color(0xFF1A1A1A)]),
  ];

  String? _current; // active alternate icon name (null = default)
  bool _supported = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _supported = await FlutterDynamicIconPlus.supportsAlternateIcons;
      _current = await FlutterDynamicIconPlus.alternateIconName;
    } catch (_) {
      _supported = false;
    }
    if (mounted) setState(() {});
  }

  Future<void> _select(String? name) async {
    if (name == _current) return;
    try {
      await FlutterDynamicIconPlus.setAlternateIconName(iconName: name, isSilent: true);
      if (mounted) setState(() => _current = name);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text("Couldn't change the icon")));
      }
    }
  }

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
              child: Text(
                _supported
                    ? 'Pick the look that fits your vibe.'
                    : 'Alternate icons aren’t available on this device.',
                style: MirraType.cochin(size: 14, color: MirraColors.muted),
              ),
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
                  final (name, iconName, colors) = _icons[i];
                  final selected = iconName == _current;
                  return GestureDetector(
                    onTap: _supported ? () => _select(iconName) : null,
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
                              child: Text(
                                'm',
                                style: MirraType.carmenSans(size: 40, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          style: MirraType.cochin(
                              size: 12,
                              weight: selected ? FontWeight.w800 : FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
