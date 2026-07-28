import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../onboarding/providers/app_icon_provider.dart';

/// App-icon picker — actually swaps the iOS Home-screen icon via alternate app
/// icons (name = null → the default Mirra icon). Uses the same real Mirra
/// logos as onboarding (declared as AppIconAlt1..N in Info.plist).
class AppIconScreen extends StatefulWidget {
  const AppIconScreen({super.key});

  @override
  State<AppIconScreen> createState() => _AppIconScreenState();
}

class _AppIconScreenState extends State<AppIconScreen> {
  // (label, alternate icon name or null for default, asset preview or null).
  // The default app icon is mirra_1, so its preview uses that same asset.
  static final _icons = <(String, String?, String?)>[
    (
      'Default',
      null,
      kAppIconAssets.isNotEmpty ? kAppIconAssets.first : null,
    ),
    // Skip Alt1 (identical to Default = mirra_1); offer the other logos.
    for (var i = 1; i < kAppIconAssets.length; i++)
      ('Mirra ${i + 1}', 'AppIconAlt${i + 1}', kAppIconAssets[i]),
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
    // Optimistic: update the checkmark immediately. We use the public API
    // (not the private "silent" path, which never invokes its callback and
    // would hang this await). iOS shows its standard confirmation alert.
    setState(() => _current = name);
    try {
      await FlutterDynamicIconPlus.setAlternateIconName(iconName: name);
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
              onTap: () => context.canPop() ? context.pop() : context.go('/home'),
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
                  final (name, iconName, asset) = _icons[i];
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(17),
                              child: asset == null
                                  ? Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFFB79DE8),
                                            Color(0xFFE86A5E),
                                          ],
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'm',
                                        style: MirraType.carmenSans(
                                            size: 40, color: Colors.white),
                                      ),
                                    )
                                  : Image.asset(
                                      asset,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        color: const Color(0xFFF4F2F8),
                                        alignment: Alignment.center,
                                        child: Text(
                                          name,
                                          style: MirraType.cochin(
                                            size: 12,
                                            color: MirraColors.muted2,
                                          ),
                                        ),
                                      ),
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
