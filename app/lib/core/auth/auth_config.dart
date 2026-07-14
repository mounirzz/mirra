/// AWS backend configuration for auth + per-user theme sync.
///
/// Values come from the `mirra-backend` CloudFormation stack outputs
/// (region us-east-1, account 975050297673). These are **public** client
/// identifiers — safe to ship in the app. The Cognito app client is a public
/// (mobile) client with no secret; login uses the Hosted UI OAuth code flow
/// with PKCE.
class AuthConfig {
  const AuthConfig._();

  static const region = 'us-east-1';

  static const userPoolId = 'us-east-1_ufMj606bz';
  static const userPoolClientId = '2880m1ablar95qk6nfrpuuecg8';

  /// Cognito Hosted UI domain (Apple + Google federation live here).
  static const hostedUiDomain =
      'https://mirra-auth-975050297673.auth.us-east-1.amazoncognito.com';

  /// Base URL of the protected HTTP API (upload-url / themes CRUD).
  static const apiBaseUrl =
      'https://fjpayb0sm9.execute-api.us-east-1.amazonaws.com';

  /// Deep link the Hosted UI redirects back to (login + logout both registered
  /// on the Cognito app client as `mirra://auth`).
  static const redirectUri = 'mirra://auth';
  static const signOutUri = 'mirra://auth';

  static const scopes = ['openid', 'email', 'profile'];

  /// Jump straight to a provider's login instead of the Hosted UI chooser:
  /// pass `identity_provider=SignInWithApple` or `Google` on /oauth2/authorize.
  static const idpApple = 'SignInWithApple';
  static const idpGoogle = 'Google';
}
