import 'package:flutter_test/flutter_test.dart';
import 'package:words_of_wonder_adventure/services/puzzle_repository.dart';

void main() {
  test('repository exposes 1000 numbered levels', () {
    expect(PuzzleRepository.all.length, 1000);
    expect(PuzzleRepository.level(1).number, 1);
    expect(PuzzleRepository.level(1000).number, 1000);
  });

  test('every answer can be formed from its level letter pool', () {
    for (final level in PuzzleRepository.all) {
      for (final answer in level.answers) {
        expect(PuzzleRepository.canMake(answer, level.wheelLetters), isTrue,
            reason: 'Level ${level.number}: $answer');
      }
    }
  });
}
