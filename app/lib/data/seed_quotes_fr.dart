/// French translations of the seed catalog, keyed by quote id. Displayed
/// instead of [Quote.text] when the app language is French. Author names are
/// kept as-is. Missing ids fall back to the English text.
const Map<String, String> kSeedQuotesFr = {
  // Motivation
  'm1': 'Commencez là où vous êtes. Avec ce que vous avez. Faites ce que vous pouvez.',
  'm2': 'L’avenir dépend de ce que vous faites aujourd’hui.',
  'm3': 'N’attendez pas l’occasion. Créez-la.',
  'm4': 'Une seule décision vous sépare d’une vie complètement différente.',

  // Self-confidence
  'c1': 'Croyez que vous pouvez, et vous êtes déjà à mi-chemin.',
  'c2': 'Vous êtes assez, tel que vous êtes.',
  'c3': 'Le doute tue plus de rêves que l’échec n’en tuera jamais.',

  // Productivity
  'p1': 'Cherchez à être productif plutôt qu’occupé.',
  'p2': 'La discipline, c’est choisir entre ce que vous voulez maintenant et ce que vous voulez le plus.',

  // Workout
  'w1': 'Votre corps peut presque tout endurer. C’est votre esprit qu’il faut convaincre.',
  'w2': 'La sueur, c’est juste la graisse qui pleure.',

  // Love
  'l1': 'Aimer et être aimé, c’est sentir le soleil des deux côtés.',
  'l2': 'L’amour, c’est une seule âme habitant deux corps.',

  // Breakup healing
  'h1': 'Guérir ne veut pas dire que la blessure n’a jamais existé. Cela veut dire qu’elle ne contrôle plus votre vie.',
  'h2': 'Vous vous relèverez, et cette fois, selon vos propres règles.',

  // Stress relief
  's1': 'Presque tout refonctionne si on le débranche quelques minutes, vous compris.',
  's2': 'Inspirez le calme. Expirez l’inquiétude.',

  // Mindfulness
  'mi1': 'Soyez là où vous êtes, sinon vous manquerez votre vie.',
  'mi2': 'Le moment présent est le seul moment qui nous soit offert.',

  // Success
  'su1': 'Le succès n’est pas final, l’échec n’est pas fatal : c’est le courage de continuer qui compte.',
  'su2': 'Le seul endroit où le succès précède le travail, c’est dans le dictionnaire.',

  // Business & money
  'b1': 'Le risque vient de ne pas savoir ce que l’on fait.',
  'b2': 'Ne travaillez pas pour l’argent ; faites travailler l’argent pour vous.',

  // Family
  'f1': 'La famille n’est pas une chose importante. C’est tout.',

  // Life lessons
  'li1': 'La vie, c’est 10 % ce qui vous arrive et 90 % votre façon d’y réagir.',
  'li2': 'Ne comptez pas les jours. Faites que les jours comptent.',

  // Gratitude
  'g1': 'La gratitude transforme ce que nous avons en suffisance.',

  // Women empowerment
  'we1': 'Une femme qui a une voix est, par définition, une femme forte.',
  'we2': 'Elle s’est souvenue de qui elle était, et tout a changé.',

  // Philosophy
  'ph1': 'Une vie sans examen ne vaut pas la peine d’être vécue.',

  // Sports
  'sp1': 'On rate 100 % des tirs qu’on ne tente pas.',

  // Happiness
  'ha1': 'Le bonheur n’est pas tout fait. Il vient de vos propres actions.',
  'ha2': 'Pour chaque minute de colère, vous perdez soixante secondes de bonheur.',

  // Faith
  'fa1': 'La foi, c’est faire le premier pas même sans voir tout l’escalier.',

  // Extra mix
  'x1': 'Devenez ce que vous croyez — renforcez-le chaque jour.',
  'x2': 'Cœur tendre, colonne solide.',
  'x3': 'Vous avez le droit de dépasser des gens, des lieux et des habitudes.',
  'x4': 'Là où votre système nerveux s’apaise, c’est là qu’est votre place.',
  'x5': 'Cessez de vous rapetisser pour entrer dans des places trop petites pour vous.',
  'x6': 'Un progrès lent reste un progrès.',
  'x7': 'Faites confiance au rythme doux de votre évolution.',
};

/// Returns the French text for a seed quote when [lang] is 'fr' and a
/// translation exists; otherwise the original [enText] (covers English mode
/// and user-written affirmations, which are never in the map).
String localizedQuoteText(String id, String enText, String lang) =>
    lang == 'fr' ? (kSeedQuotesFr[id] ?? enText) : enText;
