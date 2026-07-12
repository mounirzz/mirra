class OnbQuestion {
  const OnbQuestion({
    required this.id,
    required this.title,
    required this.options,
    this.subtitle,
    this.maxSelections = 1,
    this.allowCustom = false,
  });

  final String id;
  final String title;
  final String? subtitle;
  final List<String> options;

  /// How many options can be picked at once (1 = single choice).
  final int maxSelections;

  /// Whether the user can write their own answer in addition to the
  /// predefined options.
  final bool allowCustom;

  bool get isMulti => maxSelections > 1;
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
    options: [
      '13 \u2013 17',
      '18 \u2013 24',
      '25 \u2013 34',
      '35 \u2013 44',
      '45 +',
    ],
  ),
  OnbQuestion(
    id: 'mood',
    title: 'How do you feel right now?',
    options: ['Anxious', 'Flat', 'Okay', 'Good', 'Glowing'],
  ),
  OnbQuestion(
    id: 'feeling_source',
    title: 'What\u2019s shaping how you feel today?',
    subtitle: 'Choose up to 3.',
    maxSelections: 3,
    allowCustom: true,
    options: ['Work', 'Relationships', 'Self-image', 'Health', 'Money'],
  ),
  OnbQuestion(
    id: 'improve',
    title: 'What do you want to improve?',
    subtitle: 'Choose up to 3.',
    maxSelections: 3,
    allowCustom: true,
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
    subtitle: 'Choose up to 3.',
    maxSelections: 3,
    allowCustom: true,
    options: ['Books', 'People', 'Music', 'Solitude', 'Movement'],
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
];
