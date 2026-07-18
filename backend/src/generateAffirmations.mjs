// POST /affirmations (auth) → the user's personalized affirmations for the day.
//
// Flow: verify auth → apply defaults → return today's cached set if it exists →
// otherwise call OpenAI (SERVER-SIDE; key from env), validate + dedupe against
// recent days, save, and return. Never crashes the screen: on any failure it
// falls back to the most recent saved set, then to a built-in list.
//
// The OpenAI key lives only in this function's env (OPENAI_API_KEY) — it is
// never sent to or stored by the app.

import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  GetCommand,
  PutCommand,
  QueryCommand,
} from "@aws-sdk/lib-dynamodb";
import { userId, json } from "./_auth.mjs";
import {
  SYSTEM_PROMPT,
  applyDefaults,
  buildUserPrompt,
  validateAffirmations,
  dedupe,
  normalizeText,
  prefsSignature,
  FALLBACK,
} from "./_affirmations.mjs";

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE = process.env.AFFIRMATIONS_TABLE;
const OPENAI_KEY = process.env.OPENAI_API_KEY;
const OPENAI_MODEL = process.env.OPENAI_MODEL || "gpt-4o-mini";

const isoDate = (d) => d.toISOString().slice(0, 10);
const isValidDate = (s) => typeof s === "string" && /^\d{4}-\d{2}-\d{2}$/.test(s);

function daysBefore(dateStr, n) {
  const d = new Date(`${dateStr}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() - n);
  return isoDate(d);
}

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
  const content = data?.choices?.[0]?.message?.content ?? "{}";
  return JSON.parse(content);
}

async function recentDedup(uid, localDate) {
  const res = await ddb.send(
    new QueryCommand({
      TableName: TABLE,
      KeyConditionExpression: "userId = :u AND localDate BETWEEN :from AND :to",
      ExpressionAttributeValues: {
        ":u": uid,
        ":from": daysBefore(localDate, 30),
        ":to": daysBefore(localDate, 1),
      },
    }),
  );
  const texts = [];
  for (const item of res.Items ?? []) {
    for (const a of item.affirmations ?? []) if (a?.text) texts.push(a.text);
  }
  return { avoidTexts: texts.slice(-60), normalized: texts.map(normalizeText) };
}

async function mostRecentSaved(uid) {
  const res = await ddb.send(
    new QueryCommand({
      TableName: TABLE,
      KeyConditionExpression: "userId = :u",
      ExpressionAttributeValues: { ":u": uid },
      ScanIndexForward: false,
      Limit: 1,
    }),
  );
  return res.Items?.[0]?.affirmations ?? null;
}

export const handler = async (event) => {
  const uid = userId(event);
  if (!uid) return json(401, { success: false, code: "UNAUTHORIZED", message: "Sign in required." });

  let body = {};
  try {
    body = JSON.parse(event.body || "{}");
  } catch {
    return json(400, { success: false, code: "BAD_REQUEST", message: "Invalid JSON." });
  }

  const localDate = isValidDate(body.localDate) ? body.localDate : isoDate(new Date());
  const ctx = applyDefaults(body);
  const signature = prefsSignature(ctx);
  const force = body.force === true;

  // 1. Same day AND same preferences → reuse the day's set. If the user changed
  //    a preference (signature differs) — or asks to force — we regenerate.
  try {
    const cached = await ddb.send(
      new GetCommand({ TableName: TABLE, Key: { userId: uid, localDate } }),
    );
    if (!force && cached.Item?.affirmations?.length && cached.Item.prefsSignature === signature) {
      return json(200, { affirmations: cached.Item.affirmations, cached: true, date: localDate });
    }
  } catch (e) {
    console.error("affirmations: cache read failed", e.message);
  }

  // 2. No key configured → graceful fallback (recent, else built-in).
  if (!OPENAI_KEY) {
    console.warn("affirmations: OPENAI_API_KEY not set — returning fallback");
    const recent = await mostRecentSaved(uid).catch(() => null);
    return json(200, { affirmations: recent ?? FALLBACK, source: "fallback", date: localDate });
  }

  // 3. Generate (one retry on transient failure / too many duplicates).
  let avoidTexts = [];
  let normalized = [];
  try {
    ({ avoidTexts, normalized } = await recentDedup(uid, localDate));
  } catch (e) {
    console.error("affirmations: dedup query failed", e.message);
  }

  let best = [];
  let lastError;
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const parsed = await callOpenAI(buildUserPrompt(ctx, avoidTexts));
      const { affirmations } = validateAffirmations(parsed, ctx.count);
      const unique = dedupe(affirmations, normalized);
      if (unique.length > best.length) best = unique;
      if (best.length >= Math.ceil(ctx.count * 0.6)) break;
      // Expand the avoid list so the retry doesn't repeat what we just got.
      avoidTexts = [...avoidTexts, ...affirmations.map((a) => a.text)];
      normalized = [...normalized, ...affirmations.map((a) => normalizeText(a.text))];
    } catch (e) {
      lastError = e;
      console.error(`affirmations: generation attempt ${attempt + 1} failed`, e.message);
    }
  }

  // 4. Success → save today's set and return.
  if (best.length > 0) {
    const affirmations = best.slice(0, ctx.count);
    try {
      await ddb.send(
        new PutCommand({
          TableName: TABLE,
          Item: {
            userId: uid,
            localDate,
            affirmations,
            prefsSignature: signature,
            model: OPENAI_MODEL,
            createdAt: Date.now(),
          },
        }),
      );
    } catch (e) {
      console.error("affirmations: save failed", e.message);
    }
    return json(200, { affirmations, cached: false, date: localDate });
  }

  // 5. Hard failure → recent saved set, else built-in fallback.
  if (lastError) console.error("affirmations: giving up", lastError.message);
  const recent = await mostRecentSaved(uid).catch(() => null);
  if (recent) return json(200, { affirmations: recent, source: "recent", date: localDate });
  return json(200, { affirmations: FALLBACK, source: "fallback", date: localDate });
};
