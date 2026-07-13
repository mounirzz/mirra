// Warms the on-disk image cache with every theme background on app launch.
// After the first successful run the images live in local iOS storage, so the
// feed and Themes grid render instantly and work offline. Fire-and-forget:
// runs in the background, tolerates being offline, never blocks startup.

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'theme_catalog.dart';

/// All unique theme background URLs (catalog photos + mix cards).
List<String> _allThemeUrls() {
  final urls = <String>{};
  for (final t in kAppThemes) {
    if (t.photoUrl != null) urls.add(t.photoUrl!);
  }
  for (final m in kThemeMixes) {
    if (m.photoUrl != null) urls.add(m.photoUrl!);
  }
  return urls.toList();
}

/// Downloads any not-yet-cached theme images into the disk cache. Safe to call
/// on every launch — already-cached files are skipped by the cache manager.
Future<void> prefetchThemeImages() async {
  final cache = DefaultCacheManager();
  final urls = _allThemeUrls();
  // Small concurrency so we don't hammer the network on a cold start.
  const batch = 5;
  for (var i = 0; i < urls.length; i += batch) {
    final slice = urls.skip(i).take(batch);
    await Future.wait([
      for (final url in slice)
        // One bad URL or being offline must not fail the whole prefetch.
        cache.getSingleFile(url).then<void>((_) {}).catchError((Object e) {
          if (kDebugMode) debugPrint('theme prefetch skipped $url: $e');
        }),
    ]);
  }
}
