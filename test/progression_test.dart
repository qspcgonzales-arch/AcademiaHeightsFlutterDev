import 'package:academia_heights/models/exam.dart';
import 'package:academia_heights/models/player_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// Makes a test exam attempt. Defaults to a 10-question exam.
ExamAttempt makeAttempt(
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
  const double passMark = 0.6;

  group('exam gating', () {
    test('prelim is always unlocked; midterm and finals are not', () {
      final PlayerProfile profile = PlayerProfile(name: 'Ada');

      expect(profile.isStageUnlocked('c1', ExamStage.prelim), isTrue);
      expect(profile.isStageUnlocked('c1', ExamStage.midterm), isFalse);
      expect(profile.isStageUnlocked('c1', ExamStage.finals), isFalse);
    });

    test('passing prelim unlocks midterm but not finals', () {
      final PlayerProfile profile = PlayerProfile(name: 'Ada');
      profile.applyAttempt(
        makeAttempt('c1', ExamStage.prelim, correct: 8),
        passMark: passMark,
      );

      expect(profile.isStageUnlocked('c1', ExamStage.midterm), isTrue);
      expect(profile.isStageUnlocked('c1', ExamStage.finals), isFalse);
    });

    test('failing prelim does not unlock midterm', () {
      final PlayerProfile profile = PlayerProfile(name: 'Ada');
      profile.applyAttempt(
        makeAttempt('c1', ExamStage.prelim, correct: 3),
        passMark: passMark,
      );

      expect(profile.isStageUnlocked('c1', ExamStage.midterm), isFalse);
    });
  });

  group('scoring and profile stats', () {
    test('course is complete only after all three stages pass', () {
      final PlayerProfile profile = PlayerProfile(name: 'Ada');

      for (final ExamStage stage in ExamStage.values) {
        expect(profile.isCourseComplete('c1'), isFalse);
        profile.applyAttempt(
          makeAttempt('c1', stage, correct: 9),
          passMark: passMark,
        );
      }

      expect(profile.isCourseComplete('c1'), isTrue);
    });

    test('the best score for a stage is kept', () {
      final PlayerProfile profile = PlayerProfile(name: 'Ada');
      profile.applyAttempt(
        makeAttempt('c1', ExamStage.prelim, correct: 4),
        passMark: passMark,
      );
      profile.applyAttempt(
        makeAttempt('c1', ExamStage.prelim, correct: 7),
        passMark: passMark,
      );
      profile.applyAttempt(
        makeAttempt('c1', ExamStage.prelim, correct: 5),
        passMark: passMark,
      );

      final ExamAttempt? best =
          profile.progressFor('c1').bestAt(ExamStage.prelim);
      expect(best!.percent, 70);
      expect(profile.quizzesTaken, 3);
    });

    test('EXP adds up and the level rises every 100 EXP', () {
      final PlayerProfile profile = PlayerProfile(name: 'Ada');
      expect(profile.level, 1);

      // 10 correct * 10 EXP each = 100 EXP, which is level 2.
      profile.applyAttempt(
        makeAttempt('c1', ExamStage.prelim, correct: 10),
        passMark: passMark,
      );

      expect(profile.exp, 100);
      expect(profile.level, 2);
    });

    test('averagePercent averages the best score of each stage', () {
      final PlayerProfile profile = PlayerProfile(name: 'Ada');
      profile.applyAttempt(
        makeAttempt('c1', ExamStage.prelim, correct: 8),
        passMark: passMark,
      );
      profile.applyAttempt(
        makeAttempt('c1', ExamStage.midterm, correct: 6),
        passMark: passMark,
      );

      // (80 + 60) / 2 = 70
      expect(profile.averagePercent, 70);
    });
  });

  group('saving and loading', () {
    test('a profile survives being turned into JSON and back', () {
      final PlayerProfile profile = PlayerProfile(name: 'Ada');
      profile.applyAttempt(
        makeAttempt('c1', ExamStage.prelim, correct: 9),
        passMark: passMark,
      );

      final PlayerProfile restored =
          PlayerProfile.fromJson(profile.toJson());

      expect(restored.name, 'Ada');
      expect(restored.exp, profile.exp);
      expect(restored.isStageUnlocked('c1', ExamStage.midterm), isTrue);

      final ExamAttempt? best =
          restored.progressFor('c1').bestAt(ExamStage.prelim);
      expect(best!.percent, 90);
    });
  });

  group('exam stage helpers', () {
    test('the prerequisite chain is prelim -> midterm -> finals', () {
      expect(prerequisiteOf(ExamStage.prelim), isNull);
      expect(prerequisiteOf(ExamStage.midterm), ExamStage.prelim);
      expect(prerequisiteOf(ExamStage.finals), ExamStage.midterm);
    });

    test('there is less time per question as the exams get harder', () {
      final int prelimTime = secondsPerQuestionFor(ExamStage.prelim);
      final int midtermTime = secondsPerQuestionFor(ExamStage.midterm);
      final int finalsTime = secondsPerQuestionFor(ExamStage.finals);

      expect(prelimTime > midtermTime, isTrue);
      expect(midtermTime > finalsTime, isTrue);
    });
  });
}
