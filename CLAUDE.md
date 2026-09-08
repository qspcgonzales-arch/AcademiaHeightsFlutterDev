# CLAUDE.md — Academia Heights (Flutter & Flame Mobile Edition)

Standing instructions for Claude Code on this repo. Read before writing,
reviewing, or debugging any code here.

## What this project is

Academia Heights is a 2D top-down educational game, originally built in Java
for a past class, now being **rebuilt as an Android mobile app** with Flutter
+ Flame for **ITE 013 — Application Development and Emerging Technologies**
(T.I.P. Quezon City, College of Computer Studies, Section DS41S1).

The player walks around a tile-based school, collects study-material books,
talks to instructor NPCs, and takes multiple-choice exams to progress through
**Prelim → Midterm → Finals**. The game is a **single academic track** (the
ITE 013 course) — each exam covers every module. Passing all three exams
graduates the player and shows the Certificate of Excellence. The `Course`
model and `courses` list are kept generic in case more tracks are added
later, but today there is exactly one.

## Tech stack — do not deviate without asking

| Concern | Choice | Notes |
|---|---|---|
| Language | Dart, null-safety on | SDK `>=3.6.0 <4.0.0`, Flutter `>=3.27` |
| UI | Flutter (Material) | All non-gameplay screens are widgets |
| Game engine | **Flame** (`flame`) | Game loop, sprites, tile map, camera, collision |
| Audio | `flame_audio` | Background music + SFX |
| State management | **`provider`** | `ChangeNotifier` controllers in `lib/state/` |
| Local storage | **`shared_preferences`** | Save files + leaderboard as JSON strings |
| Version control | Git + GitHub | 3-person team working in parallel |

There is **no** second state-management library and **no** second storage
library. Do not add Riverpod, Bloc, Hive, Isar, sqflite, etc. without
explicit approval in the request.

Scope limits from the proposal: **Android only** (iOS is a stretch goal),
**no multiplayer / no cloud sync / no online leaderboard** — all data stays
on the device. No original art is produced from scratch; assets are reused.

## Folder conventions

```
lib/
├── main.dart      # Entry point: sets up providers, runs App
├── app.dart       # MaterialApp, theme, named routes
├── routes.dart    # Route-name constants (use these, never string literals)
├── screens/       # Flutter widgets — one file per screen
│                  #   title, main_menu, new_game, load_game, leaderboard,
│                  #   controls, settings, save_load, gameplay, exam,
│                  #   exam_result, progress_tracker, certificate
├── game/          # Flame components — player, tile_map, npc, collectible,
│                  #   collision; the FlameGame subclass lives here
├── models/        # Plain data classes — PlayerProfile, Course, Question,
│                  #   ExamAttempt, SaveFile, LeaderboardEntry
├── state/         # ChangeNotifier controllers exposed via provider
├── services/      # I/O — SaveService, LeaderboardService (shared_preferences)
├── data/          # Static content — course list, question banks
└── theme/         # Colors, text styles, the pixel-art theme
assets/
├── images/        # Sprites, backgrounds, UI art
├── audio/         # Music + SFX
└── tiles/         # Tile sheets / Tiled maps
```

New code lands in the matching folder. If a file does not obviously fit,
ask rather than guessing.

## Data-structure rules (Module 4: variables, loops, arrays)

- **Exam questions** are a `List<Question>`. `Question` = `prompt` (String),
  `choices` (`List<String>`, length 4), `correctIndex` (int, 0-3), optional
  `explanation`. There is one bank per stage — `prelimQuestions` (10),
  `midtermQuestions` (15), `finalsQuestions` (20) in
  `lib/data/questions_data.dart`, mirrored in `docs/quiz_bank.md`. All use
  this exact shape so the exam screen renders any of them the same way.
- **Tile maps** are `List<List<int>>` (row-major). Loops iterate
  rows/columns to place tiles and to test collision. `0` = walkable;
  non-zero = specific tile / blocked (document the mapping where the map is
  defined).
