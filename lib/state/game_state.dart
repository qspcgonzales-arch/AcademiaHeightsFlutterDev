import 'package:flutter/foundation.dart';

import '../data/courses.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/leaderboard_entry.dart';
import '../models/player_profile.dart';
import '../models/save_file.dart';
import '../services/leaderboard_service.dart';
import '../services/save_service.dart';
import '../theme/app_theme.dart';

/// App-wide game state: the active player, which course they are in, and the
/// progression rules. The single source of truth the screens and (later) the
/// Flame game read from.
class GameState extends ChangeNotifier {
  GameState({
    required SaveService saveService,
    required LeaderboardService leaderboardService,
  })  : _saveService = saveService,
        _leaderboardService = leaderboardService;

  final SaveService _saveService;
  final LeaderboardService _leaderboardService;

  PlayerProfile? _profile;
  PlayerProfile? get profile => _profile;
  bool get hasActiveRun => _profile != null;

  String? _activeSlotId;
  int _courseIndex = 0;

  Course get currentCourse => courses[_courseIndex];
  bool get isFinalCourse => _courseIndex == courses.length - 1;

  /// The last attempt taken, handed to the result screen.
  ExamAttempt? lastAttempt;

  // --- run lifecycle -------------------------------------------------------

  void startNewGame(String name) {
    final trimmed = name.trim();
    _profile = PlayerProfile(
      name: trimmed.substring(
        0,
        trimmed.length.clamp(0, AppTheme.maxPlayerNameLength),
      ),
    );
    _activeSlotId = 'slot_${DateTime.now().millisecondsSinceEpoch}';
    _courseIndex = 0;
    lastAttempt = null;
    notifyListeners();
  }

  void loadGame(SaveFile file) {
    _profile = file.profile;
    _activeSlotId = file.slotId;
    _courseIndex = _firstUnfinishedCourseIndex();
    lastAttempt = null;
    notifyListeners();
  }

  int _firstUnfinishedCourseIndex() {
    final profile = _profile;
    if (profile == null) return 0;
    for (var i = 0; i < courses.length; i++) {
      if (!profile.isCourseComplete(courses[i].id)) return i;
    }
    return courses.length - 1;
  }

  // --- progression -------------------------------------------------------

  bool isStageUnlocked(ExamStage stage) =>
      _profile?.isStageUnlocked(currentCourse.id, stage) ?? false;

  bool isStagePassed(ExamStage stage) =>
      _profile?.progressFor(currentCourse.id).isPassed(stage) ?? false;

  /// Records an exam attempt, updates EXP/level, advances the course if it
  /// is now complete, and auto-saves if enabled.
  Future<void> submitAttempt(ExamAttempt attempt) async {
    final profile = _profile;
    if (profile == null) return;

    profile.applyAttempt(attempt, passMark: AppTheme.examPassMark);
    lastAttempt = attempt;

    if (profile.isCourseComplete(currentCourse.id) && !isFinalCourse) {
      _courseIndex++;
    }
    notifyListeners();

    if (_saveService.autoSaveEnabled) {
      await save();
    }
  }

  bool get hasWon {
    final profile = _profile;
    if (profile == null) return false;
    return profile.isCourseComplete(courses.last.id);
  }

  // --- persistence -------------------------------------------------------

  Future<void> save() async {
    final profile = _profile;
    final slotId = _activeSlotId;
    if (profile == null || slotId == null) return;

    await _saveService.save(
      SaveFile(slotId: slotId, profile: profile, savedAt: DateTime.now()),
    );
    await _leaderboardService.submit(
      LeaderboardEntry.fromProfile(profile),
    );
  }

  void endRun() {
    _profile = null;
    _activeSlotId = null;
    _courseIndex = 0;
    lastAttempt = null;
    notifyListeners();
  }
}
