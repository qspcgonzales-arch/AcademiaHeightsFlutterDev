import 'dart:math';

/// One multiple-choice exam question.
///
/// Every question bank (Prelim, Midterm, Finals) uses this exact shape so the
/// exam screen can show any of them the same way.
class Question {
  const Question({
    required this.prompt,
    required this.choices,
    required this.correctIndex,
    this.explanation,
  })  : assert(choices.length == 4, 'a question needs exactly 4 choices'),
        assert(
          correctIndex >= 0 && correctIndex < 4,
          'correctIndex must be 0 to 3',
        );

  /// The question text.
  final String prompt;

  /// Exactly four answer options, shown in this order.
  final List<String> choices;

  /// Position in [choices] of the right answer (0, 1, 2, or 3).
  final int correctIndex;

  /// Optional one-line reason, shown on the result screen.
  final String? explanation;

  /// True if [selectedIndex] is the right answer.
  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;

  /// Returns a copy of this question with the four choices put in a random
  /// order, so the right answer isn't always in the same spot. The exam
  /// screen calls this once per attempt.
  Question shuffledChoices(Random random) {
    // Start with the positions 0,1,2,3 and mix them up.
    final List<int> newOrder = [0, 1, 2, 3];
    newOrder.shuffle(random);

    // Build the reordered choices and find where the right answer moved to.
    final List<String> reordered = [];
    int newCorrectIndex = 0;
    for (int position = 0; position < newOrder.length; position++) {
      final int oldPosition = newOrder[position];
      reordered.add(choices[oldPosition]);
      if (oldPosition == correctIndex) {
        newCorrectIndex = position;
      }
    }

    return Question(
      prompt: prompt,
      choices: reordered,
      correctIndex: newCorrectIndex,
      explanation: explanation,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'prompt': prompt,
      'choices': choices,
      'correctIndex': correctIndex,
    };
    if (explanation != null) {
      json['explanation'] = explanation;
    }
    return json;
  }

  static Question fromJson(Map<String, dynamic> json) {
    return Question(
      prompt: json['prompt'] as String,
      choices: (json['choices'] as List<dynamic>).cast<String>(),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String?,
    );
  }
}
