import 'package:flutter/material.dart';
import '../models/tracking_state.dart';
import '../services/rendering/expression_controller.dart';
import '../services/tracking/camera_service.dart';
import '../services/tracking/face_landmark_tracker.dart';

class TrackingProvider extends ChangeNotifier {
  final FaceLandmarkTracker _tracker = FaceLandmarkTracker();
  List<CameraDeviceInfo> _cameras = [];
  CameraDeviceInfo? _selectedCamera;

  TrackingState _state = const TrackingState();
  AvatarExpression _activeExpression = AvatarExpression.neutral;

  TrackingProvider() {
    _initCameras();
  }

  TrackingState get state => _state;
  List<CameraDeviceInfo> get cameras => _cameras;
  CameraDeviceInfo? get selectedCamera => _selectedCamera;
  AvatarExpression get activeExpression => _activeExpression;
  bool get isTracking => _state.isTracking;

  Future<void> _initCameras() async {
    _cameras = await CameraService.getAvailableCameras();
    if (_cameras.isNotEmpty) {
      _selectedCamera = _cameras.first;
    }
    notifyListeners();
  }

  void selectCamera(CameraDeviceInfo camera) {
    _selectedCamera = camera;
    if (_state.isTracking) {
      startTracking();
    } else {
      notifyListeners();
    }
  }

  void startTracking() {
    _tracker.startTracking(
      cameraId: _selectedCamera?.id,
      isManualMode: _state.isManualMode,
      sensitivity: _state.sensitivity,
      smoothing: _state.smoothing,
      onUpdate: (updatedState) {
        _state = updatedState;
        notifyListeners();
      },
    );
  }

  void stopTracking() {
    _tracker.stopTracking();
    _state = _tracker.state;
    notifyListeners();
  }

  void toggleTracking() {
    if (_state.isTracking) {
      stopTracking();
    } else {
      startTracking();
    }
  }

  void toggleManualMode() {
    _state = _state.copyWith(isManualMode: !_state.isManualMode);
    if (_state.isTracking) {
      startTracking();
    } else {
      notifyListeners();
    }
  }

  void calibrate() {
    _tracker.calibrate();
    _state = _tracker.state;
    notifyListeners();
  }

  void setSensitivity(double value) {
    _state = _state.copyWith(sensitivity: value);
    if (_state.isTracking) {
      _tracker.startTracking(
        cameraId: _selectedCamera?.id,
        isManualMode: _state.isManualMode,
        sensitivity: value,
        smoothing: _state.smoothing,
        onUpdate: (u) {
          _state = u;
          notifyListeners();
        },
      );
    } else {
      notifyListeners();
    }
  }

  void setSmoothing(double value) {
    _state = _state.copyWith(smoothing: value);
    if (_state.isTracking) {
      _tracker.startTracking(
        cameraId: _selectedCamera?.id,
        isManualMode: _state.isManualMode,
        sensitivity: _state.sensitivity,
        smoothing: value,
        onUpdate: (u) {
          _state = u;
          notifyListeners();
        },
      );
    } else {
      notifyListeners();
    }
  }

  void setManualValues({
    double? pitch,
    double? yaw,
    double? roll,
    double? mouthOpen,
    double? smile,
    double? browRaise,
  }) {
    _tracker.updateManualValues(
      pitch: pitch,
      yaw: yaw,
      roll: roll,
      mouthOpen: mouthOpen,
      smile: smile,
      browRaise: browRaise,
    );
    _state = _tracker.state;
    notifyListeners();
  }

  void triggerExpression(AvatarExpression expression) {
    _activeExpression = expression;
    final values = ExpressionValues.getValues(expression);
    _tracker.updateManualValues(
      pitch: values.pitch,
      roll: values.roll,
      mouthOpen: values.mouthOpen,
      smile: values.smile,
      browRaise: values.browRaise,
      leftBlink: values.leftBlink,
      rightBlink: values.rightBlink,
    );
    _state = _tracker.state;
    notifyListeners();
  }
}
