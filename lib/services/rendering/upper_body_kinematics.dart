import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Upper Body & Hand Kinematics Data
class UpperBodyPose {
  final Offset torsoCenter;
  final double torsoAngle;
  final Offset leftShoulder;
  final Offset rightShoulder;
  final Offset leftElbow;
  final Offset rightElbow;
  final Offset leftWrist;
  final Offset rightWrist;

  // Hand gesture properties [0.0 = rest/down, 1.0 = fully raised gesturing]
  final double leftHandElevation;
  final double rightHandElevation;
  final double leftHandGesturePhase;
  final double rightHandGesturePhase;
  final double fingerCurl; // 0.0 = open palm, 1.0 = closed fist

  const UpperBodyPose({
    required this.torsoCenter,
    required this.torsoAngle,
    required this.leftShoulder,
    required this.rightShoulder,
    required this.leftElbow,
    required this.rightElbow,
    required this.leftWrist,
    required this.rightWrist,
    required this.leftHandElevation,
    required this.rightHandElevation,
    required this.leftHandGesturePhase,
    required this.rightHandGesturePhase,
    required this.fingerCurl,
  });
}

/// Kinematics Solver for Upper Body, Shoulders, and Conversational Hands
class UpperBodyKinematicsSolver {
  /// Solves upper body posture and conversational hand positions
  static UpperBodyPose solve({
    required Size size,
    required double pitch,
    required double yaw,
    required double roll,
    required double idleTime,
    required bool isVoiceActive,
    required double speechEnergy, // 0.0 to 1.0
  }) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Natural Breathing & Spinal Sway
    final breath = math.sin(idleTime * 1.6) * 5.0;
    final lateralSway = math.sin(idleTime * 0.9) * 4.0 + (yaw * 24.0);
    final torsoAngle = (roll * 0.35) + (math.sin(idleTime * 0.9) * 0.015);

    final torsoCenter = Offset(cx + lateralSway, cy + 120.0 + breath + (pitch * 10.0));

    // 2. Anatomical Shoulders with Counter-Rotation & Clavicle Movement
    // When head tilts right (roll > 0), the left shoulder lifts slightly, right lowers
    final shoulderHalfWidth = 145.0;
    final shoulderDrop = 25.0;
    final shoulderElevation = -roll * 22.0;

    // Perspective foreshortening from Yaw
    final leftShoulderX = torsoCenter.dx - (shoulderHalfWidth * (1.0 - (yaw * 0.18)));
    final rightShoulderX = torsoCenter.dx + (shoulderHalfWidth * (1.0 + (yaw * 0.18)));

    final leftShoulderY = torsoCenter.dy - 70.0 + shoulderDrop + shoulderElevation + (pitch * 8.0);
    final rightShoulderY = torsoCenter.dy - 70.0 + shoulderDrop - shoulderElevation + (pitch * 8.0);

    final leftShoulder = Offset(leftShoulderX, leftShoulderY);
    final rightShoulder = Offset(rightShoulderX, rightShoulderY);

    // 3. Conversational Hand Gestures
    // Hands raise dynamically when user speaks or based on speech energy
    final targetElevation = isVoiceActive ? (0.65 + (speechEnergy * 0.35)).clamp(0.0, 1.0) : 0.0;
    
    // Natural phase oscillation for conversational cadence
    final leftPhase = (idleTime * 2.8) + (speechEnergy * 2.0);
    final rightPhase = (idleTime * 2.5) + (speechEnergy * 2.2) + 1.2;

    // When gesturing, hands move up towards chest/waist level
    final leftHandLift = targetElevation * 160.0;
    final rightHandLift = targetElevation * 150.0;

    final leftElbow = Offset(
      leftShoulder.dx - 45.0 - (targetElevation * 15.0),
      leftShoulder.dy + 120.0 - (leftHandLift * 0.3),
    );
    final rightElbow = Offset(
      rightShoulder.dx + 45.0 + (targetElevation * 15.0),
      rightShoulder.dy + 120.0 - (rightHandLift * 0.3),
    );

    // Conversational wrist positions
    final leftWristX = leftElbow.dx + 30.0 + (math.sin(leftPhase) * (targetElevation * 28.0));
    final leftWristY = leftElbow.dy + 110.0 - leftHandLift + (math.cos(leftPhase) * (targetElevation * 14.0));

    final rightWristX = rightElbow.dx - 30.0 + (math.sin(rightPhase) * (targetElevation * 32.0));
    final rightWristY = rightElbow.dy + 110.0 - rightHandLift + (math.cos(rightPhase) * (targetElevation * 16.0));

    final fingerCurl = (0.2 + (math.sin(idleTime * 3.0) * 0.15 * targetElevation)).clamp(0.0, 1.0);

