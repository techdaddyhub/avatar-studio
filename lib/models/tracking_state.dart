class TrackingState {
  final bool isTracking;
  final bool isManualMode;
  final bool isFaceDetected;
  final double confidence;
  final double fps;

  // Head Pose
  final double pitch; // up / down [-1.0, 1.0]
  final double yaw; // left / right [-1.0, 1.0]
  final double roll; // tilt [-1.0, 1.0]

  // Eyes & Eyebrows
  final double leftEyeBlink; // [0.0 open, 1.0 closed]
  final double rightEyeBlink; // [0.0 open, 1.0 closed]
  final double browRaise; // [0.0 neutral, 1.0 raised]

  // Mouth & Expression
  final double mouthOpen; // [0.0 closed, 1.0 open]
  final double smile; // [0.0 neutral, 1.0 full smile]

  // Calibration & Filter parameters
  final double smoothing;
  final double sensitivity;
  final bool isCalibrated;

  // Devices
  final String? selectedCameraId;
  final List<String> availableCameras;

  const TrackingState({
    this.isTracking = false,
    this.isManualMode = false,
    this.isFaceDetected = false,
    this.confidence = 0.0,
    this.fps = 0.0,
    this.pitch = 0.0,
    this.yaw = 0.0,
    this.roll = 0.0,
    this.leftEyeBlink = 0.0,
    this.rightEyeBlink = 0.0,
    this.browRaise = 0.0,
    this.mouthOpen = 0.0,
    this.smile = 0.0,
    this.smoothing = 0.65,
    this.sensitivity = 1.2,
    this.isCalibrated = false,
    this.selectedCameraId,
    this.availableCameras = const [],
  });

  TrackingState copyWith({
    bool? isTracking,
    bool? isManualMode,
    bool? isFaceDetected,
    double? confidence,
    double? fps,
    double? pitch,
    double? yaw,
    double? roll,
    double? leftEyeBlink,
    double? rightEyeBlink,
    double? browRaise,
    double? mouthOpen,
    double? smile,
    double? smoothing,
    double? sensitivity,
    bool? isCalibrated,
    String? selectedCameraId,
    List<String>? availableCameras,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      isManualMode: isManualMode ?? this.isManualMode,
      isFaceDetected: isFaceDetected ?? this.isFaceDetected,
      confidence: confidence ?? this.confidence,
      fps: fps ?? this.fps,
      pitch: pitch ?? this.pitch,
      yaw: yaw ?? this.yaw,
      roll: roll ?? this.roll,
      leftEyeBlink: leftEyeBlink ?? this.leftEyeBlink,
      rightEyeBlink: rightEyeBlink ?? this.rightEyeBlink,
      browRaise: browRaise ?? this.browRaise,
      mouthOpen: mouthOpen ?? this.mouthOpen,
      smile: smile ?? this.smile,
      smoothing: smoothing ?? this.smoothing,
      sensitivity: sensitivity ?? this.sensitivity,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      selectedCameraId: selectedCameraId ?? this.selectedCameraId,
      availableCameras: availableCameras ?? this.availableCameras,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isTracking': isTracking,
      'isFaceDetected': isFaceDetected,
      'confidence': confidence,
      'fps': fps,
      'pitch': pitch,
      'yaw': yaw,
      'roll': roll,
      'leftEyeBlink': leftEyeBlink,
      'rightEyeBlink': rightEyeBlink,
      'browRaise': browRaise,
      'mouthOpen': mouthOpen,
      'smile': smile,
    };
  }
}
