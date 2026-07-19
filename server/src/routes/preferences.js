import { Router } from "express";
import { ensureUser, query } from "../db.js";

export const preferencesRouter = Router();

const strArr = (v) =>
  Array.isArray(v) ? v.filter((x) => typeof x === "string") : [];

// The user's current preferences (null if never synced).
preferencesRouter.get("/", async (req, res) => {
  const r = await query("SELECT * FROM preferences WHERE user_id = $1", [req.userId]);
  res.json({ preferences: r.rows[0] ?? null });
});

// Upsert the whole preference set (the app pushes it on change / sign-in).
preferencesRouter.put("/", async (req, res) => {
  await ensureUser(req.userId, req.email);
  const b = req.body ?? {};
  const r = await query(
    `INSERT INTO preferences (
        user_id, age_range, gender, mood, mood_factors, motivation_sources,
        content_topics, improve, custom_answers, religion, language,
        muted_categories, updated_at)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12, now())
     ON CONFLICT (user_id) DO UPDATE SET
        age_range = EXCLUDED.age_range,
        gender = EXCLUDED.gender,
        mood = EXCLUDED.mood,
        mood_factors = EXCLUDED.mood_factors,
        motivation_sources = EXCLUDED.motivation_sources,
        content_topics = EXCLUDED.content_topics,
        improve = EXCLUDED.improve,
        custom_answers = EXCLUDED.custom_answers,
        religion = EXCLUDED.religion,
        language = EXCLUDED.language,
        muted_categories = EXCLUDED.muted_categories,
        updated_at = now()
     RETURNING *`,
    [
      req.userId,
      b.ageRange ?? null,
      b.gender ?? null,
      b.mood ?? null,
      strArr(b.moodFactors),
      strArr(b.motivationSources),
      strArr(b.contentTopics),
      strArr(b.improve),
      strArr(b.customAnswers),
      b.religion ?? null,
      typeof b.language === "string" && b.language ? b.language : "en",
      strArr(b.mutedCategories),
    ],
  );
  res.json({ preferences: r.rows[0] });
});
