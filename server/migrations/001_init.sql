-- Mirra relational schema (Postgres). Run by `npm run migrate` on boot.
-- Idempotent: safe to run repeatedly.

CREATE TABLE IF NOT EXISTS users (
  id         TEXT PRIMARY KEY,               -- Cognito `sub`
  email      TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- One row per user: the whole preference set (mirrors the app's onboarding +
-- content preferences). Arrays are first-class so the data stays queryable.
CREATE TABLE IF NOT EXISTS preferences (
  user_id            TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  age_range          TEXT,
  gender             TEXT,
  mood               TEXT,
  mood_factors       TEXT[] NOT NULL DEFAULT '{}',
  motivation_sources TEXT[] NOT NULL DEFAULT '{}',
  content_topics     TEXT[] NOT NULL DEFAULT '{}',
  improve            TEXT[] NOT NULL DEFAULT '{}',
  custom_answers     TEXT[] NOT NULL DEFAULT '{}',
  religion           TEXT,
  language           TEXT NOT NULL DEFAULT 'en',
  muted_categories   TEXT[] NOT NULL DEFAULT '{}',
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- One row per affirmation the model produced (queryable, dedup-friendly).
CREATE TABLE IF NOT EXISTS affirmations (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  local_date DATE NOT NULL,
  text       TEXT NOT NULL,
  topic      TEXT NOT NULL,
  tone       TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS affirmations_user_date_idx ON affirmations(user_id, local_date);

-- One row per user per day: marks that a set was generated + the preference
-- signature used, so we regenerate when preferences change.
CREATE TABLE IF NOT EXISTS affirmation_days (
  user_id         TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  local_date      DATE NOT NULL,
  prefs_signature TEXT NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, local_date)
);

-- Account-tied custom themes (images live in S3; here we keep the metadata).
CREATE TABLE IF NOT EXISTS themes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  image_url  TEXT NOT NULL,
  font       TEXT NOT NULL DEFAULT 'serif',
  text_color TEXT NOT NULL DEFAULT 'FFFFFFFF',
  dark       BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS themes_user_idx ON themes(user_id);

CREATE TABLE IF NOT EXISTS favorites (
  user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  quote_id   TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, quote_id)
);
