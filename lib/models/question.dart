import 'dart:math';

/// One multiple-choice exam question.
///
/// Every question bank — Prelim, Midterm, Finals — uses this exact shape so
/// the exam screen can render any of them the same way.
class Question {
  const Question({
    required this.prompt,
    required this.choices,
    required this.correctIndex,
    this.explanation,
  })  : assert(choices.length == 4, 'a question needs exactly 4 choices'),
        assert(
          correctIndex >= 0 && correctIndex < 4,
          'correctIndex must be 0-3',
        );

  final String prompt;

  /// Exactly four options. Index order is the display order.
  final List<String> choices;

  /// Index into [choices] of the correct answer (0-3).
  final int correctIndex;

  /// Optional one-line rationale shown on the result screen.
  final String? explanation;

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;

  /// A copy with the choices reordered by [random] and [correctIndex] moved
  /// to wherever the right answer landed. The exam screen calls this per
  /// attempt so the correct option isn't always in the same slot.
  Question shuffledChoices(Random random) {
    final order = List<int>.generate(choices.length, (i) => i)
      ..shuffle(random);
    return Question(
      prompt: prompt,
      choices: [for (final i in order) choices[i]],
      correctIndex: order.indexOf(correctIndex),
      explanation: explanation,
    );
  }

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        'choices': choices,
        'correctIndex': correctIndex,
        if (explanation != null) 'explanation': explanation,
      };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        prompt: json['prompt'] as String,
        choices: (json['choices'] as List<dynamic>).cast<String>(),
        correctIndex: json['correctIndex'] as int,
        explanation: json['explanation'] as String?,
      );
}
