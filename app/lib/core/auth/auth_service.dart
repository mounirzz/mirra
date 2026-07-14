import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import 'auth_config.dart';

/// The tokens Cognito hands back after a successful login.
class AuthTokens {
  const AuthTokens({
    required this.idToken,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String idToken;
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;

  /// Email claim from the id token (may be null if the provider hid it).
  String? get email => _claim('email') as String?;

  Object? _claim(String key) => decodeJwt(idToken)[key];
}

/// Drives the Cognito Hosted UI OAuth **authorization-code + PKCE** flow and
/// keeps the resulting tokens in the iOS Keychain. No client secret is used —
/// the app client is public.
class AuthService {
  AuthService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;

  static const _kRefresh = 'mirra.refresh_token';
  static const _kId = 'mirra.id_token';
  static const _kAccess = 'mirra.access_token';
  static const _kExp = 'mirra.expires_at';

  /// Launches the Hosted UI for [idp] (`SignInWithApple` / `Google`, or null to
  /// show Cognito's provider chooser) and returns the tokens on success.
  /// Throws on user-cancel or any OAuth error.
  Future<AuthTokens> signIn({String? idp}) async {
    final verifier = _randomUrlSafe(64);
    final challenge = _s256(verifier);

    final authorizeUrl = Uri.parse('${AuthConfig.hostedUiDomain}/oauth2/authorize')
        .replace(queryParameters: {
      'response_type': 'code',
      'client_id': AuthConfig.userPoolClientId,
      'redirect_uri': AuthConfig.redirectUri,
      'scope': AuthConfig.scopes.join(' '),
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
      'identity_provider': ?idp,
    }).toString();

    final result = await FlutterWebAuth2.authenticate(
      url: authorizeUrl,
      callbackUrlScheme: 'mirra',
    );

    final params = Uri.parse(result).queryParameters;
    final code = params['code'];
    if (code == null) {
      throw AuthException(params['error_description'] ?? params['error'] ?? 'Login failed');
    }

    final tokens = await _exchange({
      'grant_type': 'authorization_code',
      'client_id': AuthConfig.userPoolClientId,
      'code': code,
      'redirect_uri': AuthConfig.redirectUri,
      'code_verifier': verifier,
    });
    await _persist(tokens);
    return tokens;
  }

  /// Returns a valid id token, refreshing if it's expired/near-expiry.
  /// Null if the user isn't signed in (or the refresh token is dead).
  Future<String?> validIdToken() async {
    final tokens = await currentTokens();
    if (tokens == null) return null;
    if (tokens.expiresAt.isAfter(DateTime.now().add(const Duration(seconds: 60)))) {
      return tokens.idToken;
    }
    final refresh = tokens.refreshToken;
    if (refresh == null) return null;
    try {
      final refreshed = await _exchange({
        'grant_type': 'refresh_token',
        'client_id': AuthConfig.userPoolClientId,
        'refresh_token': refresh,
      }, keepRefresh: refresh);
      await _persist(refreshed);
      return refreshed.idToken;
    } on AuthException {
      await signOut();
      return null;
    }
  }

  /// Reads the stored tokens (without refreshing). Null if signed out.
  Future<AuthTokens?> currentTokens() async {
    final id = await _storage.read(key: _kId);
    final exp = await _storage.read(key: _kExp);
    if (id == null || exp == null) return null;
    return AuthTokens(
      idToken: id,
      accessToken: await _storage.read(key: _kAccess) ?? '',
      refreshToken: await _storage.read(key: _kRefresh),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(int.tryParse(exp) ?? 0),
    );
  }

  Future<void> signOut() async {
    await Future.wait([
      _storage.delete(key: _kId),
      _storage.delete(key: _kAccess),
      _storage.delete(key: _kRefresh),
      _storage.delete(key: _kExp),
    ]);
  }

  Future<AuthTokens> _exchange(Map<String, String> body, {String? keepRefresh}) async {
    final res = await http.post(
      Uri.parse('${AuthConfig.hostedUiDomain}/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );
    if (res.statusCode != 200) {
      throw AuthException('Token exchange failed (${res.statusCode})');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return AuthTokens(
      idToken: json['id_token'] as String,
      accessToken: json['access_token'] as String? ?? '',
      // A refresh_token grant does not return a new refresh token — reuse it.
      refreshToken: json['refresh_token'] as String? ?? keepRefresh,
      expiresAt: DateTime.now().add(Duration(seconds: (json['expires_in'] as num?)?.toInt() ?? 3600)),
    );
  }

  Future<void> _persist(AuthTokens t) async {
    await _storage.write(key: _kId, value: t.idToken);
    await _storage.write(key: _kAccess, value: t.accessToken);
    if (t.refreshToken != null) {
      await _storage.write(key: _kRefresh, value: t.refreshToken);
    }
    await _storage.write(key: _kExp, value: '${t.expiresAt.millisecondsSinceEpoch}');
  }

  // ── PKCE helpers ──────────────────────────────────────────────────────────
  static String _randomUrlSafe(int bytes) {
    final rnd = Random.secure();
    final data = List<int>.generate(bytes, (_) => rnd.nextInt(256));
    return base64UrlEncode(data).replaceAll('=', '');
  }

  static String _s256(String verifier) =>
      base64UrlEncode(sha256.convert(ascii.encode(verifier)).bytes).replaceAll('=', '');
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Decodes a JWT's payload claims (no signature check — client-side display only).
Map<String, dynamic> decodeJwt(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) return const {};
  final payload = parts[1];
  final normalized = base64Url.normalize(payload);
  return jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;
}
