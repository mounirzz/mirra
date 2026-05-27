class OnbQuestion {
  const OnbQuestion({
    required this.id,
    required this.title,
    required this.options,
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;
  final List<String> options;
}

const List<OnbQuestion> kOnboardingQuestions = [
  OnbQuestion(
    id: 'gender',
    title: 'What\u2019s your gender?',
    subtitle: 'We use this to tune the tone of your affirmations.',
    options: ['Female', 'Male', 'Non-binary', 'Prefer not to say'],
  ),
  OnbQuestion(
    id: 'age',
    title: 'How old are you?',
    options: ['13 \u2013 17', '18 \u2013 24', '25 \u2013 34', '35 \u2013 44', '45 +'],
  ),
  OnbQuestion(
    id: 'mood',
    title: 'How do you feel right now?',
    options: ['Anxious', 'Flat', 'Okay', 'Good', 'Glowing'],
  ),
  OnbQuestion(
    id: 'feeling_source',
    title: 'What\u2019s shaping how you feel today?',
    options: ['Work', 'Relationships', 'Self-image', 'Health', 'Money', 'Other'],
  ),
  OnbQuestion(
    id: 'improve',
    title: 'What do you want to improve first?',
    options: ['Confidence', 'Focus', 'Calm', 'Discipline'],
  ),
  OnbQuestion(
    id: 'religion',
    title: 'Do faith-based affirmations resonate with you?',
    options: ['Yes', 'Sometimes', 'No'],
  ),
  OnbQuestion(
    id: 'motivation_source',
    title: 'Where do you find motivation?',
    options: ['Books', 'People', 'Music', 'Solitude', 'Movement'],
  ),
  OnbQuestion(
    id: 'vision',
    title: 'How clear is your vision for the next year?',
    options: ['Foggy', 'Forming', 'Clear', 'Crystal'],
  ),
  OnbQuestion(
    id: 'zodiac',
    title: 'What\u2019s your zodiac sign?',
    options: [
      'Aries', 'Taurus', 'Gemini', 'Cancer',
      'Leo', 'Virgo', 'Libra', 'Scorpio',
      'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
    ],
  ),
  OnbQuestion(
    id: 'time',
    title: 'When do you want your first reminder?',
    options: ['Morning', 'Midday', 'Evening', 'Night'],
  ),
  OnbQuestion(
    id: 'frequency',
    title: 'How often do you want reminders?',
    options: ['Once a day', '3 times', '11 times'],
  ),
  OnbQuestion(
    id: 'commitment',
    title: 'How long do you want to commit?',
    options: ['7 days', '30 days', '90 days', 'Lifetime'],
  ),
];
