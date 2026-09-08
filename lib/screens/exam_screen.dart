import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/question_bank.dart';
import '../models/exam.dart';
import '../models/question.dart';
import '../routes.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// One multiple-choice question at a time, with a per-question countdown.
/// Expects an [ExamStage] as the route argument.
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late final GameState _game;
  late final Exam _exam;
  late final int _perQuestionSeconds;

  int _index = 0;
  int _correct = 0;
  int _secondsLeft = 0;
  int? _selected;
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    _game = context.read<GameState>();
    final stage = ModalRoute.of(context)!.settings.arguments as ExamStage;
    _exam = examFor(stage);
    _perQuestionSeconds = stage.secondsPerQuestion;
    _beginQuestion();
  }

  void _beginQuestion() {
    _selected = null;
    _secondsLeft = _perQuestionSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) _lockIn();
    });
  }

  void _lockIn() {
    _timer?.cancel();
    final question = _exam.questions[_index];
    if (_selected != null && question.isCorrect(_selected!)) _correct++;

    if (_index + 1 >= _exam.questions.length) {
      _finish();
    } else {
      setState(() => _index++);
      _beginQuestion();
    }
  }

  Future<void> _finish() async {
    final attempt = ExamAttempt(
      courseId: _exam.courseId,
      stage: _exam.stage,
      correct: _correct,
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
    final Question question = _exam.questions[_index];
    final total = _exam.questions.length;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_exam.stage.label} Exam'),
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
                    Text('Question ${_index + 1} of $total'),
                    Text('$_secondsLeft s'),
                  ],
                ),
                const SizedBox(height: AppTheme.gapS),
                LinearProgressIndicator(
                  value: _secondsLeft / _perQuestionSeconds,
                ),
                const SizedBox(height: AppTheme.gapL),
                Text(
                  question.prompt,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppTheme.gapL),
                for (var i = 0; i < question.choices.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.gapS),
                    child: RadioListTile<int>(
                      title: Text(question.choices[i]),
                      value: i,
                      groupValue: _selected,
                      onChanged: (value) => setState(() => _selected = value),
                    ),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _selected == null ? null : _lockIn,
                  child: Text(
                    _index + 1 >= total ? 'Finish' : 'Next question',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
