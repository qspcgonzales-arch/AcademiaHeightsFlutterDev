# Academia Heights — App / Game Flow

Text version of Figure 1 from the proposal. Keep in sync with the gameplay
and the navigation graph in `lib/routes.dart`.

```mermaid
flowchart TD
    Start([App launch]) --> Title[Title Screen\nloading bar]
    Title --> Menu{Main Menu}

    Menu -->|New Game| Name[Enter name\nmax 16 chars]
    Menu -->|Load Game| Load[Pick a save file]
    Menu -->|Leaderboard| LB[Leaderboard] --> Menu
    Menu -->|Quit| Exit([Exit app])

    Name --> Intro[Principal intro dialogue]
    Load --> Play
    Intro --> Play[Gameplay\nexplore course area]

    Play -->|walk near book| Collect[Collect study material] --> Play
    Play -->|open menu| Pause{Pause menu}
    Pause -->|Settings| Settings[Audio settings] --> Pause
    Pause -->|Save / Load| SaveLoad[Save / Load menu] --> Pause
    Pause -->|Progress| Tracker[Academic Progress Tracker] --> Pause
    Pause -->|Resume| Play

    Play -->|talk to instructor| Decision{Take exam now?}
    Decision -->|Review first| Play
    Decision -->|Take exam now| ExamGate{Stage unlocked?\nPrelim->Midterm->Finals}
    ExamGate -->|locked| Play
    ExamGate -->|unlocked| Exam[Exam Screen\nMCQ + per-question timer]

    Exam --> Result[Exam Result\nscore, EXP, level]
    Result -->|failed| Play
    Result -->|passed, more stages left| Play
    Result -->|passed Finals of course| Cert[Certificate\ncourse complete]
    Cert -->|more courses| NextCourse[Unlock next course] --> Play
    Cert -->|last course| Win[Principal congratulations\nCertificate of Excellence]
    Win --> Menu
```

## Decision points

| Decision | Options | Rule |
|---|---|---|
| Main Menu | New Game / Load Game / Leaderboard / Quit | — |
| After talking to instructor | Take the exam now / I will review first | Must have talked to the instructor to reach here |
| Exam gate | proceed / blocked | Midterm needs Prelim passed; Finals needs Midterm passed |
| Exam result | pass / fail | Pass mark is a named constant; fail loops back to exploring, no game over |
| Course complete | next course / game won | Finishing the last course triggers the ending |
