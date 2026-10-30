import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/puzzle_level.dart';

class PuzzleRepository {
  static List<PuzzleLevel> _levels = [];

  static Future<void> initialize() async {
    try {
      final jsonString = await rootBundle.loadString('assets/levels_with_bonus_words.json');
      final data = json.decode(jsonString);
      
      // Handle both formats: {"levels": [...]} or direct [...] list
      final List<dynamic> levelList = (data is Map) ? (data['levels'] ?? data['data'] ?? []) : (data is List ? data : []);
      
      _levels = levelList.map((json) => PuzzleLevel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading levels.json: $e');
    }
  }

  static int get totalLevels => _levels.isEmpty ? 1000 : _levels.length;

  static PuzzleLevel level(int number) {
    if (_levels.isNotEmpty) {
      final index = (number - 1).clamp(0, _levels.length - 1);
      return _levels[index];
    }
    // Fallback if accessed before initialization or empty
    return PuzzleLevel(
      number: number,
      theme: 'Level $number',
      wheelLetters: ['A', 'E', 'I', 'O', 'T'],
      answers: ['TALE', 'TIE', 'TOE', 'IOTAS'],
      bonusWords: ['APE', 'EAT', 'TEA'],
    );
  }

  static bool canMake(String word, List<String> wheelLetters) {
    final available = List<String>.from(wheelLetters);
    for (int i = 0; i < word.length; i++) {
      final char = word.toUpperCase()[i];
      if (available.contains(char)) {
        available.remove(char);
      } else {
        return false;
      }
    }
    return true;
  }

  // Strictly check if the word is valid for this level (either a main answer or a registered valid bonus word)
  static bool isKnownWord(String word, PuzzleLevel level) {
    if (word.length < 3) return false;
    final upperWord = word.toUpperCase();
    return level.answers.contains(upperWord) || level.bonusWords.contains(upperWord);
  }
}