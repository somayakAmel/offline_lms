import 'package:flutter/material.dart';

/// Very faint grid of small learning icons (books, microscopes, caps) that
/// fades in towards the bottom of the screen. Purely decorative.
class EducationPattern extends StatelessWidget {
  const EducationPattern({super.key});

  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05);
    return IgnorePointer(
      child: ExcludeSemantics(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.transparent, Colors.black],
            stops: [0, 0.45, 1],
          ).createShader(bounds),
          child: CustomPaint(
            painter: _PatternPainter(color),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter(this.color);

  final Color color;

  static const double _spacing = 64;
  static const double _iconSize = 20;
  static const List<IconData> _icons = [
    Icons.menu_book_outlined,
    Icons.biotech_outlined,
    Icons.school_outlined,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final painters = [
      for (final icon in _icons)
        TextPainter(
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              fontSize: _iconSize,
              color: color,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];

    var row = 0;
    for (var y = _spacing / 2; y < size.height; y += _spacing, row++) {
      // Offset every other row by half a step for a staggered grid.
      final shift = row.isOdd ? _spacing / 2 : 0.0;
      var column = 0;
      for (var x = shift + _spacing / 4; x < size.width; x += _spacing, column++) {
        painters[(row + column) % painters.length]
            .paint(canvas, Offset(x, y));
      }
    }
    for (final painter in painters) {
      painter.dispose();
    }
  }

  @override
  bool shouldRepaint(_PatternPainter oldDelegate) => oldDelegate.color != color;
}
