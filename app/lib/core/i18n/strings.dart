import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'language_provider.dart';

/// Lightweight source-keyed i18n: UI code keeps its English literal and wraps
/// it in [tr]; when the language is French we look the literal up in [_fr].
/// A missing key simply falls back to the English source, so partial
/// translation never breaks the UI.
const Map<String, String> _fr = {
  // Bottom nav / feed chrome
  'Mix': 'Catégories',
  'Theme': 'Thème',
  'Profile': 'Profil',
  'Swipe up': 'Glissez vers le haut',
  'day streak': 'jours d’affilée',

  // Streak hub
  'Your streak': 'Votre série',
  'Customize the app': 'Personnaliser l’app',
  'My favorites': 'Mes favoris',
  'My themes': 'Mes thèmes',
  'My own quotes': 'Mes citations',
  'My profile': 'Mon profil',
  'Topics you follow': 'Vos thèmes',
  'Reminders': 'Rappels',
  'Themes': 'Thèmes',
  'Settings': 'Réglages',

  // Preferences menu
  'Preferences': 'Préférences',
  'Premium': 'Premium',
  'Make it yours': 'À votre image',
  'Account': 'Compte',
  'Support us': 'Soutenez-nous',
  'Manage subscription': 'Gérer l’abonnement',
  'Content preferences': 'Préférences de contenu',
  'Gender identity': 'Identité de genre',
  'Muted content': 'Contenu masqué',
  'Language': 'Langue',
  'Name': 'Nom',
  'Sound': 'Son',
  'App theme': 'Thème de l’app',
  'Sign in': 'Se connecter',
  'My account': 'Mon compte',
  'Share Mirra': 'Partager Mirra',

  // Sub-screens
  'Your answers shape which affirmations you see.':
      'Vos réponses déterminent les affirmations que vous voyez.',
  'Your gender identity is used to personalize your content':
      'Votre identité de genre sert à personnaliser votre contenu',
  'Your name is used to personalize your content':
      'Votre nom sert à personnaliser votre contenu',
  'Your first name': 'Votre prénom',
  'Save': 'Enregistrer',
  'Set the volume you’d like': 'Réglez le volume souhaité',
  'THEME SOUND': 'SON DU THÈME',
  'Daily reminders': 'Rappels quotidiens',
  'Add muted content': 'Masquer un contenu',
  'Mute a topic': 'Masquer un thème',
  'Unmute': 'Réafficher',
  'You haven’t muted\nanything yet': 'Vous n’avez rien\nmasqué pour l’instant',
  'When you mute a topic, you won’t see it in your feed or notifications':
      'Un thème masqué n’apparaît plus dans votre fil ni vos notifications',
  'You are subscribed to:': 'Vous êtes abonné à :',
  'Started:': 'Débuté :',
  'Renewal:': 'Renouvellement :',
  'Cancel or change subscription': 'Annuler ou changer d’abonnement',

  // Upgrade pitch / paywall
  'Become your\nbest self with Mirra+':
      'Devenez la\nmeilleure version de vous avec Mirra+',
  'Join thousands reshaping their mindset, one affirmation at a time.':
      'Rejoignez des milliers de personnes qui transforment leur état '
          'd’esprit, une affirmation à la fois.',
  'happy users': 'utilisateurs conquis',
  'affirmations': 'affirmations',
  'Unlimited affirmations': 'Affirmations illimitées',
  'No daily limit — read as much as you need.':
      'Aucune limite quotidienne — lisez autant que vous le souhaitez.',
  'Every theme & background': 'Tous les thèmes et fonds',
  'Make Mirra truly yours, including your own photos.':
      'Faites de Mirra la vôtre, avec vos propres photos.',
  'Unlimited favorites': 'Favoris illimités',
  'Keep every quote that speaks to you.':
      'Gardez chaque citation qui vous parle.',
  'Unlimited personal affirmations': 'Affirmations perso illimitées',
  'Write the words only you can write.':
      'Écrivez les mots que vous seul pouvez écrire.',
  'Start 3-day free trial': 'Commencer l’essai gratuit de 3 jours',
  'Get Mirra+': 'Obtenir Mirra+',
  'Restore purchases': 'Restaurer les achats',
  'Continue': 'Continuer',
  'BEST VALUE': 'MEILLEURE OFFRE',
  'Weekly': 'Hebdomadaire',
  'Monthly': 'Mensuel',
  'Annual': 'Annuel',

  // Quote categories (feed eyebrow + Mix chips)
  'Motivation': 'Motivation',
  'Self-confidence': 'Confiance en soi',
  'Productivity': 'Productivité',
  'Workout': 'Sport',
  'Love': 'Amour',
  'Breakup healing': 'Après une rupture',
  'Stress relief': 'Anti-stress',
  'Mindfulness': 'Pleine conscience',
  'Success': 'Réussite',
  'Business & money': 'Business & argent',
  'Family': 'Famille',
  'Life lessons': 'Leçons de vie',
  'Gratitude': 'Gratitude',
  'Women empowerment': 'Force féminine',
  'Philosophy': 'Philosophie',
  'Sports': 'Sport',
  'Happiness': 'Bonheur',
  'Faith & spirituality': 'Foi & spiritualité',
  'My affirmations': 'Mes affirmations',
  // Mix screen
  'All': 'Tout',
  'Pick one or more categories to shape your feed.':
      'Choisissez une ou plusieurs catégories pour composer votre fil.',
  // Onboarding
  'Start Mirra': 'Démarrer Mirra',
  'Choose up to 3.': 'Choisissez-en jusqu’à 3.',
  'Write your own…': 'Écrire la vôtre…',
  'Welcome to Mirra': 'Bienvenue sur Mirra',
  'Reflect daily. Reshape gently.':
      'Réfléchissez chaque jour. Transformez-vous en douceur.',
  'Stay motivated with a\nconsistent daily routine':
      'Restez motivé grâce à une\nroutine quotidienne régulière',
  'Build a streak, one day at a time':
      'Construisez votre série, un jour à la fois',
  'Add your affirmation': 'Ajouter votre affirmation',
  'Write your own affirmations —\nwhat you tell yourself matters most.':
      'Écrivez vos propres affirmations —\nce que vous vous dites compte le '
          'plus.',
  'New affirmation': 'Nouvelle affirmation',
  'Edit affirmation': 'Modifier l’affirmation',

  // Boost lines (under each affirmation)
  'Go get it. Today counts.': 'Foncez. Aujourd’hui compte.',
  'One step closer to the top.': 'Un pas de plus vers le sommet.',
  'Built different. Prove it today.':
      'Vous êtes taillé autrement. Prouvez-le aujourd’hui.',
  'Big moves start small — start now.':
      'Les grands changements commencent petit — commencez maintenant.',
  'Stay sharp. Opportunities are watching.':
      'Restez affûté. Les opportunités vous observent.',
  'Discipline today, freedom tomorrow.':
      'Discipline aujourd’hui, liberté demain.',
  'Your future self is taking notes.':
      'Votre futur vous prend des notes.',
  'Momentum loves action. Move.': 'L’élan aime l’action. Bougez.',
  'You’ve got this today ✨': 'Vous allez y arriver aujourd’hui ✨',
  'Your energy is contagious.': 'Votre énergie est contagieuse.',
  'Today is yours. Own it gently.':
      'Cette journée est à vous. Prenez-la en douceur.',
  'Keep glowing — it suits you.': 'Continuez de rayonner — ça vous va bien.',
  'Breathe in. You’re doing better than you think.':
      'Respirez. Vous vous en sortez mieux que vous ne le pensez.',
  'Small steps still move you forward.':
      'Les petits pas font aussi avancer.',
  'Be proud of how far you’ve come.':
      'Soyez fier du chemin parcouru.',
  'The world is lucky to have you today.':
      'Le monde a de la chance de vous avoir aujourd’hui.',

  // Favorites / end card
  'Favorites': 'Favoris',
  'No favorites yet': 'Aucun favori pour l’instant',
  'You’ve seen it all for now': 'Vous avez tout vu pour aujourd’hui',
  'Come back tomorrow — or go unlimited with Mirra+.':
      'Revenez demain — ou passez en illimité avec Mirra+.',

  // App icon picker (onboarding)
  'Which icon style\ndo you like the most?':
      'Quel style d’icône\npréférez-vous ?',

  // Profile
  'Your journey': 'Votre parcours',
  'Day streak': 'Jours de série',
  'Your answers': 'Vos réponses',
  'Mirra+ member': 'Membre Mirra+',
  'Get Mirra+ — go unlimited': 'Passez à Mirra+ — en illimité',
  'Signed in': 'Connecté',
  'Sign out': 'Se déconnecter',
  'Your account': 'Votre compte',
  'Save your themes': 'Enregistrez vos thèmes',
  'Sign in to keep your custom themes tied to your account — '
          'on every device, even after reinstalling.':
      'Connectez-vous pour garder vos thèmes personnalisés liés à votre '
          'compte — sur tous vos appareils, même après réinstallation.',
  'Continue with Apple': 'Continuer avec Apple',
  'Continue with Google': 'Continuer avec Google',
  'One moment…': 'Un instant…',

  // Paywall
  'Become the best\nversion of you': 'Deviens la meilleure\nversion de toi',
  'Loved by 100,000+ people rewiring their mindset':
      'Adoré par plus de 100 000 personnes qui transforment leur état d’esprit',
  'Unlimited daily affirmations': 'Affirmations illimitées chaque jour',
  'All categories — and your own': 'Toutes les catégories — et les tiennes',
  'Widgets, sounds & voices': 'Widgets, sons et voix',
  'No ads, ever': 'Zéro publicité, jamais',
  'Start my 3-day free trial': 'Démarrer mon essai gratuit de 3 jours',
  '3-day free trial included': 'Essai gratuit de 3 jours inclus',
  'Remind me before my trial ends':
      'Me rappeler avant la fin de l’essai',
  '3 days free, then ': '3 jours gratuits, puis ',
  '/year. Cancel anytime — no commitment.':
      '/an. Annulable à tout moment — sans engagement.',
  'Cancel anytime — no commitment.':
      'Annulable à tout moment — sans engagement.',
  'Restore': 'Restaurer',
  'Terms': 'Conditions',
  'Privacy': 'Confidentialité',
  'per week': 'par semaine',
  'per month': 'par mois',
  'per year — 3,30 €/mo': 'par an — 3,30 €/mois',

  // Paywall — free-trial timeline
  'How your free\ntrial works': 'Comment fonctionne\nvotre essai gratuit',
  "You won't be charged anything today":
      'Vous ne serez pas débité aujourd’hui',
  'Today': 'Aujourd’hui',
  'Get full access and see your mindset start to change.':
      'Accès complet — votre état d’esprit commence déjà à changer.',
  'Day 2': 'Jour 2',
  'Get a reminder that your trial ends in 24 hours.':
      'Un rappel : votre essai se termine dans 24 h.',
  'After day 3': 'Après le jour 3',
  'Your free trial ends. Cancel anytime before — no charge.':
      'Votre essai gratuit se termine. Annulez avant — sans frais.',
  'Reminder before trial ends': 'Rappel avant la fin de l’essai',
  'How does the\nfree trial work?': 'Comment fonctionne\nl’essai gratuit ?',
  'Install the app': 'Installez l’appli',
  'Set it up for your goals': 'Paramétrez-la pour vos objectifs',
  'Trial starts': 'Début de l’essai',
  'Completely free for your first 3 days':
      'Entièrement gratuit pendant vos 3 premiers jours',
  'When your trial is about to end': 'Lorsque votre essai prendra fin',
  'Become a member': 'Devenir membre',
  'Your trial ends unless you cancel':
      'Votre essai prendra fin sauf si vous l’annulez',
  'Try for €0.00': 'Essayez pour 0,00 €',
  'Day 3': 'Jour 3',
  'Full access': 'Accès complet',
  'Reminder': 'Rappel',
  'Trial ends': 'Fin de l’essai',
  'Unlimited free access for 3 days, then ':
      'Accès illimité gratuit pendant 3 jours, puis ',
  '/month': '/mois',
  'Terms & Conditions': 'Conditions générales',
  'Privacy Policy': 'Politique de confidentialité',

  // Free-plan limits
  'Free plan: up to 2 categories.':
      'Plan gratuit : 2 catégories maximum.',
  'Unlock all categories': 'Débloque toutes les catégories',
  'The free plan lets you pick 2 categories.\nGo unlimited with Mirra+.':
      'Le plan gratuit permet 2 catégories.\nPasse en illimité avec Mirra+.',
  'Your favorites are full': 'Tes favoris sont pleins',
  'The free plan keeps your 2 favorites.\nGo unlimited with Mirra+.':
      'Le plan gratuit garde 2 favoris.\nPasse en illimité avec Mirra+.',
  'Use the free app': 'Utiliser l’app gratuite',
  '/month, auto-renews. Cancel anytime.':
      '/mois, renouvellement automatique. Annulable à tout moment.',
  '/year, auto-renews. Cancel anytime.':
      '/an, renouvellement automatique. Annulable à tout moment.',
  'Auto-renews. Cancel anytime.':
      'Renouvellement automatique. Annulable à tout moment.',
};

/// Translate an English source string for the given language code.
String tr(String source, String lang) =>
    lang == 'fr' ? (_fr[source] ?? source) : source;

/// Riverpod-aware translator: `context.tr(...)` style via a ref.
extension TrRef on WidgetRef {
  String tr(String source) =>
      source.trim().isEmpty ? source : _tr(this, source);
}

String _tr(WidgetRef ref, String source) =>
    tr(source, ref.watch(languageProvider).code);
