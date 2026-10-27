import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Professional vector-rendered TD Logo for TD-Avatar-Studio
class TdLogo extends StatelessWidget {
  final double size;
  final bool showBadge;
  final bool glow;

  const TdLogo({
    super.key,
    this.size = 28.0,
    this.showBadge = true,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TdLogoPainter(showBadge: showBadge),
      ),
    );

    if (!glow) return logoWidget;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withValues(alpha: 0.5),
            blurRadius: size * 0.4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: logoWidget,
    );
  }
}

class _TdLogoPainter extends CustomPainter {
  final bool showBadge;

  _TdLogoPainter({required this.showBadge});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Outer Hexagonal / Squircle Badge
    if (showBadge) {
      final badgeRect = Rect.fromLTWH(0, 0, w, h);
      final r = w * 0.22;

      // Outer gradient stroke
      final borderPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryCyan,
            AppColors.accentPurple,
            AppColors.primaryBlue,
          ],
        ).createShader(badgeRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.08;

      final bgPaint = Paint()
        ..color = const Color(0xFF0A0F1E)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(badgeRect.deflate(w * 0.04), Radius.circular(r));
      canvas.drawRRect(rrect, bgPaint);
      canvas.drawRRect(rrect, borderPaint);
    }

    // 2. Interconnected "T" and "D" Modern Geometry
    final glyphPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          AppColors.primaryCyan,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final accentPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryCyan,
          AppColors.accentPurple,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.11
      ..strokeCap = StrokeCap.round;

    // Letter "T":
    // Horizontal crossbar
    final tPath = Path()
      ..moveTo(w * 0.22, h * 0.32)
      ..lineTo(w * 0.52, h * 0.32)
      // Vertical stem
      ..moveTo(w * 0.37, h * 0.32)
      ..lineTo(w * 0.37, h * 0.72);
    canvas.drawPath(tPath, glyphPaint);

    // Letter "D":
    // Vertical stem connected + curved bowl
    final dPath = Path()
      ..moveTo(w * 0.56, h * 0.32)
      ..lineTo(w * 0.56, h * 0.72)
      ..moveTo(w * 0.56, h * 0.32)
      ..quadraticBezierTo(w * 0.84, h * 0.32, w * 0.84, h * 0.52)
      ..quadraticBezierTo(w * 0.84, h * 0.72, w * 0.56, h * 0.72);
    canvas.drawPath(dPath, accentPaint);

    // Subtle Tech Dot in center/upper right
    final dotPaint = Paint()
      ..color = AppColors.primaryCyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.78, h * 0.26), w * 0.05, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _TdLogoPainter oldDelegate) => false;
}

