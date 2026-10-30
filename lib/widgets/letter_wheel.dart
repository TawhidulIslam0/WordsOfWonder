import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LetterWheel extends StatefulWidget {
  final List<String> letters;
  final int selectedCount;
  final ValueChanged<String> onWordSubmitted;
  final VoidCallback onShuffle;

  const LetterWheel({
    super.key,
    required this.letters,
    required this.selectedCount,
    required this.onWordSubmitted,
    required this.onShuffle,
  });

  @override
  State<LetterWheel> createState() => _LetterWheelState();
}

class _LetterWheelState extends State<LetterWheel> {
  final List<int> _selectedIndexPath = [];
  Offset? _currentPointerPosition;

  void _onPanStart(DragStartDetails details, Size size) {
    _handleTouch(details.localPosition, size);
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    _handleTouch(details.localPosition, size);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selectedIndexPath.isNotEmpty) {
      final word = _selectedIndexPath.map((i) => widget.letters[i]).join();
      widget.onWordSubmitted(word);
    }
    setState(() {
      _selectedIndexPath.clear();
      _currentPointerPosition = null;
    });
  }

  void _handleTouch(Offset localPosition, Size size) {
    setState(() {
      _currentPointerPosition = localPosition;
    });

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.35;

    for (int i = 0; i < widget.letters.length; i++) {
      final angle = (i * 2 * pi / widget.letters.length) - pi / 2;
      final nodeCenter = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      // Fixed: changed localPositon to localPosition
      final distance = (localPosition - nodeCenter).distance;
      if (distance < 42) {
        if (!_selectedIndexPath.contains(i)) {
          setState(() {
            _selectedIndexPath.add(i);
          });
        } else if (_selectedIndexPath.length > 1 && _selectedIndexPath[_selectedIndexPath.length - 2] == i) {
          // Allow backtracking to previous letter
          setState(() {
            _selectedIndexPath.removeLast();
          });
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxWidth * 0.95);
        final center = Offset(size.width / 2, size.height / 2);
        final radius = min(size.width, size.height) * 0.36;

        final currentWord = _selectedIndexPath.map((i) => widget.letters[i]).join();

        return GestureDetector(
          onPanStart: (details) => _onPanStart(details, size),
          onPanUpdate: (details) => _onPanUpdate(details, size),
          onPanEnd: _onPanEnd,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer decorative ring & background
                Container(
                  width: radius * 2.2,
                  height: radius * 2.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.85),
                    border: Border.all(color: const Color(0xFFE2DDCF), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

                // Connecting Drag Path (Line between selected letters + cursor)
                CustomPaint(
                  size: size,
                  painter: WheelPathPainter(
                    selectedIndexPath: _selectedIndexPath,
                    currentPointerPosition: _currentPointerPosition,
                    lettersCount: widget.letters.length,
                    radius: radius,
                    center: center,
                  ),
                ),

                // Center word preview pill
                Positioned(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: currentWord.isNotEmpty ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.forest,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          currentWord,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Letter Nodes
                ...List.generate(widget.letters.length, (i) {
                  final angle = (i * 2 * pi / widget.letters.length) - pi / 2;
                  final x = center.dx + radius * cos(angle) - 28;
                  final y = center.dy + radius * sin(angle) - 28;
                  final isSelected = _selectedIndexPath.contains(i);

                  return Positioned(
                    left: x,
                    top: y,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? const Color(0xFFB84A39) : Colors.white,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF8E3426) : const Color(0xFFE2DDCF),
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color(0xFFB84A39).withOpacity(0.4)
                                : Colors.black.withOpacity(0.08),
                            blurRadius: isSelected ? 10 : 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.letters[i],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white : AppTheme.ink,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Shuffle Button at the bottom center
                Positioned(
                  bottom: 12,
                  child: GestureDetector(
                    onTap: widget.onShuffle,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF4F1EA),
                        border: Border.all(color: const Color(0xFFDCD5C3), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.shuffle_rounded,
                        color: AppTheme.forest,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WheelPathPainter extends CustomPainter {
  final List<int> selectedIndexPath;
  final Offset? currentPointerPosition;
  final int lettersCount;
  final double radius;
  final Offset center;

  WheelPathPainter({
    required this.selectedIndexPath,
    required this.currentPointerPosition,
    required this.lettersCount,
    required this.radius,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedIndexPath.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFB84A39).withOpacity(0.7)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < selectedIndexPath.length; i++) {
      final nodeIndex = selectedIndexPath[i];
      final angle = (nodeIndex * 2 * pi / lettersCount) - pi / 2;
      final nodePos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      if (i == 0) {
        path.moveTo(nodePos.dx, nodePos.dy);
      } else {
        path.lineTo(nodePos.dx, nodePos.dy);
      }
    }

    if (currentPointerPosition != null && selectedIndexPath.isNotEmpty) {
      path.lineTo(currentPointerPosition!.dx, currentPointerPosition!.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WheelPathPainter oldDelegate) {
    return oldDelegate.selectedIndexPath != selectedIndexPath ||
        oldDelegate.currentPointerPosition != currentPointerPosition;
  }
}