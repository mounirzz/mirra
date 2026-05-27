import '../shared/models/quote.dart';

const List<Quote> kSeedQuotes = [
  // Motivation
  Quote(id: 'm1', text: 'Start where you are. Use what you have. Do what you can.', author: 'Arthur Ashe', categoryId: 'motivation'),
  Quote(id: 'm2', text: 'The future depends on what you do today.', author: 'Mahatma Gandhi', categoryId: 'motivation'),
  Quote(id: 'm3', text: 'Don\u2019t wait for opportunity. Create it.', author: 'Mirra', categoryId: 'motivation'),
  Quote(id: 'm4', text: 'You are one decision away from a completely different life.', author: 'Mel Robbins', categoryId: 'motivation'),

  // Self-confidence
  Quote(id: 'c1', text: 'Believe you can and you\u2019re halfway there.', author: 'Theodore Roosevelt', categoryId: 'confidence'),
  Quote(id: 'c2', text: 'You are enough, just as you are.', author: 'Meghan Markle', categoryId: 'confidence'),
  Quote(id: 'c3', text: 'Doubt kills more dreams than failure ever will.', author: 'Suzy Kassem', categoryId: 'confidence'),

  // Productivity
  Quote(id: 'p1', text: 'Focus on being productive instead of busy.', author: 'Tim Ferriss', categoryId: 'productivity'),
  Quote(id: 'p2', text: 'Discipline is choosing between what you want now and what you want most.', author: 'Abraham Lincoln', categoryId: 'productivity'),

  // Workout
  Quote(id: 'w1', text: 'Your body can stand almost anything. It\u2019s your mind you have to convince.', author: 'Mirra', categoryId: 'workout'),
  Quote(id: 'w2', text: 'Sweat is just fat crying.', author: 'Anonymous', categoryId: 'workout'),

  // Love
  Quote(id: 'l1', text: 'To love and be loved is to feel the sun from both sides.', author: 'David Viscott', categoryId: 'love'),
  Quote(id: 'l2', text: 'Love is composed of a single soul inhabiting two bodies.', author: 'Aristotle', categoryId: 'love'),

  // Breakup healing
  Quote(id: 'h1', text: 'Healing doesn\u2019t mean the damage never existed. It means it no longer controls your life.', author: 'Akshay Dubey', categoryId: 'healing'),
  Quote(id: 'h2', text: 'You will rise again, and this time, on your own terms.', author: 'Mirra', categoryId: 'healing'),

  // Stress relief
  Quote(id: 's1', text: 'Almost everything will work again if you unplug it for a few minutes, including you.', author: 'Anne Lamott', categoryId: 'stress'),
  Quote(id: 's2', text: 'Breathe in calm. Breathe out worry.', author: 'Mirra', categoryId: 'stress'),

  // Mindfulness
  Quote(id: 'mi1', text: 'Be where you are; otherwise you will miss your life.', author: 'Buddha', categoryId: 'mindfulness'),
  Quote(id: 'mi2', text: 'The present moment is the only moment available to us.', author: 'Thich Nhat Hanh', categoryId: 'mindfulness'),

  // Success
  Quote(id: 'su1', text: 'Success is not final, failure is not fatal: it is the courage to continue that counts.', author: 'Winston Churchill', categoryId: 'success'),
  Quote(id: 'su2', text: 'The only place where success comes before work is in the dictionary.', author: 'Vidal Sassoon', categoryId: 'success'),

  // Business & money
  Quote(id: 'b1', text: 'Risk comes from not knowing what you\u2019re doing.', author: 'Warren Buffett', categoryId: 'business'),
  Quote(id: 'b2', text: 'Don\u2019t work for money; make money work for you.', author: 'Robert Kiyosaki', categoryId: 'business'),

  // Family
  Quote(id: 'f1', text: 'Family is not an important thing. It\u2019s everything.', author: 'Michael J. Fox', categoryId: 'family'),

  // Life lessons
  Quote(id: 'li1', text: 'Life is 10% what happens to you and 90% how you react to it.', author: 'Charles R. Swindoll', categoryId: 'life'),
  Quote(id: 'li2', text: 'Don\u2019t count the days. Make the days count.', author: 'Muhammad Ali', categoryId: 'life'),

  // Gratitude
  Quote(id: 'g1', text: 'Gratitude turns what we have into enough.', author: 'Aesop', categoryId: 'gratitude'),

  // Women empowerment
  Quote(id: 'we1', text: 'A woman with a voice is, by definition, a strong woman.', author: 'Melinda Gates', categoryId: 'women'),
  Quote(id: 'we2', text: 'She remembered who she was, and the game changed.', author: 'Lalah Delia', categoryId: 'women'),

  // Philosophy
  Quote(id: 'ph1', text: 'The unexamined life is not worth living.', author: 'Socrates', categoryId: 'philosophy'),

  // Sports
  Quote(id: 'sp1', text: 'You miss 100% of the shots you don\u2019t take.', author: 'Wayne Gretzky', categoryId: 'sports'),

  // Happiness
  Quote(id: 'ha1', text: 'Happiness is not something ready made. It comes from your own actions.', author: 'Dalai Lama', categoryId: 'happiness'),
  Quote(id: 'ha2', text: 'For every minute you are angry you lose sixty seconds of happiness.', author: 'Ralph Waldo Emerson', categoryId: 'happiness'),

  // Faith
  Quote(id: 'fa1', text: 'Faith is taking the first step even when you don\u2019t see the whole staircase.', author: 'Martin Luther King Jr.', categoryId: 'faith'),

  // Extra mix
  Quote(id: 'x1', text: 'Become what you believe \u2014 reinforce it daily.', author: 'Mirra', categoryId: 'motivation'),
  Quote(id: 'x2', text: 'Soft heart, strong spine.', author: 'Mirra', categoryId: 'confidence'),
  Quote(id: 'x3', text: 'You are allowed to outgrow people, places and patterns.', author: 'Mirra', categoryId: 'life'),
  Quote(id: 'x4', text: 'Whatever calms your nervous system is where you belong.', author: 'Mirra', categoryId: 'mindfulness'),
  Quote(id: 'x5', text: 'Stop shrinking to fit places you\u2019ve outgrown.', author: 'Mirra', categoryId: 'women'),
  Quote(id: 'x6', text: 'Slow progress is still progress.', author: 'Mirra', categoryId: 'motivation'),
  Quote(id: 'x7', text: 'Trust the gentle pace of your becoming.', author: 'Mirra', categoryId: 'mindfulness'),
];
