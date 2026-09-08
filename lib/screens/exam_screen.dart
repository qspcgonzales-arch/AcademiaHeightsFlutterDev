import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/question_bank.dart';
import '../models/exam.dart';
import '../models/question.dart';
import '../routes.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// Shows the exam one multiple-choice question at a time with a countdown
/// timer per question. The route argument is the [ExamStage] to run.
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  // "late" here means: not ready yet in the constructor, but set once in
  // didChangeDependencies() before anything reads them.
  late GameState _game;
  late Exam _exam;
  late int _secondsPerQuestion;

  int _questionIndex = 0;
  int _correctCount = 0;
  int _secondsLeft = 0;
  int? _selectedChoice; // null until the player taps an option
  Timer? _timer;
  bool _setUp = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only set things up once.
    if (_setUp) return;
    _setUp = true;

    _game = context.read<GameState>();

    final ExamStage stage =
        ModalRoute.of(context)!.settings.arguments as ExamStage;
    _exam = _withShuffledAnswers(examFor(stage));
    _secondsPerQuestion = secondsPerQuestionFor(stage);

    _startQuestionTimer();
  }

  /// Makes a copy of the exam with every question's four choices put in a
  /// random order. Question order stays as written.
  Exam _withShuffledAnswers(Exam exam) {
    final Random random = Random();

    final List<Question> shuffled = [];
    for (final Question question in exam.questions) {
      shuffled.add(question.shuffledChoices(random));
    }

    return Exam(
      courseId: exam.courseId,
      stage: exam.stage,
      questions: shuffled,
    );
  }

  void _startQuestionTimer() {
    _selectedChoice = null;
    _secondsLeft = _secondsPerQuestion;

    // "?." means "only if _timer isn't null".
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsLeft = _secondsLeft - 1;
      });
      if (_secondsLeft <= 0) {
        _submitAnswer();
      }
    });
  }

  /// Grades the current answer and moves on (or finishes the exam).
  void _submitAnswer() {
    _timer?.cancel();

    final Question question = _exam.questions[_questionIndex];
    if (_selectedChoice != null) {
      if (question.isCorrect(_selectedChoice!)) {
        _correctCount = _correctCount + 1;
      }
    }

    final bool wasLastQuestion =
        _questionIndex + 1 >= _exam.questions.length;
    if (wasLastQuestion) {
      _finishExam();
    } else {
      setState(() {
        _questionIndex = _questionIndex + 1;
      });
      _startQuestionTimer();
    }
  }

  Future<void> _finishExam() async {
    final ExamAttempt attempt = ExamAttempt(
      courseId: _exam.courseId,
      stage: _exam.stage,
      correct: _correctCount,
      total: _exam.questions.length,
      takenAt: DateTime.now(),
    );

    await _game.submitAttempt(attempt);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(Routes.examResult);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Question question = _exam.questions[_questionIndex];
    final int total = _exam.questions.length;
    final bool isLastQuestion = _questionIndex + 1 >= total;

    return PopScope(
      // Don't let the player back out of an exam in progress.
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${examStageLabel(_exam.stage)} Exam'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.gapL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Question ${_questionIndex + 1} of $total'),
                    Text('$_secondsLeft s'),
                  ],
                ),
                const SizedBox(height: AppTheme.gapS),
                LinearProgressIndicator(
                  value: _secondsLeft / _secondsPerQuestion,
                ),
                const SizedBox(height: AppTheme.gapL),
                Text(
                  question.prompt,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppTheme.gapL),
                for (int i = 0; i < question.choices.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.gapS),
                    child: RadioListTile<int>(
                      title: Text(question.choices[i]),
                      value: i,
                      groupValue: _selectedChoice,
                      onChanged: (value) {
                        setState(() {
                          _selectedChoice = value;
                        });
                      },
                    ),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed:
                      _selectedChoice == null ? null : _submitAnswer,
                  child: Text(isLastQuestion ? 'Finish' : 'Next question'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
