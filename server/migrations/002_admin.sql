-- Admin/analytics: user activity + IP location, AI cost tracking, subscriptions.

-- Enrich users with last activity and coarse IP-based location.
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_ip      TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS country      TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS region       TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS city         TEXT;

-- One row per model call: token usage + estimated cost (USD).
CREATE TABLE IF NOT EXISTS ai_usage (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           TEXT REFERENCES users(id) ON DELETE CASCADE,
  model             TEXT NOT NULL,
  prompt_tokens     INTEGER NOT NULL DEFAULT 0,
  completion_tokens INTEGER NOT NULL DEFAULT 0,
  cost_usd          NUMERIC(12,6) NOT NULL DEFAULT 0,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ai_usage_user_idx    ON ai_usage(user_id);
CREATE INDEX IF NOT EXISTS ai_usage_created_idx ON ai_usage(created_at);

-- Subscription state per user (app-reported for now; server-side receipt
-- validation can replace `source='app'` later).
CREATE TABLE IF NOT EXISTS subscriptions (
  user_id    TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  plan       TEXT,                             -- weekly / monthly / annual / lifetime
  status     TEXT NOT NULL DEFAULT 'free',     -- free / trial / active / expired / cancelled
  source     TEXT,                             -- app / app_store / play / manual
  started_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
