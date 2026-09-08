# Setup guide — Academia Heights (Flutter & Flame)

How to get the project building and running on a fresh machine. Works as a
checklist for a person, and the **agent task** block below can be pasted
straight into GitHub Copilot Chat (agent mode) in VS Code.

---

## Give this to the Copilot agent

> Open the Command Palette → **Chat: Open Chat (Agent)**, paste the block
> below, and let it work. Approve the terminal commands it proposes.

```text
You are setting up this Flutter project for the first time. Follow docs/SETUP.md.

Context:
- This repo has lib/, test/, pubspec.yaml, and docs, but NO platform folders
  (android/ etc.) yet — they are generated, not committed.
- Stack is locked: Flutter + Flame + provider + shared_preferences, Android
  only. Do not add or change dependencies.
- Read .github/copilot-instructions.md and CLAUDE.md and follow them.

Do these steps, stopping to tell me if any step fails:
1. Run `flutter --version` and `flutter doctor`. If Flutter is not installed,
   stop and tell me how to install it for my OS — do not try to install it
   yourself.
2. Generate the Android project files without touching my code:
   `flutter create . --platforms=android --org com.tip.academiaheights`
3. `flutter pub get`
4. `dart format --output=none --set-exit-if-changed .` — if it fails, run
   `dart format .` and show me the diff.
5. `flutter analyze` — fix any errors and warnings you can do safely and
   cheaply (unused imports, `const`, `final`, formatting). Do NOT change
   behaviour, rename public APIs, or restructure files. Show me anything you
   are unsure about instead of guessing.
6. `flutter test` — all tests must pass. If one fails, show me the output and
   your diagnosis before changing anything.
7. Report: Flutter version, whether analyze is clean, test result, and a list
   of every file you changed with a one-line reason each.

Do not commit anything. Do not run `flutter run` (I will do that on my
device).
```

---

## Manual steps

### 1. Prerequisites

| Tool | Notes |
|---|---|
| **Flutter SDK** 3.27+ / Dart 3.6+ | <https://docs.flutter.dev/get-started/install> — pick your OS, follow it fully, then run `flutter doctor` until the **Android toolchain** and **VS Code** rows are green (the iOS/Xcode rows can stay red — we don't target iOS). |
| **Git** | <https://git-scm.com> |
| **VS Code** | with the **Flutter** extension (ID `Dart-Code.flutter`) — it pulls in the Dart extension too. |
| **Android device or emulator** | A physical Android phone with **USB debugging** on, or an emulator created in Android Studio's Device Manager. `flutter devices` should list it. |

### 2. Clone

```bash
git clone https://github.com/qspcgonzales-arch/AcademiaHeightsFlutterDev.git
cd AcademiaHeightsFlutterDev
code .
```

### 3. Generate the platform folders

This repo holds the Dart source only. The `android/` folder is generated:

```bash
flutter create . --platforms=android --org com.tip.academiaheights
```

`flutter create .` on an existing folder **only fills in what's missing** —
it will not overwrite `lib/`, `test/`, `pubspec.yaml`, `assets/`, or the
docs. It also writes `.metadata` and, if you leave off `--platforms`, folders
for web/desktop too (harmless, but we only need `android`).

> Once the team decides to commit `android/`, delete the matching lines from
> `.gitignore`, commit it, and everyone can skip this step.

### 4. Get packages

```bash
flutter pub get
```

### 5. Check it

```bash
dart format .
flutter analyze     # expect a first-run batch of lint findings — see below
flutter test        # progression + question shuffle tests should pass
```

The code was written without a local SDK, so the **first `flutter analyze`
will likely list findings** (unused imports, `prefer_const_constructors`,
etc.). Most are auto-fixable:

```bash
dart fix --apply
dart format .
flutter analyze
```

If `flutter analyze` reports real **errors** (not warnings) — usually a Flame
API that changed version — note the file and message and raise it; don't
guess a fix that changes behaviour.

### 6. Run it

- **VS Code:** pick your device in the status bar (bottom-right), press
  **F5** (or Run → Start Debugging).
- **Terminal:** `flutter run`

You should land on the Title screen, which fills a loading bar and moves to
the Main Menu.

### 7. Build the demo APK (only near demo day)

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

Copy that file to a phone and install it to confirm it works outside the
emulator.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `flutter: command not found` | Flutter's `bin` isn't on your `PATH`. Re-check the install guide's PATH step, then restart the terminal / VS Code. |
| VS Code doesn't recognise it as a Flutter project | Install the **Flutter** extension, then **Developer: Reload Window**. |
| `No devices found` | Start an emulator, or plug in a phone with USB debugging enabled and accept the "Allow USB debugging?" prompt. Check with `flutter devices`. |
| `flutter analyze` fails on `withValues` / `RadioListTile` | Your Flutter is older than 3.27. Upgrade: `flutter upgrade`. |
| Gradle / Android build errors after `flutter create` | `flutter clean && flutter pub get`, make sure `flutter doctor` Android rows are green, accept licences with `flutter doctor --android-licenses`. |
| Package resolution errors in `pubspec.yaml` | Don't hand-edit versions. Run `flutter pub get` again; if a package truly won't resolve, raise it — don't swap the package out. |

## What not to do

- Don't add or replace dependencies (see `.github/copilot-instructions.md`).
- Don't commit `build/`, `.dart_tool/`, `android/local.properties`, or `*.jks`
  / `*.keystore` — `.gitignore` already covers them.
- Don't push to `main` — branch, open a PR (see `docs/CONTRIBUTING.md`).
