import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/auth/auth_config.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/auth/auth_service.dart';
import '../../core/i18n/language_provider.dart';
import '../affirmations/affirmation_context.dart';
import '../onboarding/providers/onboarding_provider.dart';
import 'providers/content_topics_provider.dart';
import 'providers/settings_providers.dart';

/// Turns the app's stored preferences into the structured (non-PII) payload the
/// server persists in Postgres. Labels → canonical tokens; free-text goes to
/// customAnswers.
Map<String, dynamic> buildPreferencesPayload({
  required Map<String, String> answers,
  required Set<String> contentTopics,
  required String language,
  required List<String> mutedCategories,
}) {
  final custom = <String>[];
  List<String> tokens(String? multi, Map<String, String> known) {
    final out = <String>[];
    for (final v in OnboardingNotifier.splitMulti(multi)) {
      final t = known[v];
      if (t != null) {
        out.add(t);
      } else {
        custom.add(v);
      }
    }
    return out;
  }

  final age = answers['age'];
  final mood = answers['mood'];
  return {
    'ageRange': age?.replaceAll(RegExp(r'\s+'), '').replaceAll('–', '-'),
    'gender': answers['gender'],
    'mood': mood?.toLowerCase(),
    'moodFactors': tokens(answers['feeling_source'], kMoodFactorTokens),
    'motivationSources': tokens(answers['motivation_source'], kMotivationTokens),
    'improve': tokens(answers['improve'], kImproveTopicTokens),
    'contentTopics': contentTopics.toList(),
    'customAnswers':
        custom.map((s) => s.trim()).where((s) => s.isNotEmpty).take(10).toList(),
    'religion': answers['religion'],
    'language': language,
    'mutedCategories': mutedCategories,
  };
}

class PreferencesApi {
  PreferencesApi(this._auth);

  final AuthService _auth;

  Future<void> put(Map<String, dynamic> payload) async {
    final token = await _auth.validIdToken();
    if (token == null) return; // signed out → nothing to sync
    await http.put(
      Uri.parse('${AuthConfig.apiBaseUrl}/preferences'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
  }
}

final preferencesApiProvider =
    Provider<PreferencesApi>((ref) => PreferencesApi(ref.watch(authServiceProvider)));

/// Pushes the user's preferences to Postgres on sign-in and whenever they
/// change (debounced). Best-effort: failures are swallowed so the UI is never
/// affected. Keep it alive by watching it once from the app root.
class PreferencesSyncNotifier extends StateNotifier<int> {
  PreferencesSyncNotifier(this._ref) : super(0) {
    _ref.listen<bool>(
      isSignedInProvider,
      (_, signedIn) {
        if (signedIn) _push();
      },
      fireImmediately: true,
    );
    _ref.listen(onboardingProvider, (_, _) => _schedule());
    _ref.listen(contentTopicsProvider, (_, _) => _schedule());
    _ref.listen(languageProvider, (_, _) => _schedule());
    _ref.listen(mutedCategoriesProvider, (_, _) => _schedule());
  }

  final Ref _ref;
  Timer? _debounce;

  void _schedule() {
    if (!_ref.read(isSignedInProvider)) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), _push);
  }

  Future<void> _push() async {
    if (!_ref.read(isSignedInProvider)) return;
    final payload = buildPreferencesPayload(
      answers: _ref.read(onboardingProvider),
      contentTopics: _ref.read(contentTopicsProvider),
      language: _ref.read(languageProvider).code,
      mutedCategories: _ref.read(mutedCategoriesProvider),
    );
    try {
      await _ref.read(preferencesApiProvider).put(payload);
      state++;
    } catch (_) {
      // best-effort sync
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final preferencesSyncProvider =
    StateNotifierProvider<PreferencesSyncNotifier, int>(
  (ref) => PreferencesSyncNotifier(ref),
);
