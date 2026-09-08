import 'exam.dart';

/// Everything about one player's run: name, level, EXP, and how far they have
/// got in each course. Save/load and the leaderboard both read from this one
/// object, so player facts never get spread across the UI.
class PlayerProfile {
  /// [courseProgress] is optional; a fresh profile starts with none.
  PlayerProfile({
    required this.name,
    this.level = 1,
    this.exp = 0,
    Map<String, CourseProgress>? courseProgress,
  }) : progressByCourseId = courseProgress ?? <String, CourseProgress>{};

  final String name;
  int level;
  int exp;

  /// Progress for each course, looked up by the course id.
  final Map<String, CourseProgress> progressByCourseId;

  /// How much EXP moves the player up one level.
  static const int expPerLevel = 100;

  /// The progress record for a course, creating an empty one the first time.
  CourseProgress progressFor(String courseId) {
    CourseProgress? existing = progressByCourseId[courseId];
    if (existing == null) {
      existing = CourseProgress();
      progressByCourseId[courseId] = existing;
    }
    return existing;
  }

  /// Can the player start [stage] of [courseId] yet? Prelim is always open;
  /// the others need the stage before them passed.
  bool isStageUnlocked(String courseId, ExamStage stage) {
    final ExamStage? needsFirst = prerequisiteOf(stage);
    if (needsFirst == null) return true;
    return progressFor(courseId).isPassed(needsFirst);
  }

  /// True when Prelim, Midterm, and Finals are all passed for [courseId].
  bool isCourseComplete(String courseId) {
    final CourseProgress progress = progressFor(courseId);
    for (final ExamStage stage in ExamStage.values) {
      if (!progress.isPassed(stage)) return false;
    }
    return true;
  }

  /// Record an exam attempt: keep the best score for that stage, add EXP,
  /// and recompute the level.
  void applyAttempt(ExamAttempt attempt, {required double passMark}) {
    progressFor(attempt.courseId).record(attempt, passMark: passMark);
    exp += attempt.expEarned;
    // "~/" is whole-number division (no decimals).
    level = 1 + (exp ~/ expPerLevel);
  }

  /// The average of every recorded best score, as a percentage. Shown on the
  /// leaderboard.
  int get averagePercent {
    final List<int> everyBestPercent = [];
    for (final CourseProgress progress in progressByCourseId.values) {
      for (final int percent in progress.bestPercents) {
        everyBestPercent.add(percent);
      }
    }
    if (everyBestPercent.isEmpty) return 0;

    int total = 0;
    for (final int percent in everyBestPercent) {
      total += percent;
    }
    return total ~/ everyBestPercent.length;
  }

  /// How many exam attempts the player has made in total.
  int get quizzesTaken {
    int total = 0;
    for (final CourseProgress progress in progressByCourseId.values) {
      total += progress.attemptCount;
    }
    return total;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> progressJson = {};
    for (final String courseId in progressByCourseId.keys) {
      progressJson[courseId] = progressByCourseId[courseId]!.toJson();
    }
    return {
      'name': name,
      'level': level,
      'exp': exp,
      'courseProgress': progressJson,
    };
  }

  static PlayerProfile fromJson(Map<String, dynamic> json) {
    final Map<String, CourseProgress> progress = {};
    final Object? rawProgress = json['courseProgress'];
    if (rawProgress is Map<String, dynamic>) {
      for (final String courseId in rawProgress.keys) {
        final Map<String, dynamic> entry =
            rawProgress[courseId] as Map<String, dynamic>;
        progress[courseId] = CourseProgress.fromJson(entry);
      }
    }

    return PlayerProfile(
      name: json['name'] as String,
      level: (json['level'] as int?) ?? 1,
      exp: (json['exp'] as int?) ?? 0,
      courseProgress: progress,
    );
  }
}

/// One course's progress: the best attempt at each stage and which stages
/// have been passed.
class CourseProgress {
  CourseProgress();

  /// Best attempt so far for each stage the player has tried.
  final Map<ExamStage, ExamAttempt> _bestByStage = {};

  /// Stages the player has passed at least once.
  final Set<ExamStage> _passedStages = {};

  int _attemptCount = 0;

  int get attemptCount => _attemptCount;

  ExamAttempt? bestAt(ExamStage stage) => _bestByStage[stage];

  bool isPassed(ExamStage stage) => _passedStages.contains(stage);

  /// The best percentage for every stage that has been attempted.
  List<int> get bestPercents {
    final List<int> percents = [];
    for (final ExamAttempt attempt in _bestByStage.values) {
      percents.add(attempt.percent);
    }
    return percents;
  }

  /// Store an attempt: bump the count, keep it if it beats the old best, and
  /// remember the stage as passed if the score cleared [passMark].
  void record(ExamAttempt attempt, {required double passMark}) {
    _attemptCount += 1;

    final ExamAttempt? currentBest = _bestByStage[attempt.stage];
    if (currentBest == null || attempt.percent > currentBest.percent) {
      _bestByStage[attempt.stage] = attempt;
    }

    if (attempt.passed(passMark)) {
      _passedStages.add(attempt.stage);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> bestJson = {};
    for (final ExamStage stage in _bestByStage.keys) {
      bestJson[stage.name] = _bestByStage[stage]!.toJson();
    }

    final List<String> passedNames = [];
    for (final ExamStage stage in _passedStages) {
      passedNames.add(stage.name);
    }

    return {
      'attemptCount': _attemptCount,
      'passed': passedNames,
      'best': bestJson,
    };
  }

  static CourseProgress fromJson(Map<String, dynamic> json) {
    final CourseProgress progress = CourseProgress();
    progress._attemptCount = (json['attemptCount'] as int?) ?? 0;

    final Object? rawBest = json['best'];
    if (rawBest is Map<String, dynamic>) {
      for (final String stageName in rawBest.keys) {
        final ExamStage stage = ExamStage.values.byName(stageName);
        final Map<String, dynamic> attemptJson =
            rawBest[stageName] as Map<String, dynamic>;
        progress._bestByStage[stage] = ExamAttempt.fromJson(attemptJson);
      }
    }

    final Object? rawPassed = json['passed'];
    if (rawPassed is List) {
      for (final Object? stageName in rawPassed) {
        progress._passedStages.add(
          ExamStage.values.byName(stageName as String),
        );
      }
    }

    return progress;
  }
}