- **Player state** (name, level, exp, per-course progress) lives in **one**
  `PlayerProfile` model, read by save/load and the leaderboard from that
  single source of truth. Never scatter player fields across widgets.
- **Save files** serialize `PlayerProfile` to JSON under a
  `shared_preferences` key. Keep the JSON schema in `SaveFile` — if you
  change it, add a version field and a migration, don't silently break old
  saves.

## Exam progression rules — must not drift

1. Midterm is locked until Prelim is **passed** for that course.
2. Finals is locked until Midterm is **passed** for that course.
3. An exam cannot start until the player has talked to the matching
   instructor NPC.
4. Passing all three exams graduates the player (Certificate of Excellence).
5. Failing an exam is **not** game over — the player reviews and retries.
   No lives, no health.
6. Each exam question has a countdown timer; difficulty rises Prelim → Finals.
7. The four choices are **shuffled per attempt** (`Question.shuffledChoices`),
   so the correct answer isn't always in the same slot. Question order is
   currently left as authored.

Exam **subject matter** (what questions quiz the player on): Module 1
(Intro to Flutter), Module 2 (Emerging Technologies / app planning),
Module 4 (Variables, Loops, Arrays), Human-Computer Interaction, and
Introduction to Arduino & AI.

## Controls — touch-first, not keyboard

The Java original used WASD / arrows / SPACE / ENTER / ESC. The mobile
version replaces all of that:

- **Move:** on-screen virtual joystick (Flame `JoystickComponent`).
- **Interact / confirm:** a tap-to-interact button (talk to NPC, pick up
  book, advance dialogue).
- **Menu:** an on-screen icon, top-right of the gameplay HUD.

Do not reintroduce `KeyboardEvents` / hardware-key handling into gameplay or
UI. (A debug-only keyboard fallback is acceptable if clearly marked.)

## Flutter vs Flame — keep the two loops separate

- Flutter rebuilds on `setState` / provider notifications. Flame updates
  every frame in `update(dt)` and draws in `render(canvas)`.
- Do not drive Flame components from `setState`. Do not call `notifyListeners`
  from inside Flame's `update` loop every frame — push a result once, at the
  moment it changes (e.g. exam finished, book collected).
- The gameplay screen hosts the game with `GameWidget`; HUD and overlays
  (dialogue, pause menu) are Flutter widgets layered via Flame's overlay API
  or a `Stack`.

## Coding style

- `PascalCase` types, `camelCase` members, `lowercase_with_underscores.dart`
  file names. One public class per file, file named after it.
- Prefer `StatelessWidget`; reach for `StatefulWidget` only for local,
  ephemeral UI state (text controllers, animation controllers). Shared state
  goes through a provider.
- `const` constructors wherever possible. Extract magic numbers to named
  constants (screen padding, tile size, exam pass mark, name length cap = 16).
- Keep widget `build` methods short — pull sub-trees into small private
  widgets or methods.
- Public APIs get a doc comment saying *why*, not *what*.

## After making changes

Run, in the repo root:

```
flutter pub get          # if pubspec.yaml changed
dart format .
flutter analyze          # must be clean — no new warnings
flutter test             # must pass
```

For gameplay changes that analyze/test can't cover, say so and describe how
you verified (e.g. "ran on Pixel 6 emulator, joystick + interact confirmed").

## Git hygiene

- Small, focused commits with present-tense messages
  (`add exam timer`, not `added stuff`).
- Never commit `build/`, `.dart_tool/`, `android/local.properties`,
  keystores, or generated plugin registrants (see `.gitignore`).
- Feature branches off `main`; open a PR; don't push straight to `main`.
- The platform folders (`android/`, `ios/`) are generated with
  `flutter create` — see `README.md`. If they are committed, don't
  hand-edit generated files without noting it.

## When a request implies a new architectural decision

New package, new state pattern, new folder, a change to the save schema or
the exam-progression rules — call it out explicitly and ask before
proceeding. Do not introduce a second convention next to an existing one.
