import 'question.dart';

/// The three exams every course has, in the order they must be taken.
enum ExamStage {
  prelim('Prelim'),
  midterm('Midterm'),
  finals('Finals');

  const ExamStage(this.label);

  final String label;

  /// The stage that must be passed before this one unlocks, or `null` for
  /// [ExamStage.prelim].
  ExamStage? get prerequisite => switch (this) {
        ExamStage.prelim => null,
        ExamStage.midterm => ExamStage.prelim,
        ExamStage.finals => ExamStage.midterm,
      };

  /// Seconds allowed per question. Difficulty rises Prelim -> Finals.
  int get secondsPerQuestion => switch (this) {
        ExamStage.prelim => 30,
        ExamStage.midterm => 25,
        ExamStage.finals => 20,
      };
}

/// A definition of one exam: its stage and its question bank.
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

/// The outcome of one attempt at an exam. Immutable; produced by the exam
/// screen and consumed by the result screen and [PlayerProfile].
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

  double get score => total == 0 ? 0 : correct / total;

  int get percent => (score * 100).round();

  bool passedAt(double passMark) => score >= passMark;

  /// EXP awarded for this attempt (simple linear model; tune later).
  int get expEarned => correct * 10;

  Map<String, dynamic> toJson() => {
        'courseId': courseId,
        'stage': stage.name,
        'correct': correct,
        'total': total,
        'takenAt': takenAt.toIso8601String(),
      };

  factory ExamAttempt.fromJson(Map<String, dynamic> json) => ExamAttempt(
        courseId: json['courseId'] as String,
        stage: ExamStage.values.byName(json['stage'] as String),
        correct: json['correct'] as int,
        total: json['total'] as int,
        takenAt: DateTime.parse(json['takenAt'] as String),
      );
}
