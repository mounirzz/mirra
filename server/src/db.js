import pg from "pg";

// Railway injects DATABASE_URL. SSL is required on Railway's public URL; the
// internal URL doesn't need it — enable it loosely so both work.
const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
  console.warn("DATABASE_URL is not set — the API will fail to reach Postgres.");
}

export const pool = new pg.Pool({
  connectionString,
  ssl: connectionString?.includes("railway")
    ? { rejectUnauthorized: false }
    : undefined,
  max: 5,
});

export const query = (text, params) => pool.query(text, params);

/** Upserts the caller into `users` so foreign keys hold. */
export async function ensureUser(userId, email) {
  await query(
    `INSERT INTO users (id, email) VALUES ($1, $2)
     ON CONFLICT (id) DO UPDATE SET email = COALESCE(EXCLUDED.email, users.email)`,
    [userId, email ?? null],
  );
}
