import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/hive_boxes.dart';
import 'features/theme/theme_prefetch.dart';
import 'features/widget/widget_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MirraBoxes.init();
  await WidgetService.init();
  await NotificationService.init();
  // Refresh schedules on every launch so notification quotes rotate.
  NotificationService.scheduleFromPrefs();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const ProviderScope(child: MirraApp()));

  // Download theme backgrounds into the local iOS cache in the background so
  // they're available instantly (and offline) after the first launch.
  unawaited(prefetchThemeImages());
}
