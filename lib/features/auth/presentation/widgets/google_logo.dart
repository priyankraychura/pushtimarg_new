import 'package:flutter/material.dart';

/// The four-colour Google "G", drawn so no asset is needed.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _GPainter());
}

class _GPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: Offset(r, r), radius: r * .8);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .42
      ..strokeCap = StrokeCap.butt;

    void arc(Color color, double start, double sweep) {
      stroke.color = color;
      canvas.drawArc(rect, start, sweep, false, stroke);
    }

    const deg = 3.14159 / 180;
    arc(const Color(0xFFEA4335), 155 * deg, 70 * deg); // red (top-left)
    arc(const Color(0xFFFBBC05), 225 * deg, 70 * deg); // yellow (bottom-left)
    arc(const Color(0xFF34A853), 295 * deg, 70 * deg); // green (bottom-right)
    arc(const Color(0xFF4285F4), 5 * deg, 45 * deg); // blue (right)

    // blue bar
    final bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(r, r - r * .2, r * 1.0, r * .4), bar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
