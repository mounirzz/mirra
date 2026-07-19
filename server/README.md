# Mirra server (Railway + Postgres)

Node/Express API that makes **Postgres the single source of truth** for
preferences, affirmations and themes. It verifies **Cognito** id tokens (auth
stays on AWS) and keeps **OpenAI** + **S3** server-side. Deploys on **Railway**.

```
App ──(Bearer Cognito id token)──▶ this API ──▶ Postgres
                                      ├─ OpenAI (affirmation generation)
                                      └─ S3 presigned PUT (theme images)
```

## Deploy on Railway

1. **New Project → Add PostgreSQL** (Railway sets `DATABASE_URL`).
2. **Add a service from the GitHub repo**, set **Root Directory** to `server/`.
   Railway auto-detects Node and runs `npm start` (which migrates on boot).
3. Add service **Variables** (see `.env.example`):
   - `OPENAI_API_KEY` (+ optional `OPENAI_MODEL`, default `gpt-4o-mini`)
   - `COGNITO_USER_POOL_ID=us-east-1_ufMj606bz`
   - `COGNITO_CLIENT_ID=2880m1ablar95qk6nfrpuuecg8`
   - `AWS_REGION=us-east-1`
   - `S3_BUCKET=mirra-affirmation-bucket`
   - `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (the `Mirra` IAM user — needs
     S3 PutObject on the bucket)
   - Reference `DATABASE_URL` from the Postgres plugin.
4. Railway gives the service a public URL, e.g. `https://mirra-server.up.railway.app`.
   Put it in the app as `AuthConfig.apiBaseUrl` — the endpoint shapes match the
   old AWS API, so it's a one-line switch.

Local: `cp .env.example .env`, fill it, `npm install`, `npm run migrate`, `npm start`.

## Endpoints (all require `Authorization: Bearer <Cognito id token>`)

| Method | Path                 | Body / Params                              | Returns |
|--------|----------------------|--------------------------------------------|---------|
| GET    | `/health`            | – (public)                                 | `{ ok }` |
| GET    | `/preferences`       | –                                          | `{ preferences }` |
| PUT    | `/preferences`       | full preference object                     | `{ preferences }` |
| POST   | `/affirmations`      | preference context + `localDate` (+`force`)| `{ affirmations:[{text,topic,tone}], cached }` |
| POST   | `/themes/upload-url` | –                                          | `{ uploadUrl, imageUrl }` |
| GET    | `/themes`            | –                                          | `{ themes:[...] }` |
| POST   | `/themes`            | `{ imageUrl, font, textColor, dark }`      | saved theme |
| DELETE | `/themes/{themeId}`  | –                                          | `{ ok }` |

Affirmations behave like the AWS version: same set per `userId + localDate`,
regenerated when the preference signature changes, deduped over 30 days, with a
recent/built-in fallback. Schema in `migrations/001_init.sql`.
