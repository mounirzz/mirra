import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/i18n/language_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/preferences/preferences_api.dart';
import 'features/premium/subscription_api.dart';
import 'features/streak/providers/streak_provider.dart';

class MirraApp extends ConsumerStatefulWidget {
  const MirraApp({super.key});

  @override
  ConsumerState<MirraApp> createState() => _MirraAppState();
}

class _MirraAppState extends ConsumerState<MirraApp> {
  @override
  void initState() {
    super.initState();
    ref.read(streakProvider.notifier).checkIn();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final language = ref.watch(languageProvider);
    // Keep the sync services alive (push prefs + subscription to Postgres).
    ref.watch(preferencesSyncProvider);
    ref.watch(subscriptionSyncProvider);
    return MaterialApp.router(
      title: 'Mirra',
      debugShowCheckedModeBanner: false,
      theme: MirraTheme.light(),
      locale: Locale(language.code),
      routerConfig: router,
    );
  }
}