    return UpperBodyPose(
      torsoCenter: torsoCenter,
      torsoAngle: torsoAngle,
      leftShoulder: leftShoulder,
      rightShoulder: rightShoulder,
      leftElbow: leftElbow,
      rightElbow: rightElbow,
      leftWrist: Offset(leftWristX, leftWristY),
      rightWrist: Offset(rightWristX, rightWristY),
      leftHandElevation: targetElevation,
      rightHandElevation: targetElevation,
      leftHandGesturePhase: leftPhase,
      rightHandGesturePhase: rightPhase,
      fingerCurl: fingerCurl,
    );
  }

  /// Renders an articulated, photorealistic conversational hand with 5 fingers
  static void paintArticulatedHand({
    required Canvas canvas,
    required Offset wrist,
    required Color skinTone,
    required bool isLeft,
    required double gesturePhase,
    required double elevation,
    required double fingerCurl,
    double scale = 1.0,
  }) {
    if (elevation < 0.05) return; // Hidden below frame at rest

    canvas.save();
    canvas.translate(wrist.dx, wrist.dy);
    canvas.scale(scale * (0.8 + (elevation * 0.2)));

    // Natural rotation angle of wrist during conversation
    final wristRotation = isLeft
        ? (0.25 + (math.sin(gesturePhase) * 0.15))
        : (-0.25 - (math.sin(gesturePhase) * 0.15));
    canvas.rotate(wristRotation);

    // Soft drop shadow for realistic 3D depth
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35 * elevation)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      const Rect.fromLTWH(-28, -20, 56, 75),
      shadowPaint,
    );

    // 1. Palm Base
    final palmRect = const Rect.fromLTWH(-24, -18, 48, 64);
    final palmGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _shadeColor(skinTone, -0.08),
        skinTone,
        _shadeColor(skinTone, 0.06),
      ],
    ).createShader(palmRect);

    final palmPaint = Paint()..shader = palmGradient;
    canvas.drawRRect(
      RRect.fromRectAndRadius(palmRect, const Radius.circular(16)),
      palmPaint,
    );

    // Palm Contour & Life line crease
    final creasePaint = Paint()
      ..color = _shadeColor(skinTone, -0.22).withValues(alpha: 0.45)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final creasePath = Path()
      ..moveTo(isLeft ? 8 : -8, -5)
      ..quadraticBezierTo(0, 15, isLeft ? -12 : 12, 32);
    canvas.drawPath(creasePath, creasePaint);

    // 2. Five Articulated Fingers (Thumb, Index, Middle, Ring, Pinky)
    final fingerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _shadeColor(skinTone, 0.04),
          skinTone,
          _shadeColor(skinTone, -0.15),
        ],
      ).createShader(const Rect.fromLTWH(-30, -55, 60, 60));

    // Thumb (projects outward to side)
    canvas.save();
    canvas.translate(isLeft ? 20 : -20, 8);
    canvas.rotate(isLeft ? 0.65 : -0.65);
    final thumbRect = const Rect.fromLTWH(-7, -26, 14, 30);
    canvas.drawRRect(RRect.fromRectAndRadius(thumbRect, const Radius.circular(7)), fingerPaint);
    // Thumb Nail / Highlight
    _drawNail(canvas, Offset(0, -22), 8, 8, skinTone);
    canvas.restore();

    // Four Fingers Array: [Index, Middle, Ring, Pinky]
    final fingerConfigs = [
      {'x': isLeft ? 13.0 : -13.0, 'len': 38.0, 'w': 10.5, 'angle': isLeft ? 0.12 : -0.12},
      {'x': isLeft ? 4.0 : -4.0, 'len': 44.0, 'w': 11.0, 'angle': isLeft ? 0.02 : -0.02},
      {'x': isLeft ? -5.0 : 5.0, 'len': 40.0, 'w': 10.5, 'angle': isLeft ? -0.06 : 0.06},
      {'x': isLeft ? -14.0 : 14.0, 'len': 32.0, 'w': 9.5, 'angle': isLeft ? -0.16 : 0.16},
    ];

    for (final cfg in fingerConfigs) {
      final fx = cfg['x'] as double;
      final flen = (cfg['len'] as double) * (1.0 - (fingerCurl * 0.25));
      final fw = cfg['w'] as double;
      final fAngle = cfg['angle'] as double;

      canvas.save();
      canvas.translate(fx, -18);
      canvas.rotate(fAngle + (math.sin(gesturePhase) * 0.05));

      final fRect = Rect.fromLTWH(-fw / 2, -flen, fw, flen + 6);
      canvas.drawRRect(RRect.fromRectAndRadius(fRect, Radius.circular(fw / 2)), fingerPaint);

      // Knuckle creases
      final knucklePaint = Paint()
        ..color = _shadeColor(skinTone, -0.18).withValues(alpha: 0.5)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(-fw * 0.35, -flen * 0.45), Offset(fw * 0.35, -flen * 0.45), knucklePaint);
      canvas.drawLine(Offset(-fw * 0.35, -flen * 0.75), Offset(fw * 0.35, -flen * 0.75), knucklePaint);

      // Fingernail
      _drawNail(canvas, Offset(0, -flen + 4), fw * 0.65, 8.0, skinTone);

      canvas.restore();
    }

    canvas.restore();
  }

  static void _drawNail(Canvas canvas, Offset center, double width, double height, Color skinTone) {
    final nailPaint = Paint()
      ..color = _tintColor(skinTone, Colors.white, 0.28).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    final nailRect = Rect.fromCenter(center: center, width: width, height: height);
    canvas.drawRRect(RRect.fromRectAndRadius(nailRect, const Radius.circular(4)), nailPaint);
  }

  static Color _shadeColor(Color color, double factor) {
    final r = (color.r * (1.0 + factor)).clamp(0.0, 1.0);
    final g = (color.g * (1.0 + factor)).clamp(0.0, 1.0);
    final b = (color.b * (1.0 + factor)).clamp(0.0, 1.0);
    return Color.from(alpha: color.a, red: r, green: g, blue: b);
  }

  static Color _tintColor(Color color, Color tint, double weight) {
    return Color.lerp(color, tint, weight) ?? color;
  }
}
