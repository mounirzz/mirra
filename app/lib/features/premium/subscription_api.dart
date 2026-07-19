import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/auth/auth_config.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/auth/auth_service.dart';
import 'providers/premium_provider.dart';

class SubscriptionApi {
  SubscriptionApi(this._auth);

  final AuthService _auth;

  Future<void> put(Map<String, dynamic> payload) async {
    final token = await _auth.validIdToken();
    if (token == null) return;
    await http.put(
      Uri.parse('${AuthConfig.apiBaseUrl}/subscription'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
  }
}

final subscriptionApiProvider =
    Provider<SubscriptionApi>((ref) => SubscriptionApi(ref.watch(authServiceProvider)));

/// Reports the user's subscription state to the server on sign-in and whenever
/// it changes, so the `subscriptions` table reflects who's premium. Best-effort.
/// Keep alive by watching it once from the app root.
class SubscriptionSyncNotifier extends StateNotifier<int> {
  SubscriptionSyncNotifier(this._ref) : super(0) {
    _ref.listen<bool>(
      isSignedInProvider,
      (_, signedIn) {
        if (signedIn) _push();
      },
      fireImmediately: true,
    );
    _ref.listen(isPremiumProvider, (_, _) => _push());
  }

  final Ref _ref;

  Future<void> _push() async {
    if (!_ref.read(isSignedInProvider)) return;
    final premium = _ref.read(isPremiumProvider);
    try {
      await _ref.read(subscriptionApiProvider).put({
        'status': premium ? 'active' : 'free',
        'source': 'app',
      });
      state++;
    } catch (_) {
      // best-effort
    }
  }
}

final subscriptionSyncProvider =
    StateNotifierProvider<SubscriptionSyncNotifier, int>(
  (ref) => SubscriptionSyncNotifier(ref),
);
