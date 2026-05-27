// mirra-data.jsx — content, questions, themes
const PHOTOS = {
  // 17 unique themes used across the app
  cabin:    "https://images.unsplash.com/photo-1518998053901-5348d3961a04?w=1000&q=80&auto=format&fit=crop",
  cabin2:   "https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?w=1000&q=80&auto=format&fit=crop",
  forest:   "https://images.unsplash.com/photo-1448375240586-882707db888b?w=1000&q=80&auto=format&fit=crop",
  ocean:    "https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=1000&q=80&auto=format&fit=crop",
  mountain: "https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=1000&q=80&auto=format&fit=crop",
  meadow:   "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=1000&q=80&auto=format&fit=crop",
  desert:   "https://images.unsplash.com/photo-1473580044384-7ba9967e16a0?w=1000&q=80&auto=format&fit=crop",
  fog:      "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1000&q=80&auto=format&fit=crop",
  cosmos:   "https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?w=1000&q=80&auto=format&fit=crop",
  rain:     "https://images.unsplash.com/photo-1438449805896-28a666819a20?w=1000&q=80&auto=format&fit=crop",
  sunrise:  "https://images.unsplash.com/photo-1495567720989-cebdbdd97913?w=1000&q=80&auto=format&fit=crop",
  palm:     "https://images.unsplash.com/photo-1502209524164-acea936639a2?w=1000&q=80&auto=format&fit=crop",
  autumn:   "https://images.unsplash.com/photo-1507371341162-763b5e419408?w=1000&q=80&auto=format&fit=crop",
  candle:   "https://images.unsplash.com/photo-1602514239566-b35d3a1b94c2?w=1000&q=80&auto=format&fit=crop",
  road:     "https://images.unsplash.com/photo-1465056836041-7f43ac27dcb5?w=1000&q=80&auto=format&fit=crop",
  livingrm: "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=1000&q=80&auto=format&fit=crop",
  flowers:  "https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=1000&q=80&auto=format&fit=crop",
  lion:     "https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=1000&q=80&auto=format&fit=crop",
};

// All affirmations are personalized with "Julia" as the default name
const AFFIRMATIONS = [
  "One day, you will tell your story of how you overcame what you went through, and it will be someone else's survival guide.",
  "In case no one told you today, Julia, you are stronger than you think and you are doing great.",
  "A year from now, it won't even matter, Julia. Try not to stress the little things.",
  "There are people who will take every risk just to be with you, Julia. You deserve to be loved like that.",
  "Don't be afraid to start over, Julia. This time you're not starting from scratch — you're starting from experience.",
  "Nothing is a coincidence. Everything you're experiencing is meant to happen exactly how it's happening. Embrace the lessons. Be grateful.",
  "Keep faith. The most amazing things in life tend to happen right at the moment you're about to give up hope.",
  "No matter how tough it gets this week, keep going, Julia.",
  "Not everyone deserves to know the real you, Julia. Let them criticize who they think you are.",
  "Sometimes what you're most afraid of doing is the one thing that will set you free.",
  "Keep fighting through your worst days. It's how you earn your best days.",
  "You can do it, Julia. The hard part is already behind you.",
];

// The 16 onboarding questions in order. Format:
//   { id, title, subtitle, multi, skip, kind: 'pill'|'icon'|'curve'|'text'|'goals'|'topics'|'zodiac',
//     options: [{ label, glyph?, sub? }] }
const Q = (id, title, opts, more = {}) => ({ id, title, options: opts, ...more });

