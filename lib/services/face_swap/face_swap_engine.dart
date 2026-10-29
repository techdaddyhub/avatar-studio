import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/face_swap_model.dart';
import '../../models/tracking_state.dart';
import '../../models/audio_sync_state.dart';
import '../tracking/pose_filter.dart';

class FaceSwapFrame {
  final Rect faceBoundingBox;
  final Offset leftEye;
  final Offset rightEye;
  final Offset noseTip;
  final Offset mouthCenter;
  final double mouthOpening;
  final double leftBlink;
  final double rightBlink;
  final double headPitch;
  final double headYaw;
  final double headRoll;
  final Color skinTone;
  final double blendAlpha;

  const FaceSwapFrame({
    required this.faceBoundingBox,
    required this.leftEye,
    required this.rightEye,
    required this.noseTip,
    required this.mouthCenter,
    required this.mouthOpening,
    required this.leftBlink,
    required this.rightBlink,
    required this.headPitch,
    required this.headYaw,
    required this.headRoll,
    required this.skinTone,
    required this.blendAlpha,
  });
}

class FaceSwapEngine {
  final HeadPoseFilter _poseFilter = HeadPoseFilter(smoothing: 0.35);
  final PoseFilter _mouthFilter = PoseFilter(initialValue: 0.0, smoothingFactor: 0.25);
  final PoseFilter _leftEyeFilter = PoseFilter(initialValue: 0.0, smoothingFactor: 0.2);
  final PoseFilter _rightEyeFilter = PoseFilter(initialValue: 0.0, smoothingFactor: 0.2);

  Timer? _processingTimer;

  bool get isRunning => _processingTimer != null;

  void start({
    required FaceSwapTarget target,
    required FaceSwapSettings settings,
    required TrackingState Function() getTracking,
    required AudioSyncState Function() getAudio,
    required Function(FaceSwapFrame frame) onFrameReady,
  }) {
    stop();
    _poseFilter.reset();

    final intervalMs = settings.fpsTarget == 30 ? 33 : 16;
    _processingTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      final tracking = getTracking();
      final audio = getAudio();

      // 1. Process head orientation with filter
      final smoothPitch = _poseFilter.pitchFilter.filter(tracking.pitch);
      final smoothYaw = _poseFilter.yawFilter.filter(tracking.yaw);
      final smoothRoll = _poseFilter.rollFilter.filter(tracking.roll);

      // 2. Combine camera tracking blink with natural blink & acoustic viseme
      final rawLeftBlink = settings.eyeBlinkTracking ? tracking.leftEyeBlink : 0.0;
      final rawRightBlink = settings.eyeBlinkTracking ? tracking.rightEyeBlink : 0.0;
      final smoothLeftBlink = _leftEyeFilter.filter(rawLeftBlink);
      final smoothRightBlink = _rightEyeFilter.filter(rawRightBlink);

      // 3. Combine camera mouth tracking + acoustic viseme mouth openness
      double combinedMouth = 0.0;
      if (settings.mouthSyncTracking) {
        final audioVisemeMouth = audio.mouthOpenAmount * 1.25;
        final camMouth = tracking.mouthOpen;
        combinedMouth = math.max(audioVisemeMouth, camMouth) * settings.expressionSensitivity;
      }
      final smoothMouth = _mouthFilter.filter(combinedMouth.clamp(0.0, 1.0));

      // 4. Compute dynamic transformed face landmark geometry in canvas space (1000x1000 standard coordinate space)
      final centerX = 500.0 + (smoothYaw * 120.0);
      final centerY = 450.0 + (smoothPitch * 90.0);
      const faceWidth = 320.0;
      const faceHeight = 420.0;

      final faceRect = Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: faceWidth,
        height: faceHeight,
      );

      // Eye positions with head roll rotation
      final eyeOffsetX = 65.0;
      final eyeOffsetY = -45.0;
      final rollRad = smoothRoll * (math.pi / 180.0) * 15.0;

      final leftEyeRotated = Offset(
        centerX - (eyeOffsetX * math.cos(rollRad)) - (eyeOffsetY * math.sin(rollRad)),
        centerY - (eyeOffsetX * math.sin(rollRad)) + (eyeOffsetY * math.cos(rollRad)),
      );

      final rightEyeRotated = Offset(
        centerX + (eyeOffsetX * math.cos(rollRad)) - (eyeOffsetY * math.sin(rollRad)),
        centerY + (eyeOffsetX * math.sin(rollRad)) + (eyeOffsetY * math.cos(rollRad)),
      );

      final noseTip = Offset(
        centerX + (smoothYaw * 20.0),
        centerY + 15.0 + (smoothPitch * 15.0),
      );

      final mouthCenter = Offset(
        centerX + (smoothYaw * 10.0),
        centerY + 105.0 + (smoothPitch * 12.0),
      );

      // Base skin color extracted from target preset
      Color baseSkinColor = const Color(0xFFF0CCA8);
      try {
        final hex = target.skinToneHex.replaceFirst('#', '');
        baseSkinColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}

      final frame = FaceSwapFrame(
        faceBoundingBox: faceRect,
        leftEye: leftEyeRotated,
        rightEye: rightEyeRotated,
        noseTip: noseTip,
        mouthCenter: mouthCenter,
        mouthOpening: smoothMouth,
        leftBlink: smoothLeftBlink,
        rightBlink: smoothRightBlink,
        headPitch: smoothPitch,
        headYaw: smoothYaw,
        headRoll: smoothRoll,
        skinTone: baseSkinColor,
        blendAlpha: settings.blendOpacity.clamp(0.1, 1.0),
      );

      onFrameReady(frame);
    });
  }

  void stop() {
    _processingTimer?.cancel();
    _processingTimer = null;
  }
}
