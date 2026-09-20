# Pushti Kirtan

Pushtimarg bhajan & kirtan lyrics app — Flutter + Firebase.

## Run it

```bash
flutter pub get
flutter run
```

Without Firebase configured the app starts in **demo mode**: bundled sample bhajans,
an in-memory sign-in, and a sample tithi table. Everything works; nothing persists
to the cloud.

## Connect Firebase

1. Create a Firebase project and enable **Authentication** (Email/Password, Google,
   Anonymous) and **Cloud Firestore**.
2. Generate the platform config:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   This overwrites `lib/firebase_options.dart` and adds `google-services.json` /
   `GoogleService-Info.plist`. On the next launch `AppConfig.demoMode` is false.
3. Google Sign-In on Android needs the SHA-1 of your debug/release keys in the
   Firebase console; on iOS add the reversed client ID URL scheme to `Info.plist`.

## Firestore layout

| Collection        | Doc id       | Fields |
|-------------------|--------------|--------|
| `bhajans`         | slug         | `title`, `category` (`pad|aarti|kirtan|varta`), `poet`, `seva`, `video` (YouTube id, optional), `tags[]` |
| `lyrics`          | same slug    | `gu`, `hi`, `en` — each a list of lines; `""` = stanza break. Read only when a bhajan is opened |
| `tithi`           | `yyyy-MM-dd` | `date`, `month_gu`, `paksha` (`sud\|vad`), `tithi` (1–15), `utsav[]`, `ekadashi_name` |
| `users/{uid}`     | auth uid     | `favourites[]`, `progress{bhajanId: line}` |

Seed helpers: `sampleBhajans`, `sampleLyrics`, `sampleTithi` have `toMap()` on every model.

## Project structure

```
lib/
├── main.dart                 bootstrap (Firebase → demo fallback), ProviderScope
├── app.dart                  MaterialApp.router + light/dark theme
├── core/
│   ├── config/               AppConfig (demo mode, default seva times)
│   ├── theme/                design tokens — colours, type scale, spacing, motion, ThemeData
│   ├── router/               go_router: routes, shell, transitions, auth redirect
│   ├── utils/                context.colors / context.text, Gap
│   └── widgets/              shared components (buttons, fields, tiles, nav, cards, OpenContainerCard)
└── features/<feature>/
    ├── domain/               plain models
    ├── data/                 repositories (Firestore + sample implementations)
    ├── providers/            Riverpod state
    └── presentation/         screens + feature widgets
```

### Change the look in one place

* **Colours** — `lib/core/theme/app_colors.dart` (`AppPalette` raw hexes → `AppColors` light/dark tokens)
* **Fonts & sizes** — `lib/core/theme/app_typography.dart` (families bundled from `assets/fonts`)
* **Spacing, radii, sizes, animation timing** — `lib/core/theme/app_spacing.dart`

Widgets read `context.colors.accent`, `AppTypography.titleLarge`, `AppSpacing.lg` — never raw values.

### Animation

* Card → screen uses the Material **container transform** (`animations` package) via
  `OpenContainerCard`; the tapped row grows into the reader and shrinks back on close.
* Tab switches fade-through; pushed screens (calendar, reader by URL) use shared-axis.
* Micro-animations (list fade-ins, entrance) use `flutter_animate`.
