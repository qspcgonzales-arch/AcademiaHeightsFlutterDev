import 'package:academia_heights/models/exam.dart';
import 'package:academia_heights/models/player_profile.dart';
import 'package:flutter_test/flutter_test.dart';

ExamAttempt _attempt(
  String courseId,
  ExamStage stage, {
  required int correct,
  int total = 10,
}) {
  return ExamAttempt(
    courseId: courseId,
    stage: stage,
    correct: correct,
    total: total,
    takenAt: DateTime(2026, 1, 1),
  );
}

void main() {
  const passMark = 0.6;

  group('exam gating', () {
    test('prelim is always unlocked; midterm/finals are not', () {
      final profile = PlayerProfile(name: 'Ada');
      expect(profile.isStageUnlocked('c1', ExamStage.prelim), isTrue);
      expect(profile.isStageUnlocked('c1', ExamStage.midterm), isFalse);
      expect(profile.isStageUnlocked('c1', ExamStage.finals), isFalse);
    });

    test('passing prelim unlocks midterm but not finals', () {
      final profile = PlayerProfile(name: 'Ada');
      profile.applyAttempt(
        _attempt('c1', ExamStage.prelim, correct: 8),
        passMark: passMark,
      );
      expect(profile.isStageUnlocked('c1', ExamStage.midterm), isTrue);
      expect(profile.isStageUnlocked('c1', ExamStage.finals), isFalse);
    });

    test('failing prelim does not unlock midterm', () {
      final profile = PlayerProfile(name: 'Ada');
      profile.applyAttempt(
        _attempt('c1', ExamStage.prelim, correct: 3),
        passMark: passMark,
      );
      expect(profile.isStageUnlocked('c1', ExamStage.midterm), isFalse);
    });
  });

  group('scoring and profile stats', () {
    test('course is complete only after all three stages pass', () {
      final profile = PlayerProfile(name: 'Ada');
      for (final stage in ExamStage.values) {
        expect(profile.isCourseComplete('c1'), isFalse);
        profile.applyAttempt(
          _attempt('c1', stage, correct: 9),
          passMark: passMark,
        );
      }
      expect(profile.isCourseComplete('c1'), isTrue);
    });

    test('best score per stage is kept', () {
      final profile = PlayerProfile(name: 'Ada');
      profile.applyAttempt(
        _attempt('c1', ExamStage.prelim, correct: 4),
        passMark: passMark,
      );
      profile.applyAttempt(
        _attempt('c1', ExamStage.prelim, correct: 7),
        passMark: passMark,
      );
      profile.applyAttempt(
        _attempt('c1', ExamStage.prelim, correct: 5),
        passMark: passMark,
      );
      expect(
        profile.progressFor('c1').bestAt(ExamStage.prelim)!.percent,
        70,
      );
      expect(profile.quizzesTaken, 3);
    });

    test('EXP accrues and level rises every 100 EXP', () {
      final profile = PlayerProfile(name: 'Ada');
      expect(profile.level, 1);
      // 10 correct * 10 EXP = 100 -> level 2.
      profile.applyAttempt(
        _attempt('c1', ExamStage.prelim, correct: 10),
        passMark: passMark,
      );
      expect(profile.exp, 100);
      expect(profile.level, 2);
    });

    test('averagePercent averages the best score of each stage', () {
      final profile = PlayerProfile(name: 'Ada')
        ..applyAttempt(
          _attempt('c1', ExamStage.prelim, correct: 8),
          passMark: passMark,
        )
        ..applyAttempt(
          _attempt('c1', ExamStage.midterm, correct: 6),
          passMark: passMark,
        );
      expect(profile.averagePercent, 70);
    });
  });

  group('serialization', () {
    test('profile survives a JSON round trip', () {
      final profile = PlayerProfile(name: 'Ada')
        ..applyAttempt(
          _attempt('c1', ExamStage.prelim, correct: 9),
          passMark: passMark,
        );
      final restored = PlayerProfile.fromJson(profile.toJson());
      expect(restored.name, 'Ada');
      expect(restored.exp, profile.exp);
      expect(restored.isStageUnlocked('c1', ExamStage.midterm), isTrue);
      expect(
        restored.progressFor('c1').bestAt(ExamStage.prelim)!.percent,
        90,
      );
    });
  });

  group('ExamStage', () {
    test('prerequisite chain is prelim <- midterm <- finals', () {
      expect(ExamStage.prelim.prerequisite, isNull);
      expect(ExamStage.midterm.prerequisite, ExamStage.prelim);
      expect(ExamStage.finals.prerequisite, ExamStage.midterm);
    });

    test('time pressure increases each stage', () {
      expect(
        ExamStage.prelim.secondsPerQuestion >
            ExamStage.midterm.secondsPerQuestion,
        isTrue,
      );
      expect(
        ExamStage.midterm.secondsPerQuestion >
            ExamStage.finals.secondsPerQuestion,
        isTrue,
      );
    });
  });
}
