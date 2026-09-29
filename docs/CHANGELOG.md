# Changelog

## 2026-09-08 - Project foundation

- Scaffold the Flutter and Flame project structure and establish the
  single-track ITE 013 exam plan.
- Add the Prelim, Midterm, and Finals question banks and shuffle answer
  choices on each attempt.
- Rewrite the scaffold in beginner-readable Dart and add setup and Copilot
  project instructions.

## 2026-09-15 - Core gameplay and progression

- Add the Android scaffold, player movement, exam-flow foundations, and core
  gameplay assets.
- Import and render the legacy 50-by-50 campus map, with landscape gameplay,
  tile collision, and the campus art pass.
- Add player walk animations, NPCs, collectible books, and centered tile-based
  spawn positions; fix camera following and player placement.
- Mark M2-M4 implemented in the design checklist for interactions, exams,
  progression, and persistence.

## 2026-09-30 - Gameplay polish and release setup

- Use a compact 48-by-48 contextual talk or pickup button on the gameplay HUD.
- Adapt main-menu spacing for short landscape screens and make the New Game
  form scroll when the keyboard reduces available height.
- Replace the legacy pixel-character logo mark with a scalable school crest,
  including the gameplay loading state.
- Add six non-interactive classroom students and collision-aware waypoint
  patrols for teachers and the principal; pause their movement during dialogue.
- Stop patrolling NPCs from entering the player's or another NPC's space.
- Reuse the existing teacher portraits for ambient students until student art
  is available.
- Configure release signing from local, Git-ignored `android/key.properties`
  and document Windows keystore setup and release APK steps in `docs/SETUP.md`.
- Ignore generated Android build output and add short-landscape layout
  regression tests.
- Validate with `flutter analyze` (no issues) and `flutter test` (23 passed).
- Smoke-test the x86_64 debug build in the Android emulator: gameplay rendered,
  the player reached the Principal, dialogue opened and closed, and the game
  remained alive without a game-specific fatal error.

The initial September 30 changes were committed and pushed on
`feature/core-gameplay-baseline` as `9ee2e04`. NPC patrol and classroom
population work was added later that day.

The signed APK in `build/` predates the September 30 UI and NPC changes and
needs to be rebuilt before distribution. No APK has been uploaded to Google
Drive.
