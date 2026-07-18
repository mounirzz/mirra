// Builds the (non-PII) preference context sent to the backend affirmations
// endpoint. Pure + framework-free so it can be unit-tested. Only the user's
// preferences are included — never name, email or any identifier.

import '../onboarding/providers/onboarding_provider.dart';

// Onboarding option labels → canonical snake_case tokens for the model.
const _moodFactorTokens = {
  'Work': 'work',
  'Relationships': 'relationships',
  'Self-image': 'self_image',
  'Health': 'health',
  'Money': 'money',
};

const _motivationTokens = {
  'Books': 'books',
  'People': 'people',
  'Music': 'music',
  'Solitude': 'solitude',
  'Movement': 'movement',
};

const _improveTopicTokens = {
  'Confidence': 'confidence',
  'Focus': 'focus',
  'Calm': 'calm',
  'Discipline': 'discipline',
};

String _normalizeAge(String v) =>
    v.replaceAll(RegExp(r'\s+'), '').replaceAll('–', '-');

/// Assembles the request context from the stored onboarding [answers] plus the
/// active [language] and requested [count]. [extraTopics] (e.g. Mix selection)
/// are merged into preferred topics. Missing preferences are simply omitted —
/// the backend applies safe defaults.
Map<String, dynamic> buildAffirmationContext({
  required Map<String, String> answers,
  required String language,
  int count = 10,
  List<String> extraTopics = const [],
}) {
  final custom = <String>[];

  List<String> tokensFor(String? multi, Map<String, String> known) {
    final out = <String>[];
    for (final value in OnboardingNotifier.splitMulti(multi)) {
      final token = known[value];
      if (token != null) {
        out.add(token);
      } else {
        custom.add(value); // a "Write your own" free-text answer
      }
    }
    return out;
  }

  final moodFactors = tokensFor(answers['feeling_source'], _moodFactorTokens);
  final motivationSources =
      tokensFor(answers['motivation_source'], _motivationTokens);
  final improveTopics = tokensFor(answers['improve'], _improveTopicTokens);

  final preferredTopics = <String>{...improveTopics, ...extraTopics}.toList();

  final customAnswers = custom
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .map((s) => s.length > 40 ? s.substring(0, 40) : s)
      .take(5)
      .toList();

  final age = answers['age'];
  final mood = answers['mood'];

  return {
    if (age != null && age.isNotEmpty) 'ageRange': _normalizeAge(age),
    if (mood != null && mood.isNotEmpty) 'currentMood': mood.toLowerCase(),
    'moodFactors': moodFactors,
    'motivationSources': motivationSources,
    'preferredTopics': preferredTopics,
    'customAnswers': customAnswers,
    'language': language,
    'count': count,
  };
}
