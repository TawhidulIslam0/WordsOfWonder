class PuzzleLevel {
  final int number;
  final String theme;
  final List<String> wheelLetters;
  final List<String> answers;
  final List<String> bonusWords;

  PuzzleLevel({
    required this.number,
    required this.theme,
    required this.wheelLetters,
    required this.answers,
    this.bonusWords = const [],
  });

  factory PuzzleLevel.fromJson(Map<String, dynamic> json) {
    return PuzzleLevel(
      number: json['number'] ?? 1,
      theme: json['theme'] ?? '',
      wheelLetters: List<String>.from(json['letters'] ?? json['wheelLetters'] ?? []),
      answers: List<String>.from(json['answers'] ?? []),
      bonusWords: List<String>.from(json['bonusWords'] ?? json['bonus_words'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'theme': theme,
        'wheelLetters': wheelLetters,
        'answers': answers,
        'bonusWords': bonusWords,
      };
}