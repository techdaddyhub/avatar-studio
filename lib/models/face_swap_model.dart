enum FaceMaskType { fullContour, landmarksWarp, ovalFeathered }

class FaceSwapTarget {
  final String id;
  final String name;
  final String category;
  final String description;
  final String? imagePath;
  final String? assetPath;
  final String skinToneHex;
  final bool isCustom;
  final DateTime createdAt;

  const FaceSwapTarget({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.imagePath,
    this.assetPath,
    this.skinToneHex = '#F5D0B5',
    this.isCustom = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'description': description,
    'imagePath': imagePath,
    'assetPath': assetPath,
    'skinToneHex': skinToneHex,
    'isCustom': isCustom,
    'createdAt': createdAt.toIso8601String(),
  };

  factory FaceSwapTarget.fromJson(Map<String, dynamic> json) => FaceSwapTarget(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String? ?? 'General',
    description: json['description'] as String? ?? '',
    imagePath: json['imagePath'] as String?,
    assetPath: json['assetPath'] as String?,
    skinToneHex: json['skinToneHex'] as String? ?? '#F5D0B5',
    isCustom: json['isCustom'] as bool? ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
  );
}

class FaceSwapSettings {
  final double blendOpacity;
  final bool skinToneHarmonization;
  final double edgeFeathering;
  final double expressionSensitivity;
  final bool eyeBlinkTracking;
  final bool mouthSyncTracking;
  final int fpsTarget;
  final FaceMaskType maskType;
  final bool preserveOriginalHair;

  const FaceSwapSettings({
    this.blendOpacity = 0.95,
    this.skinToneHarmonization = true,
    this.edgeFeathering = 14.0,
    this.expressionSensitivity = 1.15,
    this.eyeBlinkTracking = true,
    this.mouthSyncTracking = true,
    this.fpsTarget = 60,
    this.maskType = FaceMaskType.landmarksWarp,
    this.preserveOriginalHair = true,
  });

  FaceSwapSettings copyWith({
    double? blendOpacity,
    bool? skinToneHarmonization,
    double? edgeFeathering,
    double? expressionSensitivity,
    bool? eyeBlinkTracking,
    bool? mouthSyncTracking,
    int? fpsTarget,
    FaceMaskType? maskType,
    bool? preserveOriginalHair,
  }) {
    return FaceSwapSettings(
      blendOpacity: blendOpacity ?? this.blendOpacity,
      skinToneHarmonization:
          skinToneHarmonization ?? this.skinToneHarmonization,
      edgeFeathering: edgeFeathering ?? this.edgeFeathering,
      expressionSensitivity:
          expressionSensitivity ?? this.expressionSensitivity,
      eyeBlinkTracking: eyeBlinkTracking ?? this.eyeBlinkTracking,
      mouthSyncTracking: mouthSyncTracking ?? this.mouthSyncTracking,
      fpsTarget: fpsTarget ?? this.fpsTarget,
      maskType: maskType ?? this.maskType,
      preserveOriginalHair: preserveOriginalHair ?? this.preserveOriginalHair,
    );
  }

  Map<String, dynamic> toJson() => {
    'blendOpacity': blendOpacity,
    'skinToneHarmonization': skinToneHarmonization,
    'edgeFeathering': edgeFeathering,
    'expressionSensitivity': expressionSensitivity,
    'eyeBlinkTracking': eyeBlinkTracking,
    'mouthSyncTracking': mouthSyncTracking,
    'fpsTarget': fpsTarget,
    'maskType': maskType.name,
    'preserveOriginalHair': preserveOriginalHair,
  };

  factory FaceSwapSettings.fromJson(Map<String, dynamic> json) =>
      FaceSwapSettings(
        blendOpacity: (json['blendOpacity'] as num?)?.toDouble() ?? 0.95,
        skinToneHarmonization: json['skinToneHarmonization'] as bool? ?? true,
        edgeFeathering: (json['edgeFeathering'] as num?)?.toDouble() ?? 14.0,
        expressionSensitivity:
            (json['expressionSensitivity'] as num?)?.toDouble() ?? 1.15,
        eyeBlinkTracking: json['eyeBlinkTracking'] as bool? ?? true,
        mouthSyncTracking: json['mouthSyncTracking'] as bool? ?? true,
        fpsTarget: json['fpsTarget'] as int? ?? 60,
        maskType: FaceMaskType.values.firstWhere(
          (m) => m.name == json['maskType'],
          orElse: () => FaceMaskType.landmarksWarp,
        ),
        preserveOriginalHair: json['preserveOriginalHair'] as bool? ?? true,
      );
}

class FaceSwapState {
  final bool isSwapping;
  final bool isFaceDetected;
  final double confidence;
  final double currentFps;
  final FaceSwapTarget? activeTarget;
  final FaceSwapSettings settings;
  final String statusMessage;

  const FaceSwapState({
    this.isSwapping = false,
    this.isFaceDetected = false,
    this.confidence = 0.0,
    this.currentFps = 0.0,
    this.activeTarget,
    this.settings = const FaceSwapSettings(),
    this.statusMessage = 'AI Face Swap Standby. Select target face to begin.',
  });

  FaceSwapState copyWith({
    bool? isSwapping,
    bool? isFaceDetected,
    double? confidence,
    double? currentFps,
    FaceSwapTarget? activeTarget,
    FaceSwapSettings? settings,
    String? statusMessage,
  }) {
    return FaceSwapState(
      isSwapping: isSwapping ?? this.isSwapping,
      isFaceDetected: isFaceDetected ?? this.isFaceDetected,
      confidence: confidence ?? this.confidence,
      currentFps: currentFps ?? this.currentFps,
      activeTarget: activeTarget ?? this.activeTarget,
      settings: settings ?? this.settings,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

