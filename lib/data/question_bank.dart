import '../models/exam.dart';
import '../models/question.dart';
import 'courses.dart';
import 'questions_data.dart';

/// The exam for a stage. One shared question bank per stage — Prelim (10),
/// Midterm (15), Finals (20) — covering every module, difficulty rising
/// toward Finals. The full text lives in `questions_data.dart` and
/// `docs/quiz_bank.md`.
List<Question> questionsFor(ExamStage stage) => switch (stage) {
      ExamStage.prelim => prelimQuestions,
      ExamStage.midterm => midtermQuestions,
      ExamStage.finals => finalsQuestions,
    };

Exam examFor(ExamStage stage) => Exam(
      courseId: trackCourseId,
      stage: stage,
      questions: questionsFor(stage),
    );
