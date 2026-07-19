import { Router } from "express";
import { ensureUser, pool, query } from "../db.js";
import {
  SYSTEM_PROMPT,
  applyDefaults,
  buildUserPrompt,
  dedupe,
  normalizeText,
  prefsSignature,
  validateAffirmations,
  FALLBACK,
} from "../affirmations.js";

export const affirmationsRouter = Router();

const OPENAI_KEY = process.env.OPENAI_API_KEY;
const OPENAI_MODEL = process.env.OPENAI_MODEL || "gpt-4o-mini";

// USD per 1M tokens [input, output]. Extend as you add models.
const PRICES = {
  "gpt-4o-mini": [0.15, 0.6],
  "gpt-4o": [2.5, 10],
  "gpt-4.1-mini": [0.4, 1.6],
};
const costUsd = (model, promptTokens, completionTokens) => {
  const [inp, out] = PRICES[model] ?? PRICES["gpt-4o-mini"];
  return (promptTokens / 1e6) * inp + (completionTokens / 1e6) * out;
};

const isoDate = (d) => d.toISOString().slice(0, 10);
const isValidDate = (s) => typeof s === "string" && /^\d{4}-\d{2}-\d{2}$/.test(s);
const daysBefore = (dateStr, n) => {
  const d = new Date(`${dateStr}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() - n);
  return isoDate(d);
};

async function callOpenAI(userPrompt) {
  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${OPENAI_KEY}`,
    },
    body: JSON.stringify({
      model: OPENAI_MODEL,
      temperature: 0.9,
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: userPrompt },
      ],
    }),
  });
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    throw new Error(`OpenAI ${res.status}: ${body.slice(0, 200)}`);
  }
  const data = await res.json();
  return {
    parsed: JSON.parse(data?.choices?.[0]?.message?.content ?? "{}"),
    usage: data?.usage ?? { prompt_tokens: 0, completion_tokens: 0 },
  };
}

async function mostRecentSaved(uid) {
  const r = await query(
    `SELECT text, topic, tone FROM affirmations
      WHERE user_id = $1 AND local_date = (
        SELECT max(local_date) FROM affirmations WHERE user_id = $1)
      ORDER BY created_at`,
    [uid],
  );
  return r.rowCount ? r.rows : null;
}

affirmationsRouter.post("/", async (req, res) => {
  const uid = req.userId;
  await ensureUser(uid, req.email);

  const body = req.body ?? {};
  const localDate = isValidDate(body.localDate) ? body.localDate : isoDate(new Date());
  const ctx = applyDefaults(body);
  const signature = prefsSignature(ctx);
  const force = body.force === true;

  // 1. Same day + same preferences → reuse the saved set.
  if (!force) {
    const day = await query(
      "SELECT prefs_signature FROM affirmation_days WHERE user_id = $1 AND local_date = $2",
      [uid, localDate],
    );
    if (day.rowCount && day.rows[0].prefs_signature === signature) {
      const rows = await query(
        "SELECT text, topic, tone FROM affirmations WHERE user_id = $1 AND local_date = $2 ORDER BY created_at",
        [uid, localDate],
      );
      if (rows.rowCount) {
        return res.json({ affirmations: rows.rows, cached: true, date: localDate });
      }
    }
  }

  // 2. No key → graceful fallback.
  if (!OPENAI_KEY) {
    const recent = await mostRecentSaved(uid).catch(() => null);
    return res.json({ affirmations: recent ?? FALLBACK, source: "fallback", date: localDate });
  }

  // 3. Dedup material (last 30 days).
  const recent = await query(
    "SELECT text FROM affirmations WHERE user_id = $1 AND local_date BETWEEN $2 AND $3",
    [uid, daysBefore(localDate, 30), daysBefore(localDate, 1)],
  ).catch(() => ({ rows: [] }));
  let avoidTexts = recent.rows.map((r) => r.text).slice(-60);
  let normalized = recent.rows.map((r) => normalizeText(r.text));

  // 4. Generate (one retry on failure / too many duplicates).
  let best = [];
  let lastError;
  let promptTokens = 0;
  let completionTokens = 0;
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const { parsed, usage } = await callOpenAI(buildUserPrompt(ctx, avoidTexts));
      promptTokens += usage.prompt_tokens ?? 0;
      completionTokens += usage.completion_tokens ?? 0;
      const { affirmations } = validateAffirmations(parsed, ctx.count);
      const unique = dedupe(affirmations, normalized);
      if (unique.length > best.length) best = unique;
      if (best.length >= Math.ceil(ctx.count * 0.6)) break;
      avoidTexts = [...avoidTexts, ...affirmations.map((a) => a.text)];
      normalized = [...normalized, ...affirmations.map((a) => normalizeText(a.text))];
    } catch (e) {
      lastError = e;
      console.error(`affirmations: attempt ${attempt + 1} failed`, e.message);
    }
  }

  // Record the token usage + estimated cost of this request (fire-and-forget).
  if (promptTokens || completionTokens) {
    query(
      `INSERT INTO ai_usage (user_id, model, prompt_tokens, completion_tokens, cost_usd)
       VALUES ($1,$2,$3,$4,$5)`,
      [uid, OPENAI_MODEL, promptTokens, completionTokens, costUsd(OPENAI_MODEL, promptTokens, completionTokens)],
    ).catch((e) => console.error("ai_usage insert:", e.message));
  }

  // 5. Success → replace the day's set atomically.
  if (best.length > 0) {
    const affirmations = best.slice(0, ctx.count);
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      await client.query("DELETE FROM affirmations WHERE user_id = $1 AND local_date = $2", [uid, localDate]);
      for (const a of affirmations) {
        await client.query(
          "INSERT INTO affirmations (user_id, local_date, text, topic, tone) VALUES ($1,$2,$3,$4,$5)",
          [uid, localDate, a.text, a.topic, a.tone],
        );
      }
      await client.query(
        `INSERT INTO affirmation_days (user_id, local_date, prefs_signature) VALUES ($1,$2,$3)
         ON CONFLICT (user_id, local_date) DO UPDATE SET prefs_signature = EXCLUDED.prefs_signature, created_at = now()`,
        [uid, localDate, signature],
      );
      await client.query("COMMIT");
    } catch (e) {
      await client.query("ROLLBACK");
      console.error("affirmations: save failed", e.message);
    } finally {
      client.release();
    }
    return res.json({ affirmations, cached: false, date: localDate });
  }

  // 6. Hard failure → recent set, else built-in fallback.
  if (lastError) console.error("affirmations: giving up", lastError.message);
  const fallback = await mostRecentSaved(uid).catch(() => null);
  res.json({ affirmations: fallback ?? FALLBACK, source: fallback ? "recent" : "fallback", date: localDate });
});
