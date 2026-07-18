import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/auth/auth_config.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/auth/auth_service.dart';

/// One affirmation as returned by the backend model call.
class AiAffirmation {
  const AiAffirmation({required this.text, required this.topic, required this.tone});

  final String text;
  final String topic;
  final String tone;

  factory AiAffirmation.fromJson(Map<String, dynamic> j) => AiAffirmation(
        text: (j['text'] ?? '').toString().trim(),
        topic: (j['topic'] ?? 'general').toString(),
        tone: (j['tone'] ?? 'supportive').toString(),
      );
}

/// Calls the protected `POST /affirmations` endpoint (which does the actual
/// OpenAI call server-side). Sends only the preference context — no PII.
class AffirmationApi {
  AffirmationApi(this._auth);

  final AuthService _auth;

  Future<List<AiAffirmation>> fetchDaily({
    required Map<String, dynamic> context,
    required String localDate,
  }) async {
    final token = await _auth.validIdToken();
    if (token == null) throw AuthException('Please sign in first');

    final res = await http.post(
      Uri.parse('${AuthConfig.apiBaseUrl}/affirmations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({...context, 'localDate': localDate}),
    );
    if (res.statusCode != 200) {
      throw AuthException('Affirmations request failed (${res.statusCode})');
    }
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = (j['affirmations'] as List?) ?? const [];
    final list = raw
        .cast<Map<String, dynamic>>()
        .map(AiAffirmation.fromJson)
        .where((a) => a.text.isNotEmpty)
        .toList();
    if (list.isEmpty) throw AuthException('No affirmations returned');
    return list;
  }
}

final affirmationApiProvider =
    Provider<AffirmationApi>((ref) => AffirmationApi(ref.watch(authServiceProvider)));
