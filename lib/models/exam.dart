import 'question.dart';

/// The three exams, in the order they must be taken.
enum ExamStage { prelim, midterm, finals }

/// The name shown to the player for a stage.
String examStageLabel(ExamStage stage) {
  if (stage == ExamStage.prelim) return 'Prelim';
  if (stage == ExamStage.midterm) return 'Midterm';
  return 'Finals';
}

/// The stage that must be passed before [stage] can be taken.
/// Returns null for Prelim, which is open from the start.
ExamStage? prerequisiteOf(ExamStage stage) {
  if (stage == ExamStage.midterm) return ExamStage.prelim;
  if (stage == ExamStage.finals) return ExamStage.midterm;
  return null;
}

/// Seconds allowed per question. Less time as the exams get harder.
int secondsPerQuestionFor(ExamStage stage) {
  if (stage == ExamStage.prelim) return 30;
  if (stage == ExamStage.midterm) return 25;
  return 20;
}

/// A definition of one exam: its stage and its list of questions.
class Exam {
  const Exam({
    required this.courseId,
    required this.stage,
    required this.questions,
  });

  final String courseId;
  final ExamStage stage;
  final List<Question> questions;

  int get questionCount => questions.length;
}

/// The result of one attempt at an exam. Made by the exam screen, then read
/// by the result screen and by [PlayerProfile].
class ExamAttempt {
  const ExamAttempt({
    required this.courseId,
    required this.stage,
    required this.correct,
    required this.total,
    required this.takenAt,
  });

  final String courseId;
  final ExamStage stage;
  final int correct;
  final int total;
  final DateTime takenAt;

  /// Score as a fraction from 0.0 to 1.0.
  double get score {
    if (total == 0) return 0;
    return correct / total;
  }

  /// Score as a whole-number percentage (0 to 100).
  int get percent => (score * 100).round();

  /// True if this attempt reached [passMark] (a fraction, e.g. 0.6).
  bool passed(double passMark) => score >= passMark;

  /// EXP awarded for this attempt: 10 per correct answer.
  int get expEarned => correct * 10;

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'stage': stage.name,
      'correct': correct,
      'total': total,
      'takenAt': takenAt.toIso8601String(),
    };
  }

  static ExamAttempt fromJson(Map<String, dynamic> json) {
    return ExamAttempt(
      courseId: json['courseId'] as String,
      stage: ExamStage.values.byName(json['stage'] as String),
      correct: json['correct'] as int,
      total: json['total'] as int,
      takenAt: DateTime.parse(json['takenAt'] as String),
    );
  }
}
