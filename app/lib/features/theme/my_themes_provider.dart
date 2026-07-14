import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_provider.dart';
import 'theme_api.dart';

/// The signed-in user's saved custom themes. Reloads whenever auth state flips
/// to signed-in (and clears on sign-out), so a fresh install just needs a
/// sign-in to get every saved theme back.
class MyThemesNotifier extends StateNotifier<AsyncValue<List<RemoteTheme>>> {
  MyThemesNotifier(this._ref) : super(const AsyncValue.data([])) {
    _ref.listen<bool>(
      isSignedInProvider,
      (_, signedIn) => signedIn ? refresh() : state = const AsyncValue.data([]),
      fireImmediately: true,
    );
  }

  final Ref _ref;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _ref.read(themeApiProvider).listThemes());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(String themeId) async {
    await _ref.read(themeApiProvider).deleteTheme(themeId);
    await refresh();
  }
}

final myThemesProvider =
    StateNotifierProvider<MyThemesNotifier, AsyncValue<List<RemoteTheme>>>(
  (ref) => MyThemesNotifier(ref),
);
