import 'dart:io';

enum HardwareTier { economy, balanced, quality }

class HardwareSpecs {
  final int processorCount;
  final String osName;
  final HardwareTier recommendedTier;
  final String description;

  const HardwareSpecs({
    required this.processorCount,
    required this.osName,
    required this.recommendedTier,
    required this.description,
  });
}

class HardwareDetector {
  HardwareDetector._();

  static HardwareSpecs detectSystem() {
    final cpuCores = Platform.numberOfProcessors;
    final os = Platform.operatingSystem;

    // Adaptive evaluation:
    // Core i3 (typically 2-4 logical cores): Economy or Balanced
    // 6-8 cores: Balanced
    // 8+ cores: Quality
    HardwareTier tier;
    String desc;

    if (cpuCores <= 4) {
      tier = HardwareTier.economy;
      desc =
          'Detected $cpuCores logical cores. Economy mode recommended for smooth performance on modest hardware.';
    } else if (cpuCores <= 8) {
      tier = HardwareTier.balanced;
      desc =
          'Detected $cpuCores logical cores. Balanced mode active for sharp 720p/1080p rendering and low latency.';
    } else {
      tier = HardwareTier.quality;
      desc =
          'Detected $cpuCores logical cores. Quality mode active with advanced lighting, antialiasing, and 60 FPS.';
    }

    return HardwareSpecs(
      processorCount: cpuCores,
      osName: os,
      recommendedTier: tier,
      description: desc,
    );
  }
}
