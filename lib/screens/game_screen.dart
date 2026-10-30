import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/puzzle_level.dart';
import '../services/progress_service.dart';
import '../services/puzzle_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/letter_wheel.dart';
import '../widgets/word_slots.dart';

class GameScreen extends StatefulWidget {
  final int levelNumber;
  const GameScreen({super.key, required this.levelNumber});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late PuzzleLevel level;
  late List<String> letters;
  final Set<String> found = {};
  final Set<String> bonusWords = {};
  String feedback = '';
  bool isError = false;
  int gems = 250;
  late ConfettiController confetti;

  @override
  void initState() {
    super.initState();
    level = PuzzleRepository.level(widget.levelNumber);
    letters = List.of(level.wheelLetters);
    confetti = ConfettiController(duration: const Duration(seconds: 2));
    ProgressService.gems().then((v) { if (mounted) setState(() => gems = v); });
  }

  @override
  void dispose() { confetti.dispose(); super.dispose(); }

  Future<void> _submitWord(String word) async {
    if (word.length < 3) {
      setState(() { feedback = 'Try a word with at least 3 letters'; isError = true; });
      return;
    }
    if (found.contains(word) || bonusWords.contains(word)) {
      setState(() { feedback = 'You already found $word'; isError = true; });
      return;
    }
    // Verify word can be constructed and is an official answer or valid bonus word
    if (!PuzzleRepository.canMake(word, letters) || !PuzzleRepository.isKnownWord(word, level)) {
      setState(() { feedback = 'Not a valid word for this wheel'; isError = true; });
      return;
    }

    if (level.answers.contains(word)) {
      setState(() { found.add(word); feedback = 'Beautiful! $word fits the puzzle.'; isError = false; });
      if (found.length == level.answers.length) await _completeLevel();
    } else if (level.bonusWords.contains(word)) {
      setState(() { bonusWords.add(word); feedback = 'Bonus word! $word (+5 Gems)'; isError = false; });
      await ProgressService.addBonus();
      await ProgressService.addGems(5);
      if (mounted) setState(() => gems += 5);
    } else {
      setState(() { feedback = 'Not a valid word for this wheel'; isError = true; });
    }
  }

  Future<void> _completeLevel() async {
    confetti.play();
    await ProgressService.addGems(25 + (level.number ~/ 25));
    final next = min(1000, level.number + 1);
    final saved = await ProgressService.currentLevel();
    if (next > saved) await ProgressService.saveLevel(next);
    if (!mounted) return;
    setState(() => gems += 25 + (level.number ~/ 25));
    
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFFFF9EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.emoji_events_rounded, color: Color(0xFFE7AF38), size: 60),
          const SizedBox(height: 8),
          const Text('Trail complete!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.ink)),
          const SizedBox(height: 8),
          Text('Level ${level.number} is complete. You earned ${25 + (level.number ~/ 25)} gems.',
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (level.number < 1000) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameScreen(levelNumber: level.number + 1)));
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(level.number < 1000 ? 'NEXT LEVEL' : 'FINISH ADVENTURE'),
          )),
          TextButton(onPressed: () { Navigator.pop(dialogContext); Navigator.pop(context); }, child: const Text('Back to map')),
        ]),
      ),
    );
  }

  Future<void> _hint() async {
    if (found.length == level.answers.length) return;
    final missingAnswers = level.answers.where((w) => !found.contains(w)).toList();
    if (missingAnswers.isEmpty) return;

    if (await ProgressService.spendGems(30)) {
      final targetWord = missingAnswers.first;
      setState(() {
        found.add(targetWord);
        gems -= 30;
        feedback = 'Hint used: Revealed "$targetWord"!';
        isError = false;
      });
      if (found.length == level.answers.length) {
        await _completeLevel();
      }
    } else {
      if (mounted) {
        setState(() { feedback = 'You need 30 gems for a hint.'; isError = true; });
      }
    }
  }

  void _shuffle() {
    setState(() {
      letters.shuffle(Random());
      feedback = 'Letters shuffled';
      isError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('LEVEL ${level.number.toString().padLeft(3, '0')}', style: const TextStyle(fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.w900)),
          Text(level.theme, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70)),
        ]),
        actions: [
          Container(margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(24)),
            child: Row(children: [const Icon(Icons.diamond, color: AppTheme.gold, size: 18), const SizedBox(width: 5), Text('$gems', style: const TextStyle(fontWeight: FontWeight.w900))])),
        ],
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFF8E9), Color(0xFFF0F3E6)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SafeArea(child: Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 5), child: Row(children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: found.length / level.answers.length, minHeight: 7, backgroundColor: const Color(0xFFE0DDCF), color: AppTheme.leaf))),
              const SizedBox(width: 10),
              Text('${found.length}/${level.answers.length}', style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w900)),
            ])),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .7), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE9E1CE))),
              child: Column(children: [
                Text(feedback.isEmpty ? 'Swipe letters to find words' : feedback,
                  textAlign: TextAlign.center, style: TextStyle(color: isError ? Colors.redAccent : AppTheme.leaf, fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
            ),
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 8),
              child: Column(children: [
                WordSlots(answers: level.answers, found: found),
                if (bonusWords.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 6, runSpacing: 6, children: bonusWords.map((w) => Chip(
                    avatar: const Icon(Icons.star, size: 15, color: Color(0xFFB17B16)),
                    label: Text(w), backgroundColor: const Color(0xFFFFE8A8), visualDensity: VisualDensity.compact,
                  )).toList()),
                ],
              ]),
            )),
            Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _tool(Icons.lightbulb_outline, 'Hint', '30', _hint),
              _tool(Icons.shuffle_rounded, 'Shuffle', 'FREE', _shuffle),
            ])),
            Padding(padding: const EdgeInsets.fromLTRB(10, 0, 10, 12), child: LetterWheel(
              letters: letters,
              selectedCount: 0,
              onWordSubmitted: _submitWord,
              onShuffle: _shuffle,
            )),
          ])),
        ),
        Align(alignment: Alignment.topCenter, child: ConfettiWidget(
          confettiController: confetti, blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false, numberOfParticles: 25, maxBlastForce: 18, minBlastForce: 7,
        )),
      ]),
    );
  }

  Widget _tool(IconData icon, String label, String cost, VoidCallback action) => InkWell(
    onTap: action, borderRadius: BorderRadius.circular(14),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6), child: Column(children: [
      Container(width: 43, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFE2DDCF))),
        child: Icon(icon, color: AppTheme.forest, size: 21)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: AppTheme.ink, fontSize: 10, fontWeight: FontWeight.w800)),
      if (cost.isNotEmpty) Text(cost, style: const TextStyle(color: Colors.black45, fontSize: 9)),
    ])),
  );
}