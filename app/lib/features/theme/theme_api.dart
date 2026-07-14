import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/auth/auth_config.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/auth/auth_service.dart';

/// A custom theme saved to the user's account (DynamoDB, keyed by Cognito sub).
class RemoteTheme {
  RemoteTheme({
    required this.themeId,
    required this.imageUrl,
    required this.font,
    required this.textColor,
    required this.dark,
    this.createdAt = 0,
  });

  final String themeId;
  final String imageUrl;
  final String font; // 'serif' | 'sans' | 'mono'
  final String textColor; // ARGB hex, 8 chars
  final bool dark;
  final int createdAt;

  factory RemoteTheme.fromJson(Map<String, dynamic> j) => RemoteTheme(
        themeId: j['themeId'] as String,
        imageUrl: j['imageUrl'] as String,
        font: (j['font'] ?? 'serif') as String,
        textColor: (j['textColor'] ?? 'FFFFFFFF') as String,
        dark: (j['dark'] ?? true) as bool,
        createdAt: (j['createdAt'] as num?)?.toInt() ?? 0,
      );
}

/// Talks to the protected HTTP API for per-account theme storage. Every call
/// attaches the caller's Cognito id token; a missing/expired token throws
/// [AuthException] so callers can prompt sign-in.
class ThemeApi {
  ThemeApi(this._auth);

  final AuthService _auth;

  Future<Map<String, String>> _authHeaders() async {
    final token = await _auth.validIdToken();
    if (token == null) throw AuthException('Please sign in first');
    return {'Authorization': 'Bearer $token'};
  }

  /// Uploads JPEG [bytes] to the user's private folder in S3 and returns the
  /// public image URL. (Presigned PUT → the object name is an unguessable UUID.)
  Future<String> uploadImage(Uint8List bytes) async {
    final res = await http.post(
      Uri.parse('${AuthConfig.apiBaseUrl}/themes/upload-url'),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200) {
      throw AuthException('Could not start upload (${res.statusCode})');
    }
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final put = await http.put(
      Uri.parse(j['uploadUrl'] as String),
      headers: {'Content-Type': 'image/jpeg'},
      body: bytes,
    );
    if (put.statusCode != 200) {
      throw AuthException('Image upload failed (${put.statusCode})');
    }
    return j['imageUrl'] as String;
  }

  Future<RemoteTheme> saveTheme({
    required String imageUrl,
    required String font,
    required String textColor,
    required bool dark,
  }) async {
    final res = await http.post(
      Uri.parse('${AuthConfig.apiBaseUrl}/themes'),
      headers: {...await _authHeaders(), 'Content-Type': 'application/json'},
      body: jsonEncode({
        'imageUrl': imageUrl,
        'font': font,
        'textColor': textColor,
        'dark': dark,
      }),
    );
    if (res.statusCode != 200) {
      throw AuthException('Could not save theme (${res.statusCode})');
    }
    return RemoteTheme.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<RemoteTheme>> listThemes() async {
    final res = await http.get(
      Uri.parse('${AuthConfig.apiBaseUrl}/themes'),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200) {
      throw AuthException('Could not load themes (${res.statusCode})');
    }
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final items = (j['themes'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(RemoteTheme.fromJson)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
    return items;
  }

  Future<void> deleteTheme(String themeId) async {
    final res = await http.delete(
      Uri.parse('${AuthConfig.apiBaseUrl}/themes/$themeId'),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200) {
      throw AuthException('Could not delete theme (${res.statusCode})');
    }
  }
}

final themeApiProvider =
    Provider<ThemeApi>((ref) => ThemeApi(ref.watch(authServiceProvider)));
