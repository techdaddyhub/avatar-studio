class AppConstants {
  AppConstants._();

  static const String appName = 'Avatar Studio';
  static const String appVersion = '2.4.0';
  static const String appBuildNumber = '2026.1';

  // OBS Local Server defaults
  static const int defaultObsServerPort = 8088;
  static const String defaultObsHost = '127.0.0.1';
  static const int defaultObsWsPort = 4455;

  // Tracking defaults
  static const double defaultTrackingSmoothing = 0.65;
  static const double defaultTrackingSensitivity = 1.2;
  static const int defaultTargetFps = 60;

  // Audio Lip Sync defaults
  static const double defaultVadThreshold = -42.0; // dBFS
  static const double defaultLipSyncSensitivity = 1.35;

  // Hardware Tiers
  static const int economyMaxFps = 30;
  static const int balancedMaxFps = 60;
  static const int qualityMaxFps = 60;
}
