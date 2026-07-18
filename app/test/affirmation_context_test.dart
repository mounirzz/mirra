import 'package:flutter_test/flutter_test.dart';
import 'package:mirra/features/affirmations/affirmation_context.dart';

void main() {
  group('buildAffirmationContext', () {
    test('maps known options to tokens and routes custom answers', () {
      final ctx = buildAffirmationContext(
        answers: {
          'age': '25 – 34',
          'mood': 'Flat',
          'feeling_source': 'Relationships, Self-image, Studying abroad',
          'motivation_source': 'Books, People',
          'improve': 'Confidence, Discipline',
        },
        language: 'en',
      );

      expect(ctx['ageRange'], '25-34'); // en-dash + spaces normalized
      expect(ctx['currentMood'], 'flat'); // lowercased
      expect(ctx['moodFactors'], ['relationships', 'self_image']);
      expect(ctx['motivationSources'], ['books', 'people']);
      expect(ctx['preferredTopics'], ['confidence', 'discipline']);
      // The unmatched "Studying abroad" is treated as a free-text answer.
      expect(ctx['customAnswers'], ['Studying abroad']);
      expect(ctx['language'], 'en');
      expect(ctx['count'], 10);
    });

    test('merges extra topics and de-duplicates', () {
      final ctx = buildAffirmationContext(
        answers: {'improve': 'Confidence'},
        language: 'fr',
        count: 8,
        extraTopics: ['confidence', 'love'],
      );
      expect(ctx['preferredTopics'], ['confidence', 'love']);
      expect(ctx['count'], 8);
      expect(ctx['language'], 'fr');
    });

    test('omits absent preferences and defaults empty lists', () {
      final ctx = buildAffirmationContext(answers: {}, language: 'en');
      expect(ctx.containsKey('ageRange'), isFalse);
      expect(ctx.containsKey('currentMood'), isFalse);
      expect(ctx['moodFactors'], isEmpty);
      expect(ctx['preferredTopics'], isEmpty);
      expect(ctx['customAnswers'], isEmpty);
    });

    test('trims, length-limits and caps custom answers', () {
      final long = 'x' * 60;
      final ctx = buildAffirmationContext(
        answers: {
          'feeling_source': '  a  , $long, b, c, d, e, f',
        },
        language: 'en',
      );
      final customs = ctx['customAnswers'] as List;
      expect(customs.length, 5); // capped at 5
      expect(customs.first, 'a'); // trimmed
      expect((customs[1] as String).length, 40); // length-limited
    });
  });
}
