import '../core/utils/hardware_detector.dart';

class HardwareProfile {
  final HardwareTier tier;
  final int targetFps;
  final double currentFps;
  final double frameTimeMs;
  final int droppedFrames;
  final double cpuPercent;
  final double memoryMb;
  final bool autoAdapt;
  final bool isAntialiasingEnabled;
  final double renderScale;

  const HardwareProfile({
    this.tier = HardwareTier.balanced,
    this.targetFps = 60,
    this.currentFps = 60.0,
    this.frameTimeMs = 16.6,
    this.droppedFrames = 0,
    this.cpuPercent = 4.2,
    this.memoryMb = 148.0,
    this.autoAdapt = true,
    this.isAntialiasingEnabled = true,
    this.renderScale = 1.0,
  });

  HardwareProfile copyWith({
    HardwareTier? tier,
    int? targetFps,
    double? currentFps,
    double? frameTimeMs,
    int? droppedFrames,
    double? cpuPercent,
    double? memoryMb,
    bool? autoAdapt,
    bool? isAntialiasingEnabled,
    double? renderScale,
  }) {
    return HardwareProfile(
      tier: tier ?? this.tier,
      targetFps: targetFps ?? this.targetFps,
      currentFps: currentFps ?? this.currentFps,
      frameTimeMs: frameTimeMs ?? this.frameTimeMs,
      droppedFrames: droppedFrames ?? this.droppedFrames,
      cpuPercent: cpuPercent ?? this.cpuPercent,
      memoryMb: memoryMb ?? this.memoryMb,
      autoAdapt: autoAdapt ?? this.autoAdapt,
      isAntialiasingEnabled:
          isAntialiasingEnabled ?? this.isAntialiasingEnabled,
      renderScale: renderScale ?? this.renderScale,
    );
  }

  String get tierLabel {
    switch (tier) {
      case HardwareTier.economy:
        return 'Economy (Optimized Core i3 / Low-spec)';
      case HardwareTier.balanced:
        return 'Balanced (Recommended 720p/1080p)';
      case HardwareTier.quality:
        return 'Quality (Full 60 FPS / High Fidelity)';
    }
  }

  String get tierSummary {
    switch (tier) {
      case HardwareTier.economy:
        return 'Reduced post-processing, 30 FPS cap, low CPU/RAM footprint, basic tracking interpolation.';
      case HardwareTier.balanced:
        return 'Adaptive 60 FPS, smooth micro-expressions, balanced lighting, crisp 1080p output.';
      case HardwareTier.quality:
        return 'Sub-pixel antialiasing, high dynamic range lighting, 60 FPS output, uncompressed alpha.';
    }
  }
}
