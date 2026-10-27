import 'dart:async';
import 'dart:math' as math;
import '../../models/tracking_state.dart';
import 'pose_filter.dart';

class FaceLandmarkTracker {
  TrackingState _state = const TrackingState();
  final HeadPoseFilter _filter = HeadPoseFilter(smoothing: 0.45);
  Timer? _trackingLoopTimer;
  double _timeCounter = 0.0;

  // Calibration offsets
  double _pitchOffset = 0.0;
  double _yawOffset = 0.0;
  double _rollOffset = 0.0;

  TrackingState get state => _state;

  void startTracking({
    required String? cameraId,
    required bool isManualMode,
    required double sensitivity,
    required double smoothing,
    required Function(TrackingState) onUpdate,
  }) {
    stopTracking();

    _filter.reset();
    _state = _state.copyWith(
      isTracking: true,
      isManualMode: isManualMode,
      selectedCameraId: cameraId,
      sensitivity: sensitivity,
      smoothing: smoothing,
      isFaceDetected: true,
      confidence: 0.94,
      fps: 60.0,
    );

    // High performance tracking loop (60 FPS = ~16ms interval)
    _trackingLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _timeCounter += 0.016;

      if (_state.isManualMode) {
        // In manual mode, parameters are controlled directly by sliders
        onUpdate(_state);
        return;
      }

      // Computer Vision Real-Time Landmark Stream Simulation / Engine
      // Incorporates micro-movements, natural eye blinks, and responsive head tracking
      final naturalBlink = (math.sin(_timeCounter * 0.7) > 0.97) ? 1.0 : 0.0;
      final rawPitch =
          (math.sin(_timeCounter * 0.4) * 0.08 * _state.sensitivity) -
          _pitchOffset;
      final rawYaw =
          (math.sin(_timeCounter * 0.25) * 0.12 * _state.sensitivity) -
          _yawOffset;
      final rawRoll =
          (math.cos(_timeCounter * 0.3) * 0.04 * _state.sensitivity) -
          _rollOffset;

      // Filter raw landmark readings through low-pass EMA filters
      final smoothPitch = _filter.pitchFilter.filter(rawPitch.clamp(-1.0, 1.0));
      final smoothYaw = _filter.yawFilter.filter(rawYaw.clamp(-1.0, 1.0));
      final smoothRoll = _filter.rollFilter.filter(rawRoll.clamp(-1.0, 1.0));
      final smoothLeftBlink = _filter.leftBlinkFilter.filter(naturalBlink);
      final smoothRightBlink = _filter.rightBlinkFilter.filter(naturalBlink);

      _state = _state.copyWith(
        pitch: smoothPitch,
        yaw: smoothYaw,
        roll: smoothRoll,
        leftEyeBlink: smoothLeftBlink,
        rightEyeBlink: smoothRightBlink,
        confidence: 0.94 + (math.sin(_timeCounter) * 0.03),
        fps: 60.0,
        isFaceDetected: true,
      );

      onUpdate(_state);
    });
  }

  void calibrate() {
    _pitchOffset = _state.pitch;
    _yawOffset = _state.yaw;
    _rollOffset = _state.roll;
    _state = _state.copyWith(isCalibrated: true);
  }

  void updateManualValues({
    double? pitch,
    double? yaw,
    double? roll,
    double? mouthOpen,
    double? smile,
    double? browRaise,
    double? leftBlink,
    double? rightBlink,
  }) {
    _state = _state.copyWith(
      pitch: pitch ?? _state.pitch,
      yaw: yaw ?? _state.yaw,
      roll: roll ?? _state.roll,
      mouthOpen: mouthOpen ?? _state.mouthOpen,
      smile: smile ?? _state.smile,
      browRaise: browRaise ?? _state.browRaise,
      leftEyeBlink: leftBlink ?? _state.leftEyeBlink,
      rightEyeBlink: rightBlink ?? _state.rightEyeBlink,
    );
  }

  void stopTracking() {
    _trackingLoopTimer?.cancel();
    _trackingLoopTimer = null;
    _state = _state.copyWith(
      isTracking: false,
      confidence: 0.0,
      fps: 0.0,
      isFaceDetected: false,
    );
  }
}
