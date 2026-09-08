# Contributing — team Git workflow

Three people work on this repo at the same time. These rules keep us from
overwriting each other.

## Branches

- `main` is always in a runnable state. **Never push straight to `main`.**
- One branch per feature or fix, named `type/short-description`:
  - `feat/virtual-joystick`
  - `feat/exam-timer`
  - `fix/leaderboard-sort`
  - `docs/design-notes`

```bash
git checkout main
git pull
git checkout -b feat/virtual-joystick
```

## Commits

- Small and focused — one logical change per commit.
- Present tense, lowercase, no period: `add joystick component`,
  `wire exam result to profile`.
- Do not commit generated files (`build/`, `.dart_tool/`,
  `android/local.properties`, keystores). `.gitignore` covers these.
- Run before committing:

  ```bash
  dart format .
  flutter analyze
  flutter test
  ```

## Pull requests

1. Push your branch: `git push -u origin feat/virtual-joystick`.
2. Open a PR into `main` on GitHub. Describe what changed and how you
   tested it (emulator? real device?).
3. At least one other member reviews before merge.
4. Squash-merge to keep `main` history clean.
5. Delete the branch after merge.

## Staying up to date / resolving conflicts

Rebase your feature branch on the latest `main` often:

```bash
git checkout main
git pull
git checkout feat/virtual-joystick
git rebase main
# fix conflicts, then:
git add <files>
git rebase --continue
git push --force-with-lease
```

To avoid conflicts in the first place: agree on who owns which folder for a
given sprint (`screens/` vs `game/` vs `models/`), and keep PRs short-lived.

## Who owns what (from the proposal)

| Area | Lead |
|---|---|
| Flutter/Flame architecture, game UI, flow & mechanics | De Guzman |
| Player movement & touch controls, game objects/items, quiz content | Gonzales |
| NPC interactions & dialogue, splash screen & app config, QA | Carag |

Coordinate before editing a file outside your area.
