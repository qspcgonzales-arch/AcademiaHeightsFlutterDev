import '../models/exam.dart';
import '../models/question.dart';

/// Static question banks, keyed by course id then [ExamStage].
///
/// TODO(quiz content — Gonzales): flesh every bank out to ~10 questions per
/// stage, with difficulty rising Prelim -> Finals. The placeholder entries
/// below keep the exam screen working in the meantime. Keep every entry in
/// the [Question] shape (4 choices, one correctIndex).
const Map<String, Map<ExamStage, List<Question>>> _banks = {
  'flutter_intro': {
    ExamStage.prelim: [
      Question(
        prompt: 'What language do you write Flutter apps in?',
        choices: ['Kotlin', 'Dart', 'Swift', 'JavaScript'],
        correctIndex: 1,
      ),
      Question(
        prompt: 'Which command creates a new Flutter project?',
        choices: [
          'flutter init',
          'flutter new',
          'flutter create',
          'flutter start',
        ],
        correctIndex: 2,
      ),
      Question(
        prompt: 'In Flutter, almost everything on screen is a…',
        choices: ['Widget', 'Fragment', 'Activity', 'Scene'],
        correctIndex: 0,
      ),
    ],
    ExamStage.midterm: [
      Question(
        prompt: 'Which widget rebuilds when its internal state changes?',
        choices: [
          'StatelessWidget',
          'StatefulWidget',
          'InheritedWidget',
          'ConstWidget',
        ],
        correctIndex: 1,
      ),
      Question(
        prompt: 'What does `flutter pub get` do?',
        choices: [
          'Runs the app',
          'Downloads the packages in pubspec.yaml',
          'Formats the code',
          'Builds a release APK',
        ],
        correctIndex: 1,
      ),
    ],
    ExamStage.finals: [
      Question(
        prompt: 'Which file lists a Flutter project\'s dependencies?',
        choices: [
          'pubspec.yaml',
          'AndroidManifest.xml',
          'analysis_options.yaml',
          'main.dart',
        ],
        correctIndex: 0,
      ),
    ],
  },
};

/// Single placeholder used for any (course, stage) not yet written.
const Question _placeholder = Question(
  prompt: 'Placeholder question — quiz content still to be written.',
  choices: ['Option A', 'Option B (correct)', 'Option C', 'Option D'],
  correctIndex: 1,
  explanation: 'Replace this bank in lib/data/question_bank.dart.',
);

/// Returns the question bank for a course stage, or a one-item placeholder
/// bank if it has not been authored yet. Never returns an empty list.
List<Question> questionsFor(String courseId, ExamStage stage) {
  final bank = _banks[courseId]?[stage];
  if (bank == null || bank.isEmpty) return const [_placeholder];
  return bank;
}

Exam examFor(String courseId, ExamStage stage) => Exam(
      courseId: courseId,
      stage: stage,
      questions: questionsFor(courseId, stage),
    );
