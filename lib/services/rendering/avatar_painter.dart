import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/avatar_model.dart';
import '../../models/tracking_state.dart';
import '../../models/audio_sync_state.dart';
import '../../models/scene_preset.dart';

class AvatarPainter extends CustomPainter {
  final AvatarModel avatar;
  final TrackingState tracking;
  final AudioSyncState audio;
  final ScenePreset scene;
  final double idleTimeSeconds;
  final bool isTransparent;

  AvatarPainter({
    required this.avatar,
    required this.tracking,
    required this.audio,
    required this.scene,
    this.idleTimeSeconds = 0.0,
    this.isTransparent = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Background
    if (!isTransparent && !scene.isTransparent) {
      final rect = Offset.zero & size;
      final bgPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scene.primaryColor, scene.secondaryColor],
        ).createShader(rect);
      canvas.drawRect(rect, bgPaint);
    }

    final cx = size.width / 2;
    final cy = size.height / 2 + (avatar.offsetY * 100);

    // Natural subtle breathing motion
    final breathOffset = math.sin(idleTimeSeconds * 1.5) * 3.5;
    final naturalBlink = (math.sin(idleTimeSeconds * 0.8) > 0.96) ? 1.0 : 0.0;

    // Combine tracking & audio visemes
    final pitch = tracking.pitch;
    final yaw = tracking.yaw;
    final roll = tracking.roll;
    final leftBlink = math.max(tracking.leftEyeBlink, naturalBlink);
    final rightBlink = math.max(tracking.rightEyeBlink, naturalBlink);

    // Mouth openness combines tracking mouthOpen + audio speech energy
    final mouthOpen = math.max(
      tracking.mouthOpen,
      audio.isVoiceActive
          ? (audio.mouthOpenAmount * audio.sensitivity).clamp(0.0, 1.0)
          : 0.0,
    );

    final smile = tracking.smile;

    canvas.save();
    // Center avatar
    canvas.translate(cx, cy + breathOffset);
    canvas.scale(avatar.scale);

    // 3D-like Head Tilt and Rotation
    canvas.rotate(roll * 0.4);

    // Draw Shoulders and Torso
    _drawTorso(canvas, size, yaw, pitch);

    // Draw Neck
    _drawNeck(canvas, yaw, pitch);

    // Draw Head Base & Hair Back
    _drawHeadAndHair(
      canvas,
      yaw,
      pitch,
      leftBlink,
      rightBlink,
      mouthOpen,
      smile,
    );

