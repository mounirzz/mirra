import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_provider.dart';

class MirraApp extends ConsumerWidget {
  const MirraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Mirra',
      debugShowCheckedModeBanner: false,
      theme: MirraTheme.light(),
      darkTheme: MirraTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
