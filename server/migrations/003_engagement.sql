-- Flames (gamification) + engagement signals that teach the model.

ALTER TABLE users ADD COLUMN IF NOT EXISTS flame_points INTEGER NOT NULL DEFAULT 0;

-- Every like / share / copy / open / create. For like/share/copy we keep the
-- affirmation text + topic/tone so the generator can lean into what resonated.
CREATE TABLE IF NOT EXISTS engagement (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  action     TEXT NOT NULL,                 -- like | share | copy | open | create
  text       TEXT,
  topic      TEXT,
  tone       TEXT,
  flames     INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS engagement_user_idx ON engagement(user_id, created_at DESC);
