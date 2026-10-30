import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WordSlots extends StatelessWidget {
  final List<String> answers;
  final Set<String> found;
  const WordSlots({super.key, required this.answers, required this.found});

  @override
  Widget build(BuildContext context) {
    final sorted = List<String>.from(answers)..sort((a, b) {
      final c = a.length.compareTo(b.length);
      return c != 0 ? c : a.compareTo(b);
    });
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFFE6EBDD), borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD1DCCB))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.grid_view_rounded, size: 16, color: AppTheme.leaf),
          const SizedBox(width: 6),
          Text('CROSSWORD • ${answers.length} WORDS', style: const TextStyle(fontSize: 10, letterSpacing: 1.3, color: AppTheme.forest, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 15),
        ...sorted.map((word) {
          final isFound = found.contains(word);
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(word.length, (i) {
              final visible = isFound;
              return Container(
                width: _tileWidth(context, word.length),
                height: 39,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: visible ? const Color(0xFF2F8B65) : const Color(0xFFFFFCF3),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: visible ? const Color(0xFF2F8B65) : const Color(0xFFC8D1C0), width: 1.2),
                  boxShadow: visible ? [BoxShadow(color: AppTheme.forest.withOpacity(.12), blurRadius: 4, offset: const Offset(0, 2))] : null,
                ),
                child: Center(child: visible ? Text(word[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)) : null),
              );
            })),
          );
        }),
        const SizedBox(height: 2),
        Text('${found.length} words found', style: const TextStyle(color: Colors.black45, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  double _tileWidth(BuildContext context, int length) {
    final width = MediaQuery.of(context).size.width;
    return ((width - 62) / length).clamp(22.0, 38.0);
  }
}
