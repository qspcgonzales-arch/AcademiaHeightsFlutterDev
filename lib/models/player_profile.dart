import 'exam.dart';

/// The single source of truth for one player's run. Save/load and the
/// leaderboard both read from this — do not scatter these fields across
/// widgets or Flame components.
class PlayerProfile {
  PlayerProfile({
    required this.name,
    this.level = 1,
    this.exp = 0,
    Map<String, CourseProgress>? courseProgress,
  }) : courseProgress = courseProgress ?? {};

  final String name;
  int level;
  int exp;

  /// Keyed by [Course.id].
  final Map<String, CourseProgress> courseProgress;

  CourseProgress progressFor(String courseId) =>
      courseProgress.putIfAbsent(courseId, CourseProgress.new);

  /// Whether [stage] of [courseId] may be started, given the ordering rule
  /// (Prelim -> Midterm -> Finals).
  bool isStageUnlocked(String courseId, ExamStage stage) {
    final prereq = stage.prerequisite;
    if (prereq == null) return true;
    return progressFor(courseId).isPassed(prereq);
  }

  bool isCourseComplete(String courseId) {
    final p = progressFor(courseId);
    return ExamStage.values.every(p.isPassed);
  }

  /// Records an attempt: stores the best score for that stage and adds EXP.
  void applyAttempt(ExamAttempt attempt, {required double passMark}) {
    final p = progressFor(attempt.courseId);
    p.record(attempt, passMark: passMark);
    exp += attempt.expEarned;
    level = 1 + exp ~/ _expPerLevel;
  }

  /// Average of every recorded best score, as a percentage. Used by the
  /// leaderboard.
  int get averagePercent {
    final scores = <int>[
      for (final p in courseProgress.values) ...p.bestPercents,
    ];
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) ~/ scores.length;
  }

  int get quizzesTaken =>
      courseProgress.values.fold(0, (sum, p) => sum + p.attemptCount);

  static const int _expPerLevel = 100;

  Map<String, dynamic> toJson() => {
        'name': name,
        'level': level,
        'exp': exp,
        'courseProgress': {
          for (final entry in courseProgress.entries)
            entry.key: entry.value.toJson(),
        },
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
        name: json['name'] as String,
        level: json['level'] as int? ?? 1,
        exp: json['exp'] as int? ?? 0,
        courseProgress: {
          for (final entry
              in (json['courseProgress'] as Map<String, dynamic>? ?? {})
                  .entries)
            entry.key: CourseProgress.fromJson(
              entry.value as Map<String, dynamic>,
            ),
        },
      );
}

/// Per-course record of the best attempt at each stage.
class CourseProgress {
  CourseProgress({Map<ExamStage, ExamAttempt>? best})
      : _best = best ?? {},
        _attemptCount = 0;

  CourseProgress._({
    required Map<ExamStage, ExamAttempt> best,
    required int attemptCount,
  })  : _best = best,
        _attemptCount = attemptCount;

  final Map<ExamStage, ExamAttempt> _best;
  final Set<ExamStage> _passed = {};
  int _attemptCount;

  int get attemptCount => _attemptCount;

  ExamAttempt? bestAt(ExamStage stage) => _best[stage];

  bool isPassed(ExamStage stage) => _passed.contains(stage);

  List<int> get bestPercents =>
      [for (final a in _best.values) a.percent];

  void record(ExamAttempt attempt, {required double passMark}) {
    _attemptCount++;
    final current = _best[attempt.stage];
    if (current == null || attempt.percent > current.percent) {
      _best[attempt.stage] = attempt;
    }
    if (attempt.passedAt(passMark)) _passed.add(attempt.stage);
  }

  Map<String, dynamic> toJson() => {
        'attemptCount': _attemptCount,
        'passed': [for (final s in _passed) s.name],
        'best': {
          for (final entry in _best.entries)
            entry.key.name: entry.value.toJson(),
        },
      };

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    final best = <ExamStage, ExamAttempt>{
      for (final entry in (json['best'] as Map<String, dynamic>? ?? {}).entries)
        ExamStage.values.byName(entry.key):
            ExamAttempt.fromJson(entry.value as Map<String, dynamic>),
    };
    final progress = CourseProgress._(
      best: best,
      attemptCount: json['attemptCount'] as int? ?? 0,
    );
    for (final name in (json['passed'] as List<dynamic>? ?? [])) {
      progress._passed.add(ExamStage.values.byName(name as String));
    }
    return progress;
  }
}
