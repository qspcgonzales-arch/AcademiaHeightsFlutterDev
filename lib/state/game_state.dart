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

/// App-wide game state: the current player and the exam-progression rules.
/// Screens (and later the Flame game) read the player's status from here so
/// there is one source of truth.
///
/// `ChangeNotifier` + `notifyListeners()` is how `provider` tells the UI to
/// rebuild. Call `notifyListeners()` after anything the screens should see.
class GameState extends ChangeNotifier {
  GameState({
    required SaveService saveService,
    required LeaderboardService leaderboardService,
  })  : _saveService = saveService,
        _leaderboardService = leaderboardService;

  final SaveService _saveService;
  final LeaderboardService _leaderboardService;

  // The current player, or null when no game is running.
  PlayerProfile? _profile;
  PlayerProfile? get profile => _profile;
  bool get hasActiveRun => _profile != null;

  // Which save slot the current run writes to.
  String? _activeSlotId;

  /// The one course (single academic track).
  Course get currentCourse => track;

  /// The most recent exam attempt, passed to the result screen.
  ExamAttempt? lastAttempt;

  // --- starting and loading a run --------------------------------------

  void startNewGame(String typedName) {
    _profile = PlayerProfile(name: _cleanName(typedName));
    _activeSlotId = 'slot_${DateTime.now().millisecondsSinceEpoch}';
    lastAttempt = null;
    notifyListeners();
  }

  void loadGame(SaveFile file) {
    _profile = file.profile;
    _activeSlotId = file.slotId;
    lastAttempt = null;
    notifyListeners();
  }

  /// Trims spaces and cuts the name down to the allowed length.
  String _cleanName(String typedName) {
    final String trimmed = typedName.trim();
    if (trimmed.length <= AppTheme.maxPlayerNameLength) return trimmed;
    return trimmed.substring(0, AppTheme.maxPlayerNameLength);
  }

  // --- progression ----------------------------------------------------

  /// Can the player start this exam stage yet?
  bool isStageUnlocked(ExamStage stage) {
    final PlayerProfile? profile = _profile;
    if (profile == null) return false;
    return profile.isStageUnlocked(currentCourse.id, stage);
  }

  /// Has the player already passed this exam stage?
  bool isStagePassed(ExamStage stage) {
    final PlayerProfile? profile = _profile;
    if (profile == null) return false;
    return profile.progressFor(currentCourse.id).isPassed(stage);
  }

  /// True once Prelim, Midterm, and Finals are all passed.
  bool get hasWon {
    final PlayerProfile? profile = _profile;
    if (profile == null) return false;
    return profile.isCourseComplete(currentCourse.id);
  }

  /// Records an exam attempt, updates EXP and level, then auto-saves if the
  /// player turned that on.
  Future<void> submitAttempt(ExamAttempt attempt) async {
    final PlayerProfile? profile = _profile;
    if (profile == null) return;

    profile.applyAttempt(attempt, passMark: AppTheme.examPassMark);
    lastAttempt = attempt;
    notifyListeners();

    if (_saveService.autoSaveEnabled) {
      await save();
    }
  }

  // --- saving -------------------------------------------------------

  Future<void> save() async {
    final PlayerProfile? profile = _profile;
    final String? slotId = _activeSlotId;
    if (profile == null || slotId == null) return;

    final SaveFile file = SaveFile(
      slotId: slotId,
      profile: profile,
      savedAt: DateTime.now(),
    );
    await _saveService.save(file);
    await _leaderboardService.submit(LeaderboardEntry.fromProfile(profile));
  }

  void endRun() {
    _profile = null;
    _activeSlotId = null;
    lastAttempt = null;
    notifyListeners();
  }
}
