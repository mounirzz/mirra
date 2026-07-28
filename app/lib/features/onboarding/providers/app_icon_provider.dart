import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The nine Mirra home-screen icon options offered during onboarding.
/// Drop the matching PNGs in `assets/app_icons/` (see [kAppIconAssets]).
const kAppIconAssets = <String>[
  'assets/app_icons/mirra_1.png',
  'assets/app_icons/mirra_2.png',
  'assets/app_icons/mirra_3.png',
  'assets/app_icons/mirra_4.png',
  'assets/app_icons/mirra_5.png',
  'assets/app_icons/mirra_6.png',
  'assets/app_icons/mirra_7.png',
  'assets/app_icons/mirra_8.png',
  'assets/app_icons/mirra_9.png',
];

/// Index (0..8) of the app icon the user picked in onboarding.
final selectedAppIconProvider = StateProvider<int>((ref) => 0);
