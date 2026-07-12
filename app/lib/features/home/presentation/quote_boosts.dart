import '../../../shared/models/quote.dart';

/// Short pep lines shown under each affirmation on the feed (instead of the
/// author). Business-flavored categories get hustle energy; everything else
/// gets a day-brightening compliment. Deterministic per quote so the line
/// doesn't change while swiping back and forth.
const _businessCategories = {
  'business',
  'success',
  'productivity',
  'motivation',
  'workout',
};

const _businessBoosts = [
  'Go get it. Today counts.',
  'One step closer to the top.',
  'Built different. Prove it today.',
  'Big moves start small — start now.',
  'Stay sharp. Opportunities are watching.',
  'Discipline today, freedom tomorrow.',
  'Your future self is taking notes.',
  'Momentum loves action. Move.',
];

const _dailyBoosts = [
  'You’ve got this today ✨',
  'Your energy is contagious.',
  'Today is yours. Own it gently.',
  'Keep glowing — it suits you.',
  'Breathe in. You’re doing better than you think.',
  'Small steps still move you forward.',
  'Be proud of how far you’ve come.',
  'The world is lucky to have you today.',
];

String boostFor(Quote quote) {
  final list = _businessCategories.contains(quote.categoryId)
      ? _businessBoosts
      : _dailyBoosts;
  return list[quote.id.hashCode.abs() % list.length];
}
