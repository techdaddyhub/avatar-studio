import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/tracking_provider.dart';
import '../../widgets/glass_card.dart';
import '../studio/widgets/avatar_viewport.dart';

class FaceTrackingView extends StatelessWidget {
  const FaceTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final trackingProv = context.watch<TrackingProvider>();
    final state = trackingProv.state;

    return Scaffold(
      backgroundColor: AppColors.bgDarkest,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Real-Time Face Tracking Pipeline',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Local computer vision processing. Webcam frames are analyzed directly on your device.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => trackingProv.toggleTracking(),
                  icon: Icon(
                    state.isTracking ? Icons.stop_circle : Icons.videocam,
                  ),
                  label: Text(
                    state.isTracking
                        ? 'STOP TRACKING'
                        : 'START CAMERA TRACKING',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isTracking
                        ? AppColors.accentRed
                        : AppColors.primaryCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Privacy Guarantee Alert Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accentGreen.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, size: 20, color: AppColors.accentGreen),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Privacy Verified: Camera frames are processed strictly in local memory and are never transmitted over the internet or saved to disk.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content Rows
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Calibration & Hardware Controls
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Camera Configuration',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),

                            if (trackingProv.cameras.isNotEmpty)
                              DropdownButtonFormField<String>(
                                initialValue: trackingProv.selectedCamera?.id,
                                decoration: const InputDecoration(
                                  labelText: 'Select Webcam Device',
                                  border: OutlineInputBorder(),
                                ),
                                items: trackingProv.cameras.map((c) {
                                  return DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  );
                                }).toList(),
                                onChanged: (id) {
                                  final cam = trackingProv.cameras.firstWhere(
                                    (c) => c.id == id,
                                  );
                                  trackingProv.selectCamera(cam);
                                },
                              ),
                            const SizedBox(height: 16),

                            // Calibration Button
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => trackingProv.calibrate(),
                                    icon: const Icon(
                                      Icons.center_focus_strong,
                                      size: 18,
                                    ),
                                    label: const Text('CALIBRATE CENTER POSE'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Smoothing & Sensitivity
                            Text(
                              'Tracking Sensitivity: ${state.sensitivity.toStringAsFixed(1)}x',
                            ),
                            Slider(
                              value: state.sensitivity,
                              min: 0.5,
                              max: 2.0,
                              onChanged: (v) => trackingProv.setSensitivity(v),
                            ),

                            Text(
                              'Pose Smoothing (Kalman / EMA): ${state.smoothing.toStringAsFixed(2)}',
                            ),
                            Slider(
                              value: state.smoothing,
                              min: 0.1,
                              max: 0.9,
                              onChanged: (v) => trackingProv.setSmoothing(v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Manual Override Mode (for low-spec or no-webcam computers)
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Manual Mode (Core i3 / No-Webcam)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: state.isManualMode,
                                  onChanged: (_) =>
                                      trackingProv.toggleManualMode(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Allows manual slider adjustments for head pitch, yaw, roll, eye blinking, and smile without requiring webcam processing.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (state.isManualMode) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Pitch (Look Up/Down): ${state.pitch.toStringAsFixed(2)}',
                              ),
                              Slider(
                                value: state.pitch,
                                min: -0.5,
                                max: 0.5,
                                onChanged: (v) =>
                                    trackingProv.setManualValues(pitch: v),
                              ),
                              Text(
                                'Yaw (Look Left/Right): ${state.yaw.toStringAsFixed(2)}',
                              ),
                              Slider(
                                value: state.yaw,
                                min: -0.6,
                                max: 0.6,
                                onChanged: (v) =>
                                    trackingProv.setManualValues(yaw: v),
                              ),
                              Text('Smile: ${(state.smile * 100).toInt()}%'),
                              Slider(
                                value: state.smile,
                                min: 0.0,
                                max: 1.0,
                                onChanged: (v) =>
                                    trackingProv.setManualValues(smile: v),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Right: Real-time Telemetry & Viewport
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      GlassCard(
                        height: 340,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tracking Visualizer',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Expanded(child: AvatarViewport()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Telemetry Stats
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Landmark Estimation Telemetry',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTelemetryPill(
                              'Confidence Score',
                              '${(state.confidence * 100).toStringAsFixed(1)}%',
                            ),
                            _buildTelemetryPill(
                              'Tracking Frame Rate',
                              '${state.fps.toStringAsFixed(0)} FPS',
                            ),
                            _buildTelemetryPill(
                              'Head Rotation Pitch',
                              state.pitch.toStringAsFixed(3),
                            ),
                            _buildTelemetryPill(
                              'Head Rotation Yaw',
                              state.yaw.toStringAsFixed(3),
                            ),
                            _buildTelemetryPill(
                              'Head Rotation Roll',
                              state.roll.toStringAsFixed(3),
                            ),
                            _buildTelemetryPill(
                              'Face Lost Recovery',
                              'Automatic (EMA state preserved)',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryPill(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              color: AppColors.primaryCyan,
            ),
          ),
        ],
      ),
    );
  }
}