const ONBOARDING = [
  // Stage 1 — basics
  Q('gender', "Which option represents you best, Julia?",
    ['Female','Male','Other','Prefer not to say']),
  Q('age', "How old are you?",
    ['13 to 17','18 to 24','25 to 34','35 to 44','45 to 54','55+'], { skip: true }),
  Q('mood', "How have you been feeling lately, Julia?",
    [
      { label: 'Awesome',  glyph: 'curve-awesome' },
      { label: 'Good',     glyph: 'curve-good' },
      { label: 'Neutral',  glyph: 'curve-neutral' },
      { label: 'Bad',      glyph: 'curve-bad' },
      { label: 'Terrible', glyph: 'curve-terrible' },
      { label: 'Other',    glyph: 'curve-other' },
    ]),
  Q('feeling_source', "What's making you feel that way?",
    [
      { label: 'Love',    glyph: 'cloud' },
      { label: 'Work',    glyph: 'briefcase' },
      { label: 'Health',  glyph: 'pulse' },
      { label: 'Family',  glyph: 'home' },
      { label: 'Friends', glyph: 'hands' },
      { label: 'Other',   glyph: 'ellipsis' },
    ], { multi: true, skip: true }),
  { kind: 'splash', id: 's1', title: 'Customize the app to improve your experience', illustration: 'compass' },
  Q('improve', "What do you want to improve?",
    [
      { label: 'Faith & spirituality', glyph: 'sun' },
      { label: 'Stress & anxiety',     glyph: 'head' },
      { label: 'Positive thinking',    glyph: 'brain' },
      { label: 'Self-esteem',          glyph: 'shield' },
      { label: 'Relationships',        glyph: 'handshake' },
      { label: 'Achieving goals',      glyph: 'mountain' },
    ], { multi: true }),
  Q('struggles', "Do you struggle to stay consistent in any area?",
    ['Healthy habits','Personal relationships','Staying motivated','Mental health','School/work','Managing stress and anxiety'],
    { multi: true, skip: true }),
  Q('unmotivated', "What do you do when you're not motivated?",
    ['Procrastinate','Oversleep','Scroll mindlessly','Waste time','Fall into unhealthy habits','Other'],
    { multi: true, skip: true }),
  { kind: 'splash', id: 's2', title: 'Get motivation throughout the day', illustration: 'arch' },
  Q('source', "What's your biggest source of motivation every day?",
    ['Learning new things','Faith/spirituality','Friends','Self-improvement','Family','Work'],
    { multi: true, skip: true }),
  Q('push', "What gives you a push when you're unmotivated?",
    ['Support from others','Recalling past achievements','Faith or spirituality','Thinking about the future','Being inspired by someone','Hitting rock bottom'],
    { multi: true, skip: true }),
  Q('avoid', "Been avoiding anything you really should confront?",
    ['Healing from my past','Setting goals to shape my future','Transforming my relationships','Advancing my work and career','Improving my financial situation','Other'],
    { skip: true }),
  Q('mental', "How do you improve your mental health?",
    ['Spending time in nature','Journaling','Support from others','Therapy','Meditation','Exercise and nutrition'],
    { multi: true, skip: true }),
  Q('vision', "Do you have a clear vision of the life you want?",
    ['Yes, I do',"I'm working on it",'I take it one day at a time','Not really'],
    { skip: true }),
  Q('religious', "Are you religious?",
    ['Yes','No','Spiritual but not religious'], { skip: true }),
  { kind: 'splash', id: 's3', title: 'Customize the app to what you want to achieve', illustration: 'plant' },
  Q('zodiac', "What's your Zodiac sign?",
    [
      { label: 'Capricorn',   glyph: 'capricorn' },
      { label: 'Aquarius',    glyph: 'aquarius' },
      { label: 'Pisces',      glyph: 'pisces' },
      { label: 'Aries',       glyph: 'aries' },
      { label: 'Taurus',      glyph: 'taurus' },
      { label: 'Gemini',      glyph: 'gemini' },
      { label: 'Cancer',      glyph: 'cancer' },
      { label: 'Leo',         glyph: 'leo' },
      { label: 'Virgo',       glyph: 'virgo' },
      { label: 'Libra',       glyph: 'libra' },
      { label: 'Scorpio',     glyph: 'scorpio' },
      { label: 'Sagittarius', glyph: 'sagittarius' },
    ], { skip: true }),
  { kind: 'goals', id: 'goals', title: 'What are your goals right now?',
    placeholder: 'Tell us about your goals…', max: 250 },
  { kind: 'topics', id: 'topics', title: 'Which topics do you want to follow?',
    subtitle: 'Choose all that apply',
    options: ['Self-worth','Bible verses','Love','Fitness','Encouraging words','New beginnings','Affirmations','Fake people','Hard times','Working out','Productivity','Achieving goals','Inspiration','Letting go','Faith & Spirituality','Stress & Anxiety','Positive thinking','Relationships'] },
  Q('source_app', "How did you hear about Motivation?",
    ['Friend/family','Instagram','TikTok','App Store','Web search','Facebook','Other']),
];