    canvas.restore();
  }

  void _drawTorso(Canvas canvas, Size size, double yaw, double pitch) {
    final torsoPaint = Paint()
      ..color = avatar.clothingColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final torsoWidth = 260.0;
    final torsoTop = 130.0 + (pitch * 8.0);
    final torsoBottom = 340.0;

    path.moveTo(-torsoWidth / 2 + (yaw * 15), torsoBottom);
    path.quadraticBezierTo(
      -torsoWidth * 0.45,
      torsoTop + 20,
      -70 + (yaw * 20),
      torsoTop,
    );
    path.lineTo(70 + (yaw * 20), torsoTop);
    path.quadraticBezierTo(
      torsoWidth * 0.45,
      torsoTop + 20,
      torsoWidth / 2 + (yaw * 15),
      torsoBottom,
    );
    path.close();

    canvas.drawPath(path, torsoPaint);

    // Clothing Collar / Accent line
    final collarPaint = Paint()
      ..color = avatar.clothingColor.withValues(alpha: 0.7)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final collarPath = Path()
      ..moveTo(-45 + (yaw * 15), torsoTop)
      ..quadraticBezierTo(yaw * 15, torsoTop + 45, 45 + (yaw * 15), torsoTop);
    canvas.drawPath(collarPath, collarPaint);
  }

  void _drawNeck(Canvas canvas, double yaw, double pitch) {
    final neckPaint = Paint()
      ..color = _shadeColor(avatar.skinTone, -0.15)
      ..style = PaintingStyle.fill;

    final neckRect = Rect.fromCenter(
      center: Offset(yaw * 15, 80 + (pitch * 10)),
      width: 65,
      height: 90,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(neckRect, const Radius.circular(25)),
      neckPaint,
    );
  }

  void _drawHeadAndHair(
    Canvas canvas,
    double yaw,
    double pitch,
    double leftBlink,
    double rightBlink,
    double mouthOpen,
    double smile,
  ) {
    final headCenterX = yaw * 25.0;
    final headCenterY = -15.0 + (pitch * 20.0);

    // Hair Back Layer
    final hairPaint = Paint()
      ..color = avatar.hairColor
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenterX, headCenterY - 15),
        width: 210,
        height: 245,
      ),
      hairPaint,
    );

    // Face Skin
    final skinPaint = Paint()
      ..shader =
          RadialGradient(
            center: Alignment(-0.2 + (avatar.keyLightIntensity * 0.2), -0.4),
            radius: 0.9,
            colors: [
              _tintColor(avatar.skinTone, avatar.keyLightColor, 0.25),
              avatar.skinTone,
              _shadeColor(avatar.skinTone, -0.2),
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(
            Rect.fromCenter(
              center: Offset(headCenterX, headCenterY),
              width: 170,
              height: 215,
            ),
          );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenterX, headCenterY),
        width: 165,
        height: 210,
      ),
      skinPaint,
    );

    // Eyes
    _drawEyes(
      canvas,
      headCenterX,
      headCenterY,
      yaw,
      pitch,
      leftBlink,
      rightBlink,
    );

    // Eyebrows
    _drawEyebrows(
      canvas,
      headCenterX,
      headCenterY,
      yaw,
      pitch,
      tracking.browRaise,
    );

    // Nose
    _drawNose(canvas, headCenterX, headCenterY, yaw, pitch);

    // Mouth with Lip-Sync Visemes
    _drawMouth(canvas, headCenterX, headCenterY, yaw, pitch, mouthOpen, smile);

    // Hair Front Bangs / Modern Strands
    _drawHairFront(canvas, headCenterX, headCenterY, yaw);
  }

  void _drawEyes(
    Canvas canvas,
    double hx,
    double hy,
    double yaw,
    double pitch,
    double leftBlink,
    double rightBlink,
  ) {
    const eyeSpacing = 42.0;
    final eyeY = hy - 10.0;
    final gazeX = yaw * 8.0;
    final gazeY = pitch * 5.0;

    // Left Eye
    _drawSingleEye(
      canvas,
      Offset(hx - eyeSpacing, eyeY),
      leftBlink,
      gazeX,
      gazeY,
      isLeft: true,
    );

    // Right Eye
    _drawSingleEye(
      canvas,
      Offset(hx + eyeSpacing, eyeY),
      rightBlink,
      gazeX,
      gazeY,
      isLeft: false,
    );
  }

  void _drawSingleEye(
    Canvas canvas,
    Offset center,
    double blink,
    double gazeX,
    double gazeY, {
    required bool isLeft,
  }) {
    const eyeWidth = 34.0;
    final eyeHeight = (1.0 - blink) * 20.0;

    if (eyeHeight <= 2.0) {
      // Closed Eye (Eyelash slit)
      final lashPaint = Paint()
        ..color = _shadeColor(avatar.hairColor, -0.2)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(center.dx - (eyeWidth / 2), center.dy),
        Offset(center.dx + (eyeWidth / 2), center.dy),
        lashPaint,
      );
      return;
    }

    // Sclera (White)
    final scleraPaint = Paint()
      ..color = const Color(0xFFFAFAFA)
      ..style = PaintingStyle.fill;

    final eyeRect = Rect.fromCenter(
      center: center,
      width: eyeWidth,
      height: eyeHeight,
    );
    canvas.drawOval(eyeRect, scleraPaint);

    // Iris Clip inside eye oval
    canvas.save();
    canvas.clipPath(Path()..addOval(eyeRect));

    // Iris
    final irisCenter = Offset(center.dx + gazeX, center.dy + gazeY);
    final irisPaint = Paint()
      ..shader = RadialGradient(
        colors: [avatar.eyeColor, _shadeColor(avatar.eyeColor, -0.4)],
      ).createShader(Rect.fromCircle(center: irisCenter, radius: 10));

    canvas.drawCircle(irisCenter, 9.5, irisPaint);

    // Pupil
    final pupilPaint = Paint()..color = const Color(0xFF101018);
    canvas.drawCircle(irisCenter, 4.5, pupilPaint);

    // Specular Highlight (Reflection)
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(irisCenter.dx - 3, irisCenter.dy - 3),
      2.2,
      shinePaint,
    );
    canvas.drawCircle(
      Offset(irisCenter.dx + 2.5, irisCenter.dy + 2.5),
      1.0,
      shinePaint,
    );

    canvas.restore();

    // Eyelid line
    final lidPaint = Paint()
      ..color = _shadeColor(avatar.skinTone, -0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 1),
        width: eyeWidth + 2,
        height: eyeHeight + 2,
      ),
      math.pi,
      math.pi,
      false,
      lidPaint,
    );
  }

  void _drawEyebrows(
    Canvas canvas,
    double hx,
    double hy,
    double yaw,
    double pitch,
    double browRaise,
  ) {
    final browPaint = Paint()
      ..color = _shadeColor(avatar.hairColor, -0.1)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final browLift = browRaise * 8.0;
    final browY = hy - 26.0 - browLift;

    // Left Brow
    final leftPath = Path()
      ..moveTo(hx - 58, browY + 2)
      ..quadraticBezierTo(hx - 40, browY - 3, hx - 22, browY + 3);
    canvas.drawPath(leftPath, browPaint);

    // Right Brow
    final rightPath = Path()
      ..moveTo(hx + 22, browY + 3)
      ..quadraticBezierTo(hx + 40, browY - 3, hx + 58, browY + 2);
    canvas.drawPath(rightPath, browPaint);
  }

  void _drawNose(
    Canvas canvas,
    double hx,
    double hy,
    double yaw,
    double pitch,
  ) {
    final nosePaint = Paint()
      ..color = _shadeColor(avatar.skinTone, -0.22)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final noseX = hx + (yaw * 6.0);
    final noseY = hy + 18.0 + (pitch * 5.0);

    final path = Path()
      ..moveTo(noseX - 2, noseY - 8)
      ..lineTo(noseX + 3, noseY + 4)
      ..lineTo(noseX - 6, noseY + 7);

    canvas.drawPath(path, nosePaint);
  }

  void _drawMouth(
    Canvas canvas,
    double hx,
    double hy,
    double yaw,
    double pitch,
    double mouthOpen,
    double smile,
  ) {
    final mouthX = hx + (yaw * 5.0);
    final mouthY = hy + 54.0 + (pitch * 4.0);

    // Viseme adjustments
    double widthModifier = 0.0;
    if (audio.currentViseme == 'oh') {
      widthModifier = -10.0; // Rounded for 'O'
    } else if (audio.currentViseme == 'ee') {
      widthModifier = 12.0; // Spread for 'E'
    }

    final mouthWidth = 42.0 + (smile * 12.0) + widthModifier;
    final mouthHeight = math.max(3.0, mouthOpen * 32.0);

    if (mouthHeight > 6.0) {
      // Open mouth interior
      final innerPaint = Paint()
        ..color = const Color(0xFF4A121A)
        ..style = PaintingStyle.fill;

      final mouthRect = Rect.fromCenter(
        center: Offset(mouthX, mouthY),
        width: mouthWidth,
        height: mouthHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(mouthRect, Radius.circular(mouthHeight / 2)),
        innerPaint,
      );

      // Teeth
      final teethPaint = Paint()..color = const Color(0xFFF8FAFC);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            mouthX - (mouthWidth * 0.35),
            mouthY - (mouthHeight / 2),
            mouthWidth * 0.7,
            math.min(6.0, mouthHeight * 0.35),
          ),
          const Radius.circular(2),
        ),
        teethPaint,
      );

      // Tongue
      final tonguePaint = Paint()..color = const Color(0xFFE57373);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(mouthX, mouthY + (mouthHeight * 0.25)),
          width: mouthWidth * 0.5,
          height: mouthHeight * 0.45,
        ),
        tonguePaint,
      );
    }

    // Lips
    final lipPaint = Paint()
      ..color = _shadeColor(avatar.skinTone, -0.28)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final smileCurve = (smile * 8.0) - (mouthHeight * 0.2);

    final upperLip = Path()
      ..moveTo(mouthX - (mouthWidth / 2), mouthY)
      ..quadraticBezierTo(
        mouthX,
        mouthY + smileCurve - 2,
        mouthX + (mouthWidth / 2),
        mouthY,
      );
    canvas.drawPath(upperLip, lipPaint);

    final lowerLip = Path()
      ..moveTo(mouthX - (mouthWidth * 0.4), mouthY + (mouthHeight * 0.7))
      ..quadraticBezierTo(
        mouthX,
        mouthY + (mouthHeight * 0.8) + smileCurve,
        mouthX + (mouthWidth * 0.4),
        mouthY + (mouthHeight * 0.7),
      );
    canvas.drawPath(lowerLip, lipPaint);
  }

  void _drawHairFront(Canvas canvas, double hx, double hy, double yaw) {
    final hairPaint = Paint()
      ..color = avatar.hairColor
      ..style = PaintingStyle.fill;

    // Stylized Front Bangs
    final path = Path()
      ..moveTo(hx - 80, hy - 65)
      ..quadraticBezierTo(hx - 20, hy - 40, hx + 10, hy - 50)
      ..quadraticBezierTo(hx + 50, hy - 60, hx + 85, hy - 45)
      ..quadraticBezierTo(hx + 95, hy - 95, hx, hy - 110)
      ..quadraticBezierTo(hx - 95, hy - 95, hx - 80, hy - 65);
    canvas.drawPath(path, hairPaint);

    // Subtle hair highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final highlightPath = Path()
      ..moveTo(hx - 55, hy - 85)
      ..quadraticBezierTo(hx - 10, hy - 98, hx + 40, hy - 88);
    canvas.drawPath(highlightPath, highlightPaint);
  }

  Color _shadeColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + factor).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color _tintColor(Color base, Color tint, double amount) {
    return Color.lerp(base, tint, amount) ?? base;
  }

  @override
  bool shouldRepaint(covariant AvatarPainter oldDelegate) {
    return true; // Continuously animate in real-time
  }
}
