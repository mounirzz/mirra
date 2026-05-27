# Mirra

App mobile d'affirmations positives quotidiennes (iOS + Android, Flutter).

## Structure du repo

```
.
├── app/                    Application Flutter (cible de production)
├── Mirra.html              Prototype HTML/React de référence (design)
├── *.jsx                   Modules du prototype
└── .claude/                Config Claude Code (preview server)
```

## État actuel — Phase 1 livrée

L'app Flutter (`app/`) tourne et build OK sur simulateur iOS. Architecture clean
posée, design system mappé sur le prototype, flux principal jouable.

**Ce qui marche :**
- Welcome (gradient navy/lavande)
- Onboarding 12 questions (chips, progress bar, persistence Hive)
- Home feed (PageView vertical de quote cards serif)
- Favorites (heart, persistence Hive, empty state)
- 37 quotes seed sur 18 catégories
- GoRouter + Riverpod + Hive + google_fonts

**Stack :**
- Flutter 3.41 / Dart 3.11
- `flutter_riverpod` (state)
- `go_router` (routing)
- `hive` + `hive_flutter` (storage local)
- `google_fonts` (Instrument Serif + Inter en remplacement de Geist)

## Lancer en local

```bash
cd app
flutter pub get
flutter run
```

(Premier sim/device dispo. Pour cibler : `flutter devices` puis `flutter run -d <id>`.)

## Prototype HTML

Le prototype React/HTML (réf design originale, 67 écrans) est à la racine.

```bash
python3 -m http.server 5173
# puis http://localhost:5173/Mirra.html
```

## Roadmap

### Phase 2 — Écrans restants
- Library : collections, history, own quotes (création + édition)
- Themes / Customize quote (background, font, size, color)
- Profile + streak + mood check
- Settings (subscription, language, theme mode)
- Search (quotes / authors / categories)

### Phase 3 — Intégrations natives
- `flutter_local_notifications` — reminders (morning/midday/evening)
- `home_widget` — widgets iOS (WidgetKit) + Android (Glance)
- `share_plus` — partage Instagram/WhatsApp/etc.
- `screenshot` — export quote card en image

### Phase 4 — Monétisation + analytics
- RevenueCat — paywall (monthly/yearly/lifetime)
- Firebase Analytics + Crashlytics
- AdMob (free tier)
- Books section

⚠️ Phase 4 nécessite des comptes externes (RevenueCat, Firebase, AdMob, Apple
Developer, Google Play Console) et de la config native (`GoogleService-Info.plist`,
`google-services.json`, keys d'API). Ces fichiers sont gitignored par défaut.

## Architecture lib/

```
lib/
├── main.dart                    Init Hive + ProviderScope
├── app.dart                     MaterialApp.router
├── core/
│   ├── theme/                   Design tokens (colors, typography, spacing)
│   ├── router/                  GoRouter config
│   └── storage/                 Hive boxes setup
├── shared/
│   ├── models/                  Quote, QuoteCategory, UserPrefs (+ adapters)
│   └── widgets/                 PrimaryButton, ChipOption, IosStatusSpacer
├── features/
│   ├── onboarding/              Welcome + 12 questions
│   ├── home/                    Feed vertical
│   └── favorites/               Liste + empty state
└── data/seed_quotes.dart        Quotes seed
```