const THEMES = [
  { id: 'cabin',    label: 'Cabin', photo: PHOTOS.cabin, animated: true },
  { id: 'fog',      label: 'Fog',   photo: PHOTOS.fog },
  { id: 'cosmos',   label: 'Cosmos',photo: PHOTOS.cosmos },
  { id: 'forest',   label: 'Forest',photo: PHOTOS.forest },
  { id: 'plain',    label: 'Plain', photo: null },
  { id: 'sunrise',  label: 'Sunrise', photo: PHOTOS.sunrise },
  { id: 'palm',     label: 'Palm',  photo: PHOTOS.palm },
  { id: 'autumn',   label: 'Autumn',photo: PHOTOS.autumn },
  { id: 'road',     label: 'Road',  photo: PHOTOS.road },
  { id: 'candle',   label: 'Candle',photo: PHOTOS.candle, animated: true },
  { id: 'ocean',    label: 'Ocean', photo: PHOTOS.ocean, animated: true },
  { id: 'mountain', label: 'Mountain', photo: PHOTOS.mountain },
  { id: 'meadow',   label: 'Meadow', photo: PHOTOS.meadow },
  { id: 'desert',   label: 'Desert', photo: PHOTOS.desert },
  { id: 'rain',     label: 'Rain',   photo: PHOTOS.rain },
  { id: 'livingrm', label: 'Living', photo: PHOTOS.livingrm },
  { id: 'flowers',  label: 'Flowers',photo: PHOTOS.flowers },
  { id: 'black',    label: 'Black',  photo: null, dark: true },
];

const THEME_MIXES = [
  { id: 'animated', label: 'ANIMATED',     photo: PHOTOS.ocean, italic: false, caps: true,  serif: true },
  { id: 'popular',  label: 'Most popular', photo: PHOTOS.sunrise, italic: true, caps: false, serif: true },
  { id: 'seasonal', label: 'Seasonal',     photo: PHOTOS.autumn, italic: false, caps: false, serif: true },
  { id: 'plain',    label: 'Plain',        photo: null, mono: true },
  { id: 'animals',  label: 'ANIMALS',      photo: PHOTOS.lion, italic: true, caps: true, serif: true },
  { id: 'easy',     label: 'EASY TO READ', photo: null, dark: true, bold: true, caps: true },
  { id: 'flowers',  label: 'Flowers and plants', photo: PHOTOS.flowers, italic: true, serif: true },
  { id: 'sports',   label: 'Sports',       photo: PHOTOS.road, italic: false, caps: false, serif: true },
  { id: 'cosmos',   label: 'COSMOS',       photo: PHOTOS.cosmos, caps: true, serif: true },
  { id: 'highvis',  label: 'HIGH VISIBILITY', photo: null, purple: true, bold: true, caps: true },
  { id: 'urban',    label: 'Urban',        photo: PHOTOS.rain, italic: true, caps: false, serif: true },
  { id: 'natural',  label: 'Natural phenomena', photo: PHOTOS.cosmos, serif: true },
  { id: 'tropical', label: 'TROPICAL',     photo: PHOTOS.palm, caps: true, mono: true },
  { id: 'illustration', label: 'Illustration', photo: PHOTOS.meadow, serif: true },
];

const TOPICS_POPULAR = [
  'Self-worth','Bible verses','Love','Fitness','Encouraging words','New beginnings','Affirmations','Fake people'
];
const TOPICS_GROWTH = ['Self-esteem','Achieving goals','Letting go','Mindfulness','Hard times','Stress & Anxiety','Positive thinking','Productivity'];
const TOPICS_RELATION = ['Love','Relationships','Friendship','Family'];
const ZODIAC = ['Capricorn','Aquarius','Pisces','Aries','Taurus','Gemini','Cancer','Leo','Virgo','Libra','Scorpio','Sagittarius'];
const AUTHORS = ['Lewis Howes','Mark Twain','Lao Tzu','Hellen Keller','Marcus Aurelius','Muhammad Ali','Maya Angelou','Buddha','Jim Rohn'];

const CONTENT_PREFS = ['Hard times','Working out','Productivity','Self-esteem','Achieving goals','Inspiration','Letting go','Love','Relationships','Faith & Spirituality','Positive thinking','Stress & Anxiety'];

