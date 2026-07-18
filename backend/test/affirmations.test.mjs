import { test } from "node:test";
import assert from "node:assert/strict";

import {
  applyDefaults,
  buildUserPrompt,
  validateAffirmations,
  dedupe,
  normalizeText,
  prefsSignature,
  DEFAULTS,
} from "../src/_affirmations.mjs";

test("applyDefaults fills missing preferences", () => {
  const ctx = applyDefaults({});
  assert.equal(ctx.currentMood, DEFAULTS.currentMood);
  assert.deepEqual(ctx.preferredTopics, DEFAULTS.preferredTopics);
  assert.equal(ctx.language, "en");
  assert.equal(ctx.count, 10);
});

test("applyDefaults clamps count and lowercases mood/language", () => {
  assert.equal(applyDefaults({ count: 999 }).count, 20);
  assert.equal(applyDefaults({ count: 0 }).count, 1);
  assert.equal(applyDefaults({ count: "7" }).count, 7);
  assert.equal(applyDefaults({ currentMood: "Flat" }).currentMood, "flat");
  assert.equal(applyDefaults({ language: "EN" }).language, "en");
});

test("applyDefaults sanitizes and caps custom answers", () => {
  const long = "x".repeat(80);
  const ctx = applyDefaults({
    customAnswers: ["  keep  ", "", long, "a", "b", "c", "d", "e"],
  });
  assert.equal(ctx.customAnswers.length, 5); // capped at 5
  assert.equal(ctx.customAnswers[0], "keep"); // trimmed
  assert.ok(ctx.customAnswers.every((a) => a.length <= 40)); // length-limited
});

test("buildUserPrompt reflects context and hides age/mood leakage rules", () => {
  const ctx = applyDefaults({
    ageRange: "25-34",
    currentMood: "flat",
    moodFactors: ["relationships", "self_image"],
    preferredTopics: ["love", "confidence"],
    count: 10,
  });
  const prompt = buildUserPrompt(ctx, []);
  assert.match(prompt, /Generate 10 personalized affirmations/);
  assert.match(prompt, /Preferred topics: Love, Confidence/);
  assert.match(prompt, /Factors shaping their mood: Relationships, Self Image/);
  assert.match(prompt, /Do not mention the user's age/);
  assert.match(prompt, /Return only the required JSON/);
});

test("buildUserPrompt omits age line when unknown and includes avoid list", () => {
  const ctx = applyDefaults({ preferredTopics: ["confidence"] });
  const prompt = buildUserPrompt(ctx, ["I am calm and steady."]);
  assert.doesNotMatch(prompt, /Age range/);
  assert.match(prompt, /Do not repeat or closely paraphrase/);
  assert.match(prompt, /- I am calm and steady\./);
});

test("validateAffirmations keeps only well-formed items and strips extra keys", () => {
  const { affirmations, enough } = validateAffirmations(
    {
      affirmations: [
        { text: "My worth remains steady, even on difficult days.", topic: "self_worth", tone: "gentle", extra: "x" },
        { text: "", topic: "x", tone: "y" }, // empty
        { text: "too short", topic: "x", tone: "y" }, // 2 words
        { text: 123, topic: "x", tone: "y" }, // non-string
        { text: "I welcome relationships built on honesty and mutual respect today.", topic: "relationships", tone: "calm" },
      ],
    },
    10,
  );
  assert.equal(affirmations.length, 2);
  assert.deepEqual(Object.keys(affirmations[0]), ["text", "topic", "tone"]); // no `extra`
  assert.equal(enough, false); // 2 < ceil(10*0.6)
});

test("validateAffirmations caps at requested count", () => {
  const items = Array.from({ length: 12 }, (_, i) => ({
    text: `This is affirmation number ${i} for the caller today.`,
    topic: "motivation",
    tone: "encouraging",
  }));
  const { affirmations } = validateAffirmations({ affirmations: items }, 5);
  assert.equal(affirmations.length, 5);
});

test("normalizeText lowercases and strips punctuation", () => {
  assert.equal(normalizeText("  My Worth, Remains!  "), "my worth remains");
});

test("prefsSignature is order-independent but changes with preferences", () => {
  const a = applyDefaults({
    currentMood: "flat",
    moodFactors: ["relationships", "self_image"],
    preferredTopics: ["love", "confidence"],
    language: "en",
  });
  const b = applyDefaults({
    currentMood: "flat",
    moodFactors: ["self_image", "relationships"], // reordered
    preferredTopics: ["confidence", "love"], // reordered
    language: "en",
  });
  const c = applyDefaults({
    currentMood: "good", // changed
    moodFactors: ["relationships", "self_image"],
    preferredTopics: ["love", "confidence"],
    language: "en",
  });
  assert.equal(prefsSignature(a), prefsSignature(b)); // same prefs, any order
  assert.notEqual(prefsSignature(a), prefsSignature(c)); // mood changed
});

test("dedupe removes items matching recent normalized texts", () => {
  const recent = [normalizeText("My worth remains steady.")];
  const kept = dedupe(
    [
      { text: "My worth remains steady!", topic: "a", tone: "b" }, // dup (punct/case)
      { text: "A brand new gentle thought.", topic: "a", tone: "b" },
    ],
    recent,
  );
  assert.equal(kept.length, 1);
  assert.equal(kept[0].text, "A brand new gentle thought.");
});
