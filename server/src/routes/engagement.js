import { Router } from "express";
import { ensureUser, query } from "../db.js";
import { flameLevel } from "../affirmations.js";

export const engagementRouter = Router();

// Flames per action. like is the strongest single tap; share/copy = +1.
const FLAMES = { like: 2, share: 1, copy: 1, open: 5, create: 5 };

engagementRouter.get("/", async (req, res) => {
  const u = await query("SELECT flame_points FROM users WHERE id = $1", [req.userId]);
  const counts = await query(
    "SELECT action, count(*)::int AS n FROM engagement WHERE user_id = $1 GROUP BY action",
    [req.userId],
  );
  res.json({
    ...flameLevel(u.rows[0]?.flame_points ?? 0),
    counts: Object.fromEntries(counts.rows.map((r) => [r.action, r.n])),
  });
});

engagementRouter.post("/", async (req, res) => {
  await ensureUser(req.userId, req.email);
  const b = req.body ?? {};
  const action = String(b.action || "");
  if (!(action in FLAMES)) return res.status(400).json({ error: "invalid action" });

  // The daily "open" bonus is awarded once per local day.
  if (action === "open") {
    const already = await query(
      "SELECT 1 FROM engagement WHERE user_id = $1 AND action = 'open' AND created_at::date = now()::date LIMIT 1",
      [req.userId],
    );
    if (already.rowCount) {
      const u = await query("SELECT flame_points FROM users WHERE id = $1", [req.userId]);
      return res.json({ ...flameLevel(u.rows[0]?.flame_points ?? 0), awarded: 0 });
    }
  }

  const flames = FLAMES[action];
  await query(
    "INSERT INTO engagement (user_id, action, text, topic, tone, flames) VALUES ($1,$2,$3,$4,$5,$6)",
    [req.userId, action, b.text ?? null, b.topic ?? null, b.tone ?? null, flames],
  );
  const upd = await query(
    "UPDATE users SET flame_points = flame_points + $2 WHERE id = $1 RETURNING flame_points",
    [req.userId, flames],
  );
  res.json({ ...flameLevel(upd.rows[0].flame_points), awarded: flames });
});