const VOICES = [
  { name: 'Gordon',    locale: 'en-AU' },
  { name: 'Karen',     locale: 'en-AU' },
  { name: 'Catherine', locale: 'en-AU' },
  { name: 'Rocko',     locale: 'en-GB' },
  { name: 'Shelley',   locale: 'en-GB' },
  { name: 'Martha',    locale: 'en-GB' },
  { name: 'Daniel',    locale: 'en-GB', selected: true },
  { name: 'Grandma',   locale: 'en-GB' },
  { name: 'Grandpa',   locale: 'en-GB' },
  { name: 'Flo',       locale: 'en-GB' },
  { name: 'Eddy',      locale: 'en-GB' },
  { name: 'Reed',      locale: 'en-GB' },
  { name: 'Sandy',     locale: 'en-GB' },
  { name: 'Arthur',    locale: 'en-GB' },
];

const ICON_CHOICES = [
  // Row 1 - black squares with quote glyph
  { id: 'i1', bg: '#171B2A', glyph: '"', dark: true },
  { id: 'i2', bg: '#171B2A', glyph: '"', dark: true, big: true, selected: true },
  { id: 'i3', bg: '#171B2A', glyph: '"', dark: true, ring: true },
  { id: 'i4', bg: '#FFFFFF', glyph: '"', dark: false, ringDark: true },
  // Row 2 - light backgrounds with quote
  { id: 'i5', bg: 'linear-gradient(135deg,#D4C7F3,#EFD6E8)', glyph: '"', dark: false },
  { id: 'i6', bg: '#FAF7F2', glyph: '"', dark: false, biggerGlyph: true },
  { id: 'i7', bg: PHOTOS.cosmos, glyph: '"', dark: true, photo: true },
  { id: 'i8', bg: '#1F1F1F', glyph: '"', dark: true, marble: true },
  // Row 3
  { id: 'i9',  bg: 'linear-gradient(135deg,#B8C6E0,#DCC7E8)', glyph: '"', dark: true },
  { id: 'i10', bg: '#FFFFFF', glyph: '"', dark: false, biggerGlyph: true },
  { id: 'i11', bg: '#171B2A', glyph: '"', dark: true, ringWhite: true },
  { id: 'i12', bg: '#171B2A', glyph: '"', dark: true, smallQuote: true },
  // Row 4 - text icons
  { id: 'i13', bg: '#171B2A', text: 'Do\nnot\nquit', dark: true },
  { id: 'i14', bg: '#F4ECE2', text: 'Chase\nyour\ndreams', dark: false, bold: true },
  { id: 'i15', bg: 'linear-gradient(135deg,#C5C5BC,#7E7B71)', text: 'Be you.\nDo you.\nFor you.', dark: true },
  { id: 'i16', bg: '#171B2A', text: 'Trust\nthe\nprocess', dark: true },
  // Row 5
  { id: 'i17', bg: '#171B2A', wordmark: 'MOTIVATION', dark: true },
  { id: 'i18', bg: '#FAF7F2', wordmark: 'MOTIVATION', dark: false },
  { id: 'i19', bg: PHOTOS.cosmos, wordmark: 'MOTI\nVA\nTION', dark: true, photo: true },
  { id: 'i20', bg: 'linear-gradient(135deg,#FFD6A5,#FFB3D9,#B5D4F7)', glyph: '"', dark: false },
  // Row 6
  { id: 'i21', bg: PHOTOS.sunrise, glyph: '"', dark: true, photo: true },
  { id: 'i22', bg: '#F8C8DC', glyph: '"', dark: false },
  { id: 'i23', bg: 'linear-gradient(135deg,#D0D0D0,#A8A8A8)', glyph: '"', dark: false, marble: true },
  { id: 'i24', bg: '#1A1A1A', glyph: '"', dark: true, marble: true },
];

window.MIRRA = {
  PHOTOS, AFFIRMATIONS, ONBOARDING, THEMES, THEME_MIXES,
  TOPICS_POPULAR, TOPICS_GROWTH, TOPICS_RELATION, ZODIAC, AUTHORS,
  CONTENT_PREFS, VOICES, ICON_CHOICES,
  NAME: 'Julia',
};
