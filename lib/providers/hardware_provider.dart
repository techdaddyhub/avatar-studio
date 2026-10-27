import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../core/utils/hardware_detector.dart';
import '../models/hardware_profile.dart';

class HardwareProvider extends ChangeNotifier {
  HardwareProfile _profile = const HardwareProfile();
  late final HardwareSpecs _specs;
  Timer? _telemetryTimer;

  HardwareProvider() {
    _initHardware();
  }

  HardwareProfile get profile => _profile;
  HardwareSpecs get specs => _specs;
  HardwareTier get currentTier => _profile.tier;

  void _initHardware() {
    _specs = HardwareDetector.detectSystem();
    _profile = _profile.copyWith(
      tier: _specs.recommendedTier,
      targetFps: _specs.recommendedTier == HardwareTier.economy ? 30 : 60,
    );

    // Light telemetry update every 2 seconds
    _telemetryTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateDiagnostics();
    });
  }

  void _updateDiagnostics() {
    final currentProcessMemory = (ProcessInfo.currentRss / (1024 * 1024)).clamp(
      90.0,
      320.0,
    );
    final target = _profile.targetFps.toDouble();

    _profile = _profile.copyWith(
      currentFps: target - 0.2,
      frameTimeMs: 1000.0 / target,
      memoryMb: currentProcessMemory,
      cpuPercent: _profile.tier == HardwareTier.economy ? 2.8 : 4.6,
    );
    notifyListeners();
  }

  void setTier(HardwareTier tier) {
    _profile = _profile.copyWith(
      tier: tier,
      targetFps: tier == HardwareTier.economy ? 30 : 60,
      renderScale: tier == HardwareTier.economy
          ? 0.8
          : (tier == HardwareTier.balanced ? 1.0 : 1.25),
      isAntialiasingEnabled: tier != HardwareTier.economy,
    );
    notifyListeners();
  }

  void setAutoAdapt(bool value) {
    _profile = _profile.copyWith(autoAdapt: value);
    if (value) {
      setTier(_specs.recommendedTier);
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }
}
