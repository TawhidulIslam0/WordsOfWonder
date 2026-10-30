import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../services/puzzle_repository.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class LevelMapScreen extends StatefulWidget {
  const LevelMapScreen({super.key});
  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  int current = 1;
  @override
  void initState() { 
    super.initState(); 
    ProgressService.currentLevel().then((v) { if (mounted) setState(() => current = v); }); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adventure map'), backgroundColor: AppTheme.forest),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFF8E9), Color(0xFFE9F3E7)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Choose your next trail', style: TextStyle(fontSize: 23, color: AppTheme.ink, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('You have reached level $current. Earlier trails stay open for practice.', style: const TextStyle(color: Colors.black54)),
          ]))),
          SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 11, mainAxisSpacing: 11, childAspectRatio: 1),
            delegate: SliverChildBuilderDelegate((context, i) {
              final n = i + 1;
              final unlocked = n <= current;
              final completed = n < current;
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: unlocked ? () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(levelNumber: n)));
                  final updatedCurrent = await ProgressService.currentLevel();
                  if (mounted) {
                    setState(() {
                      current = updatedCurrent;
                    });
                  }
                } : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: completed ? AppTheme.leaf : unlocked ? AppTheme.forest : const Color(0xFFE0DFD5),
                    borderRadius: BorderRadius.circular(18),
                    border: n == current ? Border.all(color: AppTheme.gold, width: 3) : null,
                    boxShadow: unlocked ? [BoxShadow(color: AppTheme.forest.withOpacity(.12), blurRadius: 7, offset: const Offset(0, 3))] : null,
                  ),
                  child: Center(child: unlocked
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(completed ? Icons.check_circle : Icons.auto_awesome, color: AppTheme.gold, size: 18),
                        const SizedBox(height: 4),
                        Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                      ])
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.lock_outline, color: Colors.black38, size: 18),
                        const SizedBox(height: 4),
                        Text('$n', style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w800)),
                      ]),
                  ),
                ),
              );
            }, childCount: PuzzleRepository.totalLevels),
          )),
        ]),
      ),
    );
  }
}