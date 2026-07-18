# Mirra backend

Serverless AWS backend for **login (Apple + Google)**, **per-user theme
images**, and **AI-personalized daily affirmations**. Provisioned with AWS SAM:

- **Cognito User Pool** — federated Sign in with Apple + Google; issues JWTs.
- **API Gateway (HTTP API)** — protected by the Cognito JWT authorizer.
- **Lambda** — `POST /themes/upload-url` (presigned S3 PUT), `GET/POST /themes`,
  `DELETE /themes/{themeId}`, and `POST /affirmations` (calls OpenAI server-side).
- **DynamoDB** `mirra-user-themes` (saved themes) and `mirra-affirmations` (each
  user's daily generated set, keyed by Cognito `sub` + local date).
- Images land in the existing **S3** bucket under `themes/users/<sub>/<uuid>.jpg`.
- The **OpenAI key stays server-side only** (Lambda env var); it is never shipped
  to the app.

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

### OpenAI (for affirmations)
1. Create an API key at <https://platform.openai.com/api-keys>.
2. Pass it **only** as the `OpenAiApiKey` deploy parameter (below) — it lands in
   the `GenerateAffirmationsFn` Lambda's env (`OPENAI_API_KEY`). Never put it in
   the app, a committed file, or Git. Leaving it empty deploys fine; the endpoint
   then returns a graceful fallback until you set it.
3. Optional: override the model with `OpenAiModel` (default `gpt-4o-mini`).

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
    GoogleClientSecret=xxxx \
    OpenAiApiKey="$(cat ~/.mirra_openai_key)"
```

> Keep `OpenAiApiKey` out of your shell history and the repo. Store it in a local
> file (e.g. `~/.mirra_openai_key`) and read it with `$(cat …)`, exactly like the
> Google secret. It is `NoEcho`, so it won't appear in CloudFormation output.

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
| POST   | `/affirmations`         | preference context + `localDate` | `{ affirmations: [{text, topic, tone}], cached }` |

All require `Authorization: Bearer <Cognito idToken>`.

### `POST /affirmations`

Body is the non-PII preference context (no name/email/phone):

```json
{ "ageRange": "25-34", "currentMood": "flat",
  "moodFactors": ["relationships", "self_image"],
  "motivationSources": ["books", "people"],
  "preferredTopics": ["love", "confidence", "motivation"],
  "customAnswers": [], "language": "en", "count": 10,
  "localDate": "2026-07-16" }
```

The function returns the **same set all day** for a given `userId + localDate`
(cached in DynamoDB), dedupes against the last 30 days, retries once on failure,
and falls back to the most recent set — then a built-in list — so the app never
breaks. Missing preferences get safe defaults. Unit-tested in
`backend/test/affirmations.test.mjs` (`node --test test/affirmations.test.mjs`).
