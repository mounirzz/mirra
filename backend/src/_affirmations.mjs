// Pure helpers for affirmation generation — prompts, defaults, validation and
// dedup. Kept side-effect-free so they can be unit-tested without AWS/OpenAI.

export const SYSTEM_PROMPT = `You generate short, personalized affirmations for a wellness application.

Create affirmations based only on the user's preferences provided in the request.

The affirmations must:
- match the user's selected topics;
- be appropriate for the user's current mood;
- take into account what is shaping the user's feelings;
- reflect the user's motivation sources when relevant;
- sound natural, supportive and personal;
- contain one clear idea;
- use simple language;
- contain between 5 and 18 words;
- be written in the requested language;
- remain appropriate for a general audience.

For users feeling anxious or flat, use a gentle, calm and reassuring tone.
For users feeling okay or good, use an encouraging and optimistic tone.
For users feeling glowing, use an energetic and confident tone.

Avoid:
- generic motivational clichés;
- exaggerated promises;
- guilt or pressure;
- toxic positivity;
- medical advice;
- diagnoses;
- treatment claims;
- commands that tell the user how they must feel;
- questions, explanations or quotes.

Return only valid JSON matching the requested structure.`;

// Applied when the client omits a preference — never block the user.
export const DEFAULTS = {
  currentMood: "okay",
  preferredTopics: ["confidence", "motivation", "gratitude"],
  language: "en",
  count: 10,
};

// Last-resort content if OpenAI is unavailable and nothing is saved yet.
export const FALLBACK = [
  { text: "I am allowed to grow at my own pace.", topic: "confidence", tone: "gentle" },
  { text: "Small steps I take today still move me forward.", topic: "motivation", tone: "encouraging" },
  { text: "I meet this moment with a little more kindness for myself.", topic: "self_worth", tone: "calm" },
  { text: "What I appreciate today quietly grows tomorrow.", topic: "gratitude", tone: "encouraging" },
  { text: "My worth stays steady, even on difficult days.", topic: "self_worth", tone: "gentle" },
  { text: "I can begin again, gently, whenever I need to.", topic: "motivation", tone: "calm" },
];

const LANGUAGE_NAMES = { en: "English", fr: "French", es: "Spanish", de: "German" };

const clampInt = (v, min, max, fallback) => {
  const n = Number.parseInt(v, 10);
  if (Number.isNaN(n)) return fallback;
  return Math.min(max, Math.max(min, n));
};

const pretty = (token) =>
  String(token)
    .replace(/_/g, " ")
    .replace(/\b\w/g, (c) => c.toUpperCase());

const cleanList = (v, { max = 8, maxLen = 60 } = {}) =>
  Array.isArray(v)
    ? v
        .filter((x) => typeof x === "string")
        .map((x) => x.trim())
        .filter(Boolean)
        .map((x) => (x.length > maxLen ? x.slice(0, maxLen) : x))
        .slice(0, max)
    : [];

/** Fills defaults, clamps count, sanitizes free-text — returns a safe context. */
export function applyDefaults(raw = {}) {
  const language =
    typeof raw.language === "string" && raw.language.trim()
      ? raw.language.trim().toLowerCase().slice(0, 5)
      : DEFAULTS.language;
  const preferredTopics = cleanList(raw.preferredTopics);
  return {
    ageRange: typeof raw.ageRange === "string" ? raw.ageRange.trim().slice(0, 20) : "",
    currentMood:
      typeof raw.currentMood === "string" && raw.currentMood.trim()
        ? raw.currentMood.trim().toLowerCase()
        : DEFAULTS.currentMood,
    moodFactors: cleanList(raw.moodFactors),
    motivationSources: cleanList(raw.motivationSources),
    preferredTopics: preferredTopics.length ? preferredTopics : [...DEFAULTS.preferredTopics],
    // "Write your own" answers: sanitized and length-limited before the model.
    customAnswers: cleanList(raw.customAnswers, { max: 5, maxLen: 40 }),
    language,
    count: clampInt(raw.count, 1, 20, DEFAULTS.count),
  };
}

const languageName = (code) => LANGUAGE_NAMES[code] || code || "English";

/** Builds the dynamic user prompt from a sanitized context (+ texts to avoid). */
export function buildUserPrompt(ctx, avoid = []) {
  const topics = ctx.preferredTopics.map(pretty).join(", ");
  const lines = [
    `Generate ${ctx.count} personalized affirmations.`,
    "",
    "User context:",
    ctx.ageRange ? `- Age range: ${ctx.ageRange}` : null,
    `- Current mood: ${pretty(ctx.currentMood)}`,
    ctx.moodFactors.length
      ? `- Factors shaping their mood: ${ctx.moodFactors.map(pretty).join(", ")}`
      : null,
    ctx.motivationSources.length
      ? `- Motivation sources: ${ctx.motivationSources.map(pretty).join(", ")}`
      : null,
    `- Preferred topics: ${topics}`,
    ctx.customAnswers.length ? `- In their own words: ${ctx.customAnswers.join("; ")}` : null,
    `- Language: ${languageName(ctx.language)}`,
    "",
    `Prioritize affirmations about ${topics}.`,
    "",
    `Do not mention the user's age or explicitly state that the user feels ${pretty(ctx.currentMood)}.`,
  ].filter((l) => l !== null);

  if (avoid.length) {
    lines.push(
      "",
      "Do not repeat or closely paraphrase any of these recent affirmations:",
      ...avoid.slice(0, 60).map((t) => `- ${t}`),
    );
  }
  lines.push(
    "",
    "Return only the required JSON — an object with this exact shape:",
    '{"affirmations":[{"text":"...","topic":"...","tone":"..."}]}',
    `The "affirmations" array must contain exactly ${ctx.count} items, each with`,
    'the string keys "text", "topic" and "tone" and no others.',
  );
  return lines.join("\n");
}

/** Lowercase, strip punctuation, collapse whitespace — for dedup comparison. */
export function normalizeText(text) {
  return String(text)
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, "")
    .replace(/\s+/g, " ")
    .trim();
}

/**
 * Validates and cleans the model output. Keeps only well-formed items
 * ({text, topic, tone}, non-empty text, 3..25 words), strips extra keys and
 * caps at `count`. Returns { affirmations, enough }.
 */
export function validateAffirmations(parsed, count) {
  const arr = parsed && Array.isArray(parsed.affirmations) ? parsed.affirmations : [];
  const cleaned = [];
  for (const item of arr) {
    if (!item || typeof item !== "object") continue;
    const text = typeof item.text === "string" ? item.text.trim() : "";
    if (!text) continue;
    const words = text.split(/\s+/).length;
    if (words < 3 || words > 25) continue;
    const topic = typeof item.topic === "string" && item.topic.trim() ? item.topic.trim() : "general";
    const tone = typeof item.tone === "string" && item.tone.trim() ? item.tone.trim() : "supportive";
    cleaned.push({ text, topic, tone }); // only the expected keys
    if (cleaned.length >= count) break;
  }
  return { affirmations: cleaned, enough: cleaned.length >= Math.ceil(count * 0.6) };
}

/** Drops affirmations whose normalized text collides with a recent one. */
export function dedupe(affirmations, recentNormalized) {
  const seen = new Set(recentNormalized);
  const kept = [];
  for (const a of affirmations) {
    const key = normalizeText(a.text);
    if (seen.has(key)) continue;
    seen.add(key);
    kept.push(a);
  }
  return kept;
}
