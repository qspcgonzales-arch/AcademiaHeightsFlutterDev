# Copilot instructions — Academia Heights (Flutter & Flame)

VS Code Copilot (chat and agent mode) loads this file automatically. It is a
short version of [`CLAUDE.md`](../CLAUDE.md) — read that file for the full
rules before making non-trivial changes.

## The project

A 2D top-down school game, rebuilt from an old Java version as an **Android**
app with **Flutter + Flame**, for the ITE 013 course (T.I.P. Quezon City).
The player explores the campus, collects study-material books, talks to the
instructor, and passes the **Prelim → Midterm → Finals** exams to graduate.
It is a **single academic track** — each exam covers every module.

## Tech stack — do not change without being asked

| Concern | Choice |
|---|---|
| Language | Dart (null-safety), SDK `>=3.6.0`, Flutter `>=3.27` |
| UI | Flutter (Material) |
| Game engine | Flame (`flame`) |
| Audio | `flame_audio` |
| State | `provider` (`ChangeNotifier` in `lib/state/`) |
| Storage | `shared_preferences` |

No second state or storage library. No Riverpod, Bloc, Hive, sqflite, GetX,
etc. Android only (no iOS work), no networking, no multiplayer.

## Two rules that override "clever"

An instructor and student teammates read this code.

1. **Write plain, beginner-readable Dart.** Use `if/else`, not `switch`
   expressions or pattern matching. Use ordinary `for` loops, not
   `.map().where().fold()` chains. No `sealed` classes, custom `mixin`s,
   extension methods, or tear-offs. Full-word names. Put a `//` comment
   above anything non-obvious, and above every `~/`, `??`, `?.`, `..`,
   `late`. Collection-`for` is OK **only inside a widget list**
   (`children: [ for (...) Widget() ]`).
2. **Move fast, stay simple.** Build one feature end to end before the next.
   Don't add layers or options "for later". Follow the milestone list in
   [`docs/DESIGN.md`](../docs/DESIGN.md).

If an advanced feature really is clearest, use it **and comment what it does.**

## Where code goes

```
lib/
├── screens/   Flutter widgets, one file per screen
├── game/      Flame components (player, tile_map, npc, collectible)
├── models/    plain data classes (PlayerProfile, Question, Exam, SaveFile…)
├── state/     provider ChangeNotifier controllers
├── services/  shared_preferences read/write
├── data/      static content — courses.dart, questions_data.dart
└── theme/     app_theme.dart (colours, spacing, shared numbers)
```

New code lands in the matching folder. If it doesn't obviously fit, ask.

## Exam rules — must not drift

- Midterm is locked until Prelim is passed; Finals until Midterm is passed.
- An exam can't start until the player talks to the instructor.
- Failing an exam is **not** game over — the player retries.
- The four answer choices are shuffled per attempt
  (`Question.shuffledChoices`).
- Question banks: `prelimQuestions` (10), `midtermQuestions` (15),
  `finalsQuestions` (20) in `lib/data/questions_data.dart`. Same `Question`
  shape everywhere (prompt, 4 choices, correctIndex).

## Flutter vs Flame

They are separate loops. Don't drive Flame components from `setState`, and
don't call `notifyListeners()` from Flame's `update()` every frame — push a
value once, when it changes.

## Before finishing a change

```bash
flutter pub get      # if pubspec.yaml changed
dart format .
flutter analyze      # keep clean
flutter test
```

Small commits, present-tense messages (`add exam timer`). Feature branch +
PR, never push straight to `main`. Never commit `build/`, `.dart_tool/`,
`android/local.properties`, or keystores.

First-time environment setup: [`docs/SETUP.md`](../docs/SETUP.md).
