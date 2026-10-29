import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/face_swap_model.dart';
import '../../../services/face_swap/face_swap_engine.dart';

class FaceSwapPainter extends CustomPainter {
  final FaceSwapFrame? frame;
  final FaceSwapTarget? target;
  final FaceSwapSettings settings;
  final bool showMesh;
  final bool isTransparent;

  const FaceSwapPainter({
    required this.frame,
    required this.target,
    required this.settings,
    this.showMesh = false,
    this.isTransparent = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isTransparent) {
      final bgPaint = Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.2,
          colors: [Color(0xFF161F2E), Color(0xFF090D13)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    }

    if (frame == null) {
      _paintStandbyPlaceholder(canvas, size);
      return;
    }

    final f = frame!;
    final scale = math.min(size.width / 1000.0, size.height / 1000.0);
    canvas.save();
    canvas.scale(scale);

    // Center in view if aspect ratios differ
    final dx = (size.width / scale - 1000.0) / 2.0;
    final dy = (size.height / scale - 1000.0) / 2.0;
    canvas.translate(dx, dy);

    // 1. Draw Torso / Shoulders base
    _paintTorso(canvas, f);

    // 2. Draw Neck with natural shadow
    _paintNeck(canvas, f);

    // 3. Draw Swapped Head Contour & Skin Surface
    _paintFaceBase(canvas, f);

    // 4. Draw Nose Structure
    _paintNose(canvas, f);

    // 5. Draw Photorealistic Eyes & Blinking
    _paintEye(
      canvas: canvas,
      center: f.leftEye,
      blink: f.leftBlink,
      headYaw: f.headYaw,
      headPitch: f.headPitch,
      isLeft: true,
    );
    _paintEye(
      canvas: canvas,
      center: f.rightEye,
      blink: f.rightBlink,
      headYaw: f.headYaw,
      headPitch: f.headPitch,
      isLeft: false,
    );

    // 6. Draw Eyebrows
    _paintEyebrows(canvas, f);

    // 7. Draw Expressive Swapped Mouth with Lip-Sync
    _paintMouth(canvas, f);

    // 8. Draw Hair Layer (preserves realistic target face styling)
    _paintHair(canvas, f);

    // 9. Draw Live Computer Vision Tracking Mesh (if toggled)
    if (showMesh) {
      _paintLandmarkMesh(canvas, f);
    }

    canvas.restore();
  }

  void _paintStandbyPlaceholder(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'AI Face Swap Ready\nSelect Target Face and Enable Camera',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 40);

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _paintTorso(Canvas canvas, FaceSwapFrame f) {
    final torsoPath = Path()
      ..moveTo(240, 750)
      ..cubicTo(260, 680, 360, 660, 500 + (f.headYaw * 30), 660)
      ..cubicTo(640, 660, 740, 680, 760, 750)
      ..lineTo(820, 1000)
      ..lineTo(180, 1000)
      ..close();

    final clothPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E2838), Color(0xFF101722)],
      ).createShader(const Rect.fromLTWH(180, 660, 640, 340));

    canvas.drawPath(torsoPath, clothPaint);
  }

  void _paintNeck(Canvas canvas, FaceSwapFrame f) {
    final neckRect = Rect.fromCenter(
      center: Offset(500 + (f.headYaw * 40), 570 + (f.headPitch * 20)),
      width: 140,
      height: 160,
    );

    final neckPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          f.skinTone.withValues(alpha: f.blendAlpha * 0.7),
          f.skinTone.withValues(alpha: f.blendAlpha),
        ],
      ).createShader(neckRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(neckRect, const Radius.circular(30)),
      neckPaint,
    );
  }

  void _paintFaceBase(Canvas canvas, FaceSwapFrame f) {
    final box = f.faceBoundingBox;
    final path = Path()
      ..addOval(
        Rect.fromCenter(
          center: box.center,
          width: box.width,
          height: box.height,
        ),
      );

    // Realistic multi-stop radial skin lighting
    final facePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          f.headYaw * 0.3 - 0.15,
          f.headPitch * 0.3 - 0.25,
        ),
        radius: 0.9,
        colors: [
          Color.lerp(f.skinTone, Colors.white, 0.25)!.withValues(
            alpha: f.blendAlpha,
          ),
          f.skinTone.withValues(alpha: f.blendAlpha),
          Color.lerp(f.skinTone, const Color(0xFF6A3B22), 0.35)!.withValues(
            alpha: f.blendAlpha,
          ),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(box);

    canvas.drawPath(path, facePaint);

    // Soft Edge Feathering Blur / Ambient occlusion
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, settings.edgeFeathering)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawPath(path, shadowPaint);
  }

  void _paintNose(Canvas canvas, FaceSwapFrame f) {
    final noseCenter = f.noseTip;
    final path = Path()
      ..moveTo(noseCenter.dx - 18, noseCenter.dy + 8)
      ..quadraticBezierTo(noseCenter.dx, noseCenter.dy + 16, noseCenter.dx + 18, noseCenter.dy + 8)
      ..quadraticBezierTo(noseCenter.dx + 6, noseCenter.dy - 25, noseCenter.dx, noseCenter.dy - 35)
      ..quadraticBezierTo(noseCenter.dx - 6, noseCenter.dy - 25, noseCenter.dx - 18, noseCenter.dy + 8)
      ..close();

    final nosePaint = Paint()
      ..color = Color.lerp(f.skinTone, const Color(0xFF4A2515), 0.18)!
          .withValues(alpha: f.blendAlpha * 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, nosePaint);

    // Nostrils
    final nostrilPaint = Paint()
      ..color = const Color(0xFF2C1309).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(noseCenter.dx - 12, noseCenter.dy + 10), width: 8, height: 5),
      nostrilPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(noseCenter.dx + 12, noseCenter.dy + 10), width: 8, height: 5),
      nostrilPaint,
    );
  }

  void _paintEye({
    required Canvas canvas,
    required Offset center,
    required double blink,
    required double headYaw,
    required double headPitch,
    required bool isLeft,
  }) {
    final eyeWidth = 52.0;
    final eyeHeight = (1.0 - blink.clamp(0.0, 1.0)) * 26.0;

    if (eyeHeight < 2.0) {
      // Closed Eye Eyelash Line
      final closedEyePaint = Paint()
        ..color = const Color(0xFF1D0E08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(center.dx - (eyeWidth / 2), center.dy),
        Offset(center.dx + (eyeWidth / 2), center.dy),
        closedEyePaint,
      );
      return;
    }

    // Sclera (White)
    final eyeRect = Rect.fromCenter(
      center: center,
      width: eyeWidth,
      height: eyeHeight,
    );
    final scleraPaint = Paint()
      ..color = const Color(0xFFF9F7F5)
      ..style = PaintingStyle.fill;
    canvas.drawOval(eyeRect, scleraPaint);

    // Iris (Dynamic Gaze)
    final gazeDx = (headYaw * 6.0).clamp(-8.0, 8.0);
    final gazeDy = (headPitch * 5.0).clamp(-6.0, 6.0);
    final irisCenter = Offset(center.dx + gazeDx, center.dy + gazeDy);

    final irisPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF1D5A72), Color(0xFF0A222C)],
      ).createShader(Rect.fromCircle(center: irisCenter, radius: 12));

    canvas.save();
    canvas.clipPath(Path()..addOval(eyeRect));
    canvas.drawCircle(irisCenter, 11.5, irisPaint);

    // Pupil
    canvas.drawCircle(irisCenter, 5.0, Paint()..color = const Color(0xFF040608));

    // Specular Catchlight
    canvas.drawCircle(
      Offset(irisCenter.dx - 3, irisCenter.dy - 3),
      2.5,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.restore();

    // Eyelid Outlines
    final lidPaint = Paint()
      ..color = const Color(0xFF2E1911)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(eyeRect, lidPaint);
  }

  void _paintEyebrows(Canvas canvas, FaceSwapFrame f) {
    final browPaint = Paint()
      ..color = const Color(0xFF261811)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    // Left Brow
    final leftStart = Offset(f.leftEye.dx - 26, f.leftEye.dy - 24 + (f.headPitch * 4));
    final leftEnd = Offset(f.leftEye.dx + 26, f.leftEye.dy - 28 + (f.headPitch * 4));
    canvas.drawLine(leftStart, leftEnd, browPaint);

    // Right Brow
    final rightStart = Offset(f.rightEye.dx - 26, f.rightEye.dy - 28 + (f.headPitch * 4));
    final rightEnd = Offset(f.rightEye.dx + 26, f.rightEye.dy - 24 + (f.headPitch * 4));
    canvas.drawLine(rightStart, rightEnd, browPaint);
  }

  void _paintMouth(Canvas canvas, FaceSwapFrame f) {
    final mCenter = f.mouthCenter;
    final mouthOpen = f.mouthOpening.clamp(0.0, 1.0);
    final width = 64.0 + (mouthOpen * 8.0);
    final height = 12.0 + (mouthOpen * 36.0);

    final mouthRect = Rect.fromCenter(
      center: mCenter,
      width: width,
      height: height,
    );

    if (mouthOpen > 0.08) {
      // Mouth Cavity
      final cavityPaint = Paint()
        ..color = const Color(0xFF2B0A0D)
        ..style = PaintingStyle.fill;
      canvas.drawOval(mouthRect, cavityPaint);

      // Upper Teeth
      final teethRect = Rect.fromLTWH(
        mCenter.dx - (width * 0.35),
        mCenter.dy - (height * 0.45),
        width * 0.7,
        height * 0.35,
      );
      canvas.save();
      canvas.clipPath(Path()..addOval(mouthRect));
      canvas.drawRRect(
        RRect.fromRectAndRadius(teethRect, const Radius.circular(4)),
        Paint()..color = const Color(0xFFEBE6E3),
      );

      // Tongue
      final tongueRect = Rect.fromCenter(
        center: Offset(mCenter.dx, mCenter.dy + (height * 0.3)),
        width: width * 0.6,
        height: height * 0.45,
      );
      canvas.drawOval(tongueRect, Paint()..color = const Color(0xFFB54C54));
      canvas.restore();
    }

    // Lips Outlines
    final lipColor = Color.lerp(f.skinTone, const Color(0xFFBA4F55), 0.6)!;
    final lipPaint = Paint()
      ..color = lipColor.withValues(alpha: f.blendAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawOval(mouthRect, lipPaint);
  }

  void _paintHair(Canvas canvas, FaceSwapFrame f) {
    final box = f.faceBoundingBox;
    final hairPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF281C17), Color(0xFF140C08)],
      ).createShader(Rect.fromLTWH(box.left - 20, box.top - 50, box.width + 40, box.height * 0.5));

    final hairPath = Path()
      ..moveTo(box.left - 10, box.top + 80)
      ..cubicTo(box.left - 30, box.top - 60, box.right + 30, box.top - 60, box.right + 10, box.top + 80)
      ..quadraticBezierTo(box.right, box.top + 10, box.center.dx, box.top + 25)
      ..quadraticBezierTo(box.left, box.top + 10, box.left - 10, box.top + 80)
      ..close();

    canvas.drawPath(hairPath, hairPaint);
  }

  void _paintLandmarkMesh(Canvas canvas, FaceSwapFrame f) {
    final meshPaint = Paint()
      ..color = AppColors.primaryCyan.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Face boundary box
    canvas.drawRect(f.faceBoundingBox, meshPaint);

    // Landmark crosshairs
    final points = [
      f.leftEye,
      f.rightEye,
      f.noseTip,
      f.mouthCenter,
      Offset(f.faceBoundingBox.left + 30, f.noseTip.dy),
      Offset(f.faceBoundingBox.right - 30, f.noseTip.dy),
    ];

    for (final pt in points) {
      canvas.drawCircle(pt, 3.5, Paint()..color = AppColors.primaryCyan);
    }

    // Connect mesh lines
    canvas.drawLine(f.leftEye, f.rightEye, meshPaint);
    canvas.drawLine(f.leftEye, f.noseTip, meshPaint);
    canvas.drawLine(f.rightEye, f.noseTip, meshPaint);
    canvas.drawLine(f.noseTip, f.mouthCenter, meshPaint);
  }

  @override
  bool shouldRepaint(covariant FaceSwapPainter oldDelegate) => true;
}
