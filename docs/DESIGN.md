# Academia Heights — Design Notes

Distilled from the project proposal. This is the reference the screens and
systems are built against. If gameplay drifts from this, update this file in
the same PR.

## Core loop

1. Enter a course area (a tile-based map).
2. Explore; collect study-material **books** scattered around the map.
3. Talk to the course **instructor NPC**.
4. Choose **"Take the exam now"** or **"I will review first"**.
5. Take the exam — one multiple-choice question at a time, countdown timer
   per question.
6. See the result (score %, EXP earned, level progress, remark).
7. Pass → the next exam unlocks. Fail → review and retry.
8. Pass **Prelim → Midterm → Finals** → course complete → **Certificate** →
   next course unlocks.
9. Pass the last course's Finals → the Principal congratulates the player →
   **Certificate of Excellence** → game won.

## Screens

| Screen | Purpose | Key elements |
|---|---|---|
| **Title** | Entry point | Title, tagline, loading progress bar, mute/unmute icon |
| **Main Menu** | Hub | New Game, Load Game, Leaderboard, Quit; school background + main character |
| **New Game — Name Entry** | Start a run | Text field, **max 16 characters**, Start button |
| **Load Game** | Resume | List of save files: player name + date/time saved |
| **Leaderboard** | Rankings | Rank, Player Name, Average Score, Level, Quizzes Taken |
| **Controls** | Help | Explains the virtual joystick, tap-to-interact, menu button |
| **Settings — Audio** | Config | Music volume, SFX volume, mute all, test sound |
| **Save / Load Menu** | In-game persistence | Quick Save, Load Game, Delete Save, Auto Save toggle |
| **NPC Dialogue** | Story / prompts | Dialogue box; Principal intro; instructor conversations |
| **NPC Decision Prompt** | Branch | "Take the exam now" / "I will review first" |
| **Gameplay** | Main view | Top-left: name, level, EXP bar. Top-right: menu icons. Character centered. Virtual joystick + interact button. |
| **Collecting Study Material** | Feedback | Prompt when near a book; tap-to-interact collects it |
| **Exam** | Test | One MCQ at a time, 4 choices, countdown timer per question |
| **Exam Result** | Feedback | Score (e.g. 10/10, 100%), EXP earned, new level progress, remark |
| **Academic Progress Tracker** | Overview | Prelim / Midterm / Finals status, course completion %, next exam |
| **Certificate of Excellence** | Reward | Player name, overall score, honors (e.g. "Summa Cum Laude") |

## Mechanics

- **Controls (mobile):** virtual joystick to move; tap-to-interact to talk,
  pick up, and confirm. No keyboard.
- **Characters:** the player; the Principal; one Instructor per exam
  (Prelim / Midterm / Finals) per course.
- **Objects:** collectible study-material books; scenery (trees, buildings,
  paths) that blocks movement.
- **World:** school-themed, tile-based. Each course has its own area.
  Movement blocked by walls, trees, and other non-walkable tiles.
- **Scoring:** each exam gives a percentage. Scores tracked per player and
  averaged for the leaderboard.
- **Levels / EXP:** passing exams grants EXP and raises the player level;
  shown on the gameplay HUD and the result screen.
- **Progression:** strictly linear and locked — Midterm needs Prelim passed,
  Finals needs Midterm passed. Difficulty rises Prelim → Finals.
- **Time:** no limit while exploring; per-question countdown during exams.
- **Rewards:** certificate per completed course; the next course unlocks.
- **Win:** pass the last course's Finals. **No permanent lose** — failing an
  exam just sends the player back to reviewing.

## Rules (must not drift — mirrored in `CLAUDE.md`)

- Cannot take Midterm before passing Prelim.
- Cannot take Finals before passing Midterm.
- Cannot start an exam without first talking to the matching instructor.
- Failing an exam is not game over.
- The only tracked resource is the exam score → course average →
  leaderboard rank.

## Exam subject matter

Questions quiz the player on the course's own topics:

- **Module 1 — Introduction to Flutter:** what Flutter is, install steps,
  system requirements, project structure, the Dart language.
- **Module 2 — Emerging Technologies:** app-planning ideas (what to consider,
  how to plan an app).
- **Module 4 — Variables, Loops, and Arrays:** variables, loops, Dart lists.
- **Human-Computer Interaction:** usability and design principles.
- **Introduction to Arduino & AI:** used as quiz subject matter only — not
  built into the app.

## Data shapes

- `Question` — `prompt`, `choices` (4), `correctIndex` (0-3),
  `explanation?`.
- Question bank — `List<Question>` per (course, stage). Same shape everywhere.
- `PlayerProfile` — `name`, `level`, `exp`, `courseProgress`
  (per course: which of Prelim/Midterm/Finals are passed + their scores).
- Tile map — `List<List<int>>`, `0` walkable, non-zero blocked/typed.
- Save file — `PlayerProfile` serialized to JSON in `shared_preferences`.

## Milestone checklist

- [x] **M0 — Scaffold:** project structure, `pubspec.yaml`, `CLAUDE.md`,
      navigation between stub screens.
- [ ] **M1 — Core gameplay (Flame):** tile map render + collision, player
      component, virtual joystick, camera follow.
- [ ] **M2 — Interaction:** NPC components, tap-to-interact, dialogue box,
      collectible books, decision prompt.
- [ ] **M3 — Exam system:** `Question` model, question banks, exam screen
      with per-question timer, scoring, result screen, EXP/level.
- [ ] **M4 — Progression & persistence:** locked Prelim→Midterm→Finals,
      progress tracker, certificate, `SaveService` + `LeaderboardService`
      on `shared_preferences`, Save/Load screen, auto-save.
- [ ] **M5 — Polish:** audio via `flame_audio`, transitions, settings wired
      to real volume, pixel-art theme pass.
- [ ] **M6 — Testing & packaging:** unit tests for scoring/progression,
      emulator + real-device runs, release APK for the demo.
