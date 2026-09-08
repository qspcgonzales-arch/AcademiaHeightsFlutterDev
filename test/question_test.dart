import 'dart:math';

import 'package:academia_heights/models/question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Question question = Question(
    prompt: 'Which language does Flutter use?',
    choices: ['Java', 'Dart', 'Swift', 'Kotlin'],
    correctIndex: 1,
    explanation: 'Flutter apps are written in Dart.',
  );

  group('shuffledChoices', () {
    test('keeps the same four choices', () {
      final Question shuffled = question.shuffledChoices(Random(1));

      expect(shuffled.choices.length, 4);
      for (final String choice in question.choices) {
        expect(shuffled.choices.contains(choice), isTrue);
      }
    });

    test('correctIndex still points at the right answer, for many shuffles',
        () {
      for (int seed = 0; seed < 50; seed++) {
        final Question shuffled = question.shuffledChoices(Random(seed));
        final String answerText = shuffled.choices[shuffled.correctIndex];

        expect(answerText, 'Dart', reason: 'seed $seed lost the answer');
        expect(shuffled.isCorrect(shuffled.correctIndex), isTrue);
      }
    });

    test('keeps the prompt and explanation', () {
      final Question shuffled = question.shuffledChoices(Random(7));

      expect(shuffled.prompt, question.prompt);
      expect(shuffled.explanation, question.explanation);
    });

    test('actually changes the order for at least one seed', () {
      bool foundADifferentOrder = false;

      for (int seed = 0; seed < 20; seed++) {
        final Question shuffled = question.shuffledChoices(Random(seed));
        if (!_sameOrder(shuffled.choices, question.choices)) {
          foundADifferentOrder = true;
        }
      }

      expect(foundADifferentOrder, isTrue);
    });
  });
}

/// True if the two lists hold the same strings in the same positions.
bool _sameOrder(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
