# Mirra backend

Serverless AWS backend for **login (Apple + Google)** and **per-user theme
images**. Provisioned with AWS SAM:

- **Cognito User Pool** — federated Sign in with Apple + Google; issues JWTs.
- **API Gateway (HTTP API)** — protected by the Cognito JWT authorizer.
- **Lambda** — `POST /themes/upload-url` (presigned S3 PUT), `GET/POST /themes`,
  `DELETE /themes/{themeId}`.
- **DynamoDB** `mirra-user-themes` — each user's saved themes (keyed by Cognito
  `sub`), so they follow the user across reinstalls / devices.
- Images land in the existing **S3** bucket under `themes/users/<sub>/<uuid>.jpg`.

## 1. Prerequisites (you set these up once)

### Google
1. Google Cloud Console → APIs & Services → Credentials → **Create OAuth client ID**.
2. Type **Web application** (Cognito uses the web client).
3. Authorized redirect URI (add after step 3 gives you the domain, or use the
   pattern): `https://mirra-auth-<ACCOUNT_ID>.auth.us-east-1.amazoncognito.com/oauth2/idpresponse`
4. Note the **Client ID** and **Client secret**.
5. (Also create an **iOS** OAuth client for the native Google sign-in in the app.)

### Apple (you have a paid Apple Developer account)
1. Certificates, IDs & Profiles → **Identifiers** → create a **Services ID**
   (e.g. `com.mirra.signin`) → enable "Sign in with Apple".
2. Configure its Return URL:
   `https://mirra-auth-<ACCOUNT_ID>.auth.us-east-1.amazoncognito.com/oauth2/idpresponse`
3. **Keys** → create a key with "Sign in with Apple" → download the **.p8**.
4. Note: **Team ID**, **Key ID**, the **Services ID**, and the `.p8` contents.

### AWS tooling
- `brew install aws-sam-cli`
- The deploying IAM identity needs rights to create Cognito / Lambda / API
  Gateway / DynamoDB / IAM / S3. The current `Mirra` key is S3-only — deploy with
  an admin profile or attach a deploy policy.

## 2. Deploy

```bash
cd backend
sam build
sam deploy --guided \
  --stack-name mirra-backend \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    AppleServicesId=com.mirra.signin \
    AppleTeamId=XXXXXXXXXX \
    AppleKeyId=XXXXXXXXXX \
    ApplePrivateKey="$(cat AuthKey_XXXXXXXXXX.p8)" \
    GoogleClientId=xxxx.apps.googleusercontent.com \
    GoogleClientSecret=xxxx
```

> **⚠️ Apple private key format — the #1 deploy failure.**
> Cognito's Apple IdP expects `ApplePrivateKey` to be the **base64 body of the
> `.p8` only** — strip the `-----BEGIN/END PRIVATE KEY-----` lines and all
> newlines. Passing the full PEM fails at stack-create with
> *"Provided private key cannot be used for Sign in with Apple"* (the
> credentials are fine; Cognito just can't parse the armored PEM). Extract it:
> ```bash
> grep -v 'PRIVATE KEY' AuthKey_XXXXXXXXXX.p8 | tr -d '\n'
> ```
> Multi-line/space values also get mangled by CLI `--parameter-overrides`; pass
> params via a `samconfig.toml` (`parameter_overrides = [ ... ]` list form,
> `sam deploy --config-file`) to avoid shell splitting. Deployed values live in
> `app/lib/core/auth/auth_config.dart`.

## 3. Wire the app

After deploy, note the stack **Outputs**:
- `ApiBaseUrl`, `UserPoolId`, `UserPoolClientId`, `HostedUiDomain`.

Put them in the Flutter app config (`lib/core/auth/auth_config.dart`, added on the
app side) so the auth + upload services can reach Cognito and the API.

## Endpoints

| Method | Path                    | Body / Params            | Returns                         |
|--------|-------------------------|--------------------------|---------------------------------|
| POST   | `/themes/upload-url`    | –                        | `{ uploadUrl, imageUrl }`       |
| POST   | `/themes`               | `{ imageUrl, font, textColor, dark }` | saved theme item   |
| GET    | `/themes`               | –                        | `{ themes: [...] }`             |
| DELETE | `/themes/{themeId}`     | –                        | `{ ok: true }`                  |

All require `Authorization: Bearer <Cognito idToken>`.
