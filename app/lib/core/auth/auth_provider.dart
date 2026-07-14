import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';

enum AuthStatus { unknown, signedOut, signedIn }

class AuthState {
  const AuthState({required this.status, this.email, this.busy = false, this.error});

  final AuthStatus status;
  final String? email;
  final bool busy;
  final String? error;

  bool get isSignedIn => status == AuthStatus.signedIn;

  AuthState copyWith({AuthStatus? status, String? email, bool? busy, String? error}) =>
      AuthState(
        status: status ?? this.status,
        email: email ?? this.email,
        busy: busy ?? this.busy,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._service) : super(const AuthState(status: AuthStatus.unknown)) {
    _restore();
  }

  final AuthService _service;

  Future<void> _restore() async {
    final tokens = await _service.currentTokens();
    if (tokens == null) {
      state = const AuthState(status: AuthStatus.signedOut);
    } else {
      state = AuthState(status: AuthStatus.signedIn, email: tokens.email);
    }
  }

  Future<void> signInWithApple() => _signIn(AuthConfigIdp.apple);
  Future<void> signInWithGoogle() => _signIn(AuthConfigIdp.google);

  Future<void> _signIn(String idp) async {
    state = state.copyWith(busy: true, error: null);
    try {
      final tokens = await _service.signIn(idp: idp);
      state = AuthState(status: AuthStatus.signedIn, email: tokens.email);
    } on AuthException catch (e) {
      state = state.copyWith(busy: false, error: e.message);
    } catch (_) {
      // User cancelled the web sheet, or a transport error — stay signed out.
      state = state.copyWith(busy: false, error: null);
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = const AuthState(status: AuthStatus.signedOut);
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authServiceProvider)),
);

/// Convenience: true once the user has signed in.
final isSignedInProvider = Provider<bool>((ref) => ref.watch(authProvider).isSignedIn);

// Kept here to avoid importing auth_config everywhere just for the IdP names.
class AuthConfigIdp {
  static const apple = 'SignInWithApple';
  static const google = 'Google';
}
