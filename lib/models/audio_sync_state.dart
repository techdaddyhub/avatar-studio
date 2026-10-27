class AudioSyncState {
  final bool isListening;
  final bool isMuted;
  final double inputLevelDb; // dBFS [-60.0 to 0.0]
  final double normalizedLevel; // [0.0 to 1.0]
  final String currentViseme; // 'sil', 'aa', 'ee', 'oh', 'ch', 'm'
  final double mouthOpenAmount; // [0.0 to 1.0]
  final double mouthWidthAmount; // [-0.5 rounded to 0.5 spread]
  final double sensitivity;
  final double vadThreshold; // in dBFS
  final bool isVoiceActive;
  final String? selectedMicId;
  final List<String> availableMics;

  const AudioSyncState({
    this.isListening = false,
    this.isMuted = false,
    this.inputLevelDb = -60.0,
    this.normalizedLevel = 0.0,
    this.currentViseme = 'sil',
    this.mouthOpenAmount = 0.0,
    this.mouthWidthAmount = 0.0,
    this.sensitivity = 1.35,
    this.vadThreshold = -42.0,
    this.isVoiceActive = false,
    this.selectedMicId,
    this.availableMics = const [],
  });

  AudioSyncState copyWith({
    bool? isListening,
    bool? isMuted,
    double? inputLevelDb,
    double? normalizedLevel,
    String? currentViseme,
    double? mouthOpenAmount,
    double? mouthWidthAmount,
    double? sensitivity,
    double? vadThreshold,
    bool? isVoiceActive,
    String? selectedMicId,
    List<String>? availableMics,
  }) {
    return AudioSyncState(
      isListening: isListening ?? this.isListening,
      isMuted: isMuted ?? this.isMuted,
      inputLevelDb: inputLevelDb ?? this.inputLevelDb,
      normalizedLevel: normalizedLevel ?? this.normalizedLevel,
      currentViseme: currentViseme ?? this.currentViseme,
      mouthOpenAmount: mouthOpenAmount ?? this.mouthOpenAmount,
      mouthWidthAmount: mouthWidthAmount ?? this.mouthWidthAmount,
      sensitivity: sensitivity ?? this.sensitivity,
      vadThreshold: vadThreshold ?? this.vadThreshold,
      isVoiceActive: isVoiceActive ?? this.isVoiceActive,
      selectedMicId: selectedMicId ?? this.selectedMicId,
      availableMics: availableMics ?? this.availableMics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isListening': isListening,
      'isMuted': isMuted,
      'inputLevelDb': inputLevelDb,
      'normalizedLevel': normalizedLevel,
      'currentViseme': currentViseme,
      'mouthOpenAmount': mouthOpenAmount,
      'mouthWidthAmount': mouthWidthAmount,
      'isVoiceActive': isVoiceActive,
    };
  }
}
