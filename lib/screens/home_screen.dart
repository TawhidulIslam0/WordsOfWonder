import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../services/puzzle_repository.dart';
import '../theme/app_theme.dart';
import 'level_map_screen.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int level = 1;
  int gems = 250;
  int bonus = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final values = await Future.wait([
      ProgressService.currentLevel(), ProgressService.gems(), ProgressService.bonusCount()
    ]);
    if (!mounted) return;
    setState(() {
      level = values[0] as int;
      gems = values[1] as int;
      bonus = values[2] as int;
    });
  }

  Future<void> _confirmReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF9EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hard Reset Game?', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.ink)),
        content: const Text('This will reset your progress back to Level 1 and wipe all saved gems and bonus words.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ProgressService.reset();
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF164C3B), Color(0xFF286B4D), Color(0xFFFFF6E3)],
            stops: [0, .48, .48]),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  Row(children: [
                    const Icon(Icons.auto_awesome, color: AppTheme.gold, size: 28),
                    const SizedBox(width: 9),
                    const Text('WORDBOUND', style: TextStyle(color: Colors.white, letterSpacing: 3, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    _pill(Icons.diamond, '$gems'),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _confirmReset,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                        child: const Icon(Icons.refresh, color: Colors.white, size: 18),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 38),
                  const Text('A world of words,', style: TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w800, height: 1.1)),
                  const Text('one letter at a time.', style: TextStyle(color: AppTheme.gold, fontSize: 31, fontWeight: FontWeight.w800, height: 1.1)),
                  const SizedBox(height: 14),
                  Text('Stretch your vocabulary. Discover new words. Explore 1,000 levels.',
                    style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: 15, height: 1.5)),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(color: const Color(0xFFFFF9EC), borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .12), blurRadius: 24, offset: const Offset(0, 12))]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFFE5F1E7), borderRadius: BorderRadius.circular(17)),
                          child: const Icon(Icons.explore, color: AppTheme.forest, size: 29)),
                        const SizedBox(width: 13),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('YOUR JOURNEY', style: TextStyle(fontSize: 11, letterSpacing: 1.6, color: AppTheme.leaf, fontWeight: FontWeight.w900)),
                          Text('Level $level of ${PuzzleRepository.totalLevels}', style: const TextStyle(fontSize: 20, color: AppTheme.ink, fontWeight: FontWeight.w800)),
                        ])),
                      ]),
                      const SizedBox(height: 20),
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(
                        value: level / PuzzleRepository.totalLevels, minHeight: 8,
                        backgroundColor: const Color(0xFFE4E0D3), color: AppTheme.leaf)),
                      const SizedBox(height: 21),
                      SizedBox(width: double.infinity, child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(levelNumber: level)));
                          _load();
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 25),
                        label: Text(level == 1 ? 'START ADVENTURE' : 'CONTINUE JOURNEY'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                      )),
                      const SizedBox(height: 10),
                      SizedBox(width: double.infinity, child: OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelMapScreen()));
                          _load();
                        },
                        icon: const Icon(Icons.map_outlined), label: const Text('EXPLORE LEVELS'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.forest, side: const BorderSide(color: Color(0xFFD7D4C5), width: 1.5),
                          minimumSize: const Size.fromHeight(50), shape: const StadiumBorder()),
                      )),
                    ]),
                  ),
                  const SizedBox(height: 22),
                  Row(children: [
                    Expanded(child: _statCard(Icons.diamond_outlined, '$gems', 'Gems')),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard(Icons.auto_awesome, '$bonus', 'Bonus words')),
                  ]),
                  const SizedBox(height: 25),
                  const Text('HOW TO PLAY', style: TextStyle(color: AppTheme.ink, letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 12)),
                  const SizedBox(height: 12),
                  _how(Icons.gesture, 'Connect letters', 'Swipe or tap letters to spell a word.'),
                  _how(Icons.grid_view_rounded, 'Fill the crossword', 'Find every hidden answer to finish a level.'),
                  _how(Icons.lightbulb_outline, 'Learn as you go', 'Discover bonus words and use hints wisely.'),
                  const SizedBox(height: 22),
                  Center(child: Text('A little word magic, every day ✦', style: TextStyle(color: AppTheme.ink.withValues(alpha: .65), fontWeight: FontWeight.w700))),
                ])),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white24)),
    child: Row(children: [Icon(icon, color: AppTheme.gold, size: 18), const SizedBox(width: 6), Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))]),
  );

  Widget _statCard(IconData icon, String value, String label) => Container(
    padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 12, offset: const Offset(0, 5))]),
    child: Row(children: [Icon(icon, color: AppTheme.leaf, size: 25), const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(color: AppTheme.ink, fontSize: 21, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ]))]),
  );

  Widget _how(IconData icon, String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFE5F1E7), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: AppTheme.forest)),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800, fontSize: 15)),
        Text(body, style: const TextStyle(color: Colors.black54, fontSize: 13)),
      ])),
    ]),
  );
}