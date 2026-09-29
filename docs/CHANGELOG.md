# Changelog

## 2026-09-30 - Unreleased

These changes are present in the local working tree and have not yet been
committed or pushed.

### Gameplay and exams

- Load and render the legacy 50-by-50 campus map with tile-based collision.
- Follow and zoom the camera around the player; animate movement and prevent
  the player from walking through walls or NPCs.
- Add instructor and other NPC interactions, nearby-book pickup, and a
  contextual interaction button.
- Shuffle exam answer choices, show timed questions, and connect exam attempts
  to scoring, EXP, and progression.

### Interface and branding

- Use a compact 48-by-48 contextual talk or pickup button on the gameplay HUD.
- Adapt the main menu spacing and logo size for short landscape screens.
- Make the New Game form scroll when the keyboard reduces available height.
- Replace the legacy pixel-character logo mark with a scalable school crest,
  including the gameplay loading state.

### Android distribution and validation

- Configure release signing from local, Git-ignored `android/key.properties`
  and fail release builds with a clear message when signing is not configured.
- Document Windows keystore setup, release APK build, and key-protection steps
  in `docs/SETUP.md`; ignore generated Android build output.
- Add short-landscape layout regression tests. The latest validation passed
  `flutter analyze` with no issues and all 17 tests.

The signed APK currently in `build/` predates these latest UI changes and must
be rebuilt before distribution. No APK has been uploaded to Google Drive.