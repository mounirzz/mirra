import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/auth/auth_config.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/auth/auth_service.dart';

/// The user's flame progress (gamification level from engagement).
class FlameState {
  const FlameState({
    this.points = 0,
    this.level = 1,
    this.name = 'Spark',
    this.nextAt,
  });

  final int points;
  final int level;
  final String name;
  final int? nextAt;

  /// Progress (0..1) toward the next level, for a ring/bar.
  double get progress {
    final next = nextAt;
    if (next == null || next <= 0) return 1;
    return (points / next).clamp(0, 1).toDouble();
  }

  factory FlameState.fromJson(Map<String, dynamic> j) => FlameState(
        points: (j['points'] as num?)?.toInt() ?? 0,
        level: (j['level'] as num?)?.toInt() ?? 1,
        name: (j['name'] ?? 'Spark') as String,
        nextAt: (j['nextAt'] as num?)?.toInt(),
      );
}

class FlameApi {
  FlameApi(this._auth);

  final AuthService _auth;

  Future<FlameState?> _send(String method, [Map<String, dynamic>? body]) async {
    final token = await _auth.validIdToken();
    if (token == null) return null;
    final uri = Uri.parse('${AuthConfig.apiBaseUrl}/engagement');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    try {
      final res = method == 'GET'
          ? await http.get(uri, headers: headers)
          : await http.post(uri, headers: headers, body: jsonEncode(body));
      if (res.statusCode != 200) return null;
      return FlameState.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<FlameState?> stats() => _send('GET');

  Future<FlameState?> record(
    String action, {
    String? text,
    String? topic,
    String? tone,
  }) =>
      _send('POST', {
        'action': action,
        'text': ?text,
        'topic': ?topic,
        'tone': ?tone,
      });
}

final flameApiProvider =
    Provider<FlameApi>((ref) => FlameApi(ref.watch(authServiceProvider)));

/// Holds the flame total/level. Loads on sign-in (and claims the daily "open"
/// bonus), and updates from each like/share/copy the user makes. Signed out /
/// offline it stays at zero — best-effort, never blocks the UI.
class FlameNotifier extends StateNotifier<FlameState> {
  FlameNotifier(this._ref) : super(const FlameState()) {
    _ref.listen<bool>(
      isSignedInProvider,
      (_, signedIn) {
        if (signedIn) {
          _init();
        } else {
          state = const FlameState();
        }
      },
      fireImmediately: true,
    );
  }

  final Ref _ref;

  Future<void> _init() async {
    final api = _ref.read(flameApiProvider);
    final opened = await api.record('open'); // daily bonus (server dedups)
    final s = opened ?? await api.stats();
    if (s != null) state = s;
  }

  Future<void> record(String action, {String? text, String? topic, String? tone}) async {
    final s = await _ref
        .read(flameApiProvider)
        .record(action, text: text, topic: topic, tone: tone);
    if (s != null) state = s;
  }
}

final flameProvider =
    StateNotifierProvider<FlameNotifier, FlameState>((ref) => FlameNotifier(ref));
