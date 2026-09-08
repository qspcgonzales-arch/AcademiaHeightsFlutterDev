import 'dart:math';

import 'package:academia_heights/models/question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const question = Question(
    prompt: 'Which language does Flutter use?',
    choices: ['Java', 'Dart', 'Swift', 'Kotlin'],
    correctIndex: 1,
    explanation: 'Flutter apps are written in Dart.',
  );

  group('shuffledChoices', () {
    test('keeps the same set of choices', () {
      final shuffled = question.shuffledChoices(Random(1));
      expect(shuffled.choices.toSet(), question.choices.toSet());
      expect(shuffled.choices.length, 4);
    });

    test('correctIndex still points at the right answer', () {
      for (var seed = 0; seed < 50; seed++) {
        final shuffled = question.shuffledChoices(Random(seed));
        expect(
          shuffled.choices[shuffled.correctIndex],
          'Dart',
          reason: 'seed $seed moved the correct answer',
        );
        expect(shuffled.isCorrect(shuffled.correctIndex), isTrue);
      }
    });

    test('carries the prompt and explanation through unchanged', () {
      final shuffled = question.shuffledChoices(Random(7));
      expect(shuffled.prompt, question.prompt);
      expect(shuffled.explanation, question.explanation);
    });

    test('actually changes the order for at least one seed', () {
      final anyReordered = List.generate(20, (s) => s).any((seed) {
        final shuffled = question.shuffledChoices(Random(seed));
        return !_sameOrder(shuffled.choices, question.choices);
      });
      expect(anyReordered, isTrue);
    });
  });
}

bool _sameOrder(List<String> a, List<String> b) {
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
