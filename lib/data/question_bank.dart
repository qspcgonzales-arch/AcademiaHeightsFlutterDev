import '../models/exam.dart';
import '../models/question.dart';
import 'courses.dart';
import 'questions_data.dart';

/// The list of questions for one exam stage. One shared bank per stage —
/// Prelim (10), Midterm (15), Finals (20) — each covering every module. The
/// question text lives in `questions_data.dart` and `docs/quiz_bank.md`.
List<Question> questionsFor(ExamStage stage) {
  if (stage == ExamStage.prelim) return prelimQuestions;
  if (stage == ExamStage.midterm) return midtermQuestions;
  return finalsQuestions;
}

/// Builds the [Exam] for a stage.
Exam examFor(ExamStage stage) {
  return Exam(
    courseId: trackCourseId,
    stage: stage,
    questions: questionsFor(stage),
  );
}
