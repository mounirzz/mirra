import { Router } from "express";
import { ensureUser, query } from "../db.js";

export const subscriptionRouter = Router();

const COLS = `plan, status, source, started_at AS "startedAt", expires_at AS "expiresAt"`;

subscriptionRouter.get("/", async (req, res) => {
  const r = await query(
    `SELECT ${COLS} FROM subscriptions WHERE user_id = $1`,
    [req.userId],
  );
  res.json({ subscription: r.rows[0] ?? { status: "free" } });
});

// The app reports its subscription state (from in_app_purchase). Server-side
// receipt validation can replace this later without changing the app contract.
subscriptionRouter.put("/", async (req, res) => {
  await ensureUser(req.userId, req.email);
  const b = req.body ?? {};
  const r = await query(
    `INSERT INTO subscriptions (user_id, plan, status, source, started_at, expires_at, updated_at)
     VALUES ($1,$2,$3,$4,$5,$6, now())
     ON CONFLICT (user_id) DO UPDATE SET
        plan = EXCLUDED.plan, status = EXCLUDED.status, source = EXCLUDED.source,
        started_at = EXCLUDED.started_at, expires_at = EXCLUDED.expires_at, updated_at = now()
     RETURNING ${COLS}`,
    [
      req.userId,
      b.plan ?? null,
      b.status ?? "free",
      b.source ?? "app",
      b.startedAt ?? null,
      b.expiresAt ?? null,
    ],
  );
  res.json({ subscription: r.rows[0] });
});
