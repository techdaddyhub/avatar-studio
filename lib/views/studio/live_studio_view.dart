import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/audio_sync_provider.dart';
import '../../providers/obs_provider.dart';
import '../../providers/hardware_provider.dart';
import '../../services/rendering/expression_controller.dart';
import '../../widgets/glass_card.dart';
import 'widgets/avatar_viewport.dart';

class LiveStudioView extends StatefulWidget {
  const LiveStudioView({super.key});

  @override
  State<LiveStudioView> createState() => _LiveStudioViewState();
}

class _LiveStudioViewState extends State<LiveStudioView> {
  bool _showCheckerboard = true;

  @override
  Widget build(BuildContext context) {
    final avatarProv = context.watch<AvatarProvider>();
    final trackingProv = context.watch<TrackingProvider>();
    final audioProv = context.watch<AudioSyncProvider>();
    final obsProv = context.watch<ObsProvider>();
    final hwProv = context.watch<HardwareProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDarkest,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Toolbar
            _buildTopToolbar(avatarProv, trackingProv, audioProv, obsProv),
            const SizedBox(height: 12),

            // Main Workspace Layout
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Control Panel (Tracking & Audio)
                  SizedBox(
                    width: 270,
                    child: _buildLeftControlPanel(trackingProv, audioProv),
                  ),
                  const SizedBox(width: 12),

                  // Center Viewport
                  Expanded(
                    child: _buildCenterViewport(avatarProv, obsProv, hwProv),
                  ),
                  const SizedBox(width: 12),

                  // Right Control Panel (Expressions & Lighting)
                  SizedBox(
                    width: 270,
                    child: _buildRightControlPanel(avatarProv, trackingProv),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopToolbar(
    AvatarProvider avatarProv,
    TrackingProvider trackingProv,
    AudioSyncProvider audioProv,
    ObsProvider obsProv,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          // Tracking Master Toggle
          ElevatedButton.icon(
            onPressed: () => trackingProv.toggleTracking(),
            icon: Icon(
              trackingProv.isTracking ? Icons.stop_circle : Icons.videocam,
              size: 16,
            ),
            label: Text(
              trackingProv.isTracking ? 'STOP TRACKING' : 'START TRACKING',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: trackingProv.isTracking
                  ? AppColors.accentRed
                  : AppColors.primaryCyan,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 10),

          // Audio Sync Toggle
          OutlinedButton.icon(
            onPressed: () => audioProv.toggleListening(),
            icon: Icon(
              audioProv.isListening ? Icons.mic : Icons.mic_off,
              size: 16,
              color: audioProv.isListening
                  ? AppColors.statusOnline
                  : AppColors.textSecondary,
            ),
            label: Text(
              audioProv.isListening ? 'VOICE SYNC ON' : 'VOICE SYNC OFF',
            ),
          ),
          const SizedBox(width: 10),

          // OBS Broadcast Toggle
          OutlinedButton.icon(
            onPressed: () {
              obsProv.toggleServer(
                avatarProvider: avatarProv,
                trackingProvider: trackingProv,
                audioProvider: audioProv,
              );
            },
            icon: Icon(
              obsProv.isServerRunning ? Icons.cast_connected : Icons.cast,
              size: 16,
              color: obsProv.isServerRunning
                  ? AppColors.statusOnline
                  : AppColors.textSecondary,
            ),
            label: Text(
              obsProv.isServerRunning ? 'OBS STREAM: LIVE' : 'OBS STREAM: OFF',
            ),
          ),

          const Spacer(),

          // Alpha Checkerboard Toggle
          IconButton(
            icon: Icon(
              _showCheckerboard ? Icons.grid_on : Icons.grid_off,
              size: 18,
              color: _showCheckerboard
                  ? AppColors.primaryCyan
                  : AppColors.textMuted,
            ),
            tooltip: 'Toggle Transparency Grid',
            onPressed: () {
              setState(() {
                _showCheckerboard = !_showCheckerboard;
              });
            },
          ),
          const SizedBox(width: 8),

          // Calibration
          IconButton(
            icon: const Icon(Icons.center_focus_strong, size: 18),
            tooltip: 'Calibrate Center Pose',
            onPressed: () => trackingProv.calibrate(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftControlPanel(
    TrackingProvider trackingProv,
    AudioSyncProvider audioProv,
  ) {
    return ListView(
      children: [
        // Camera & Face Tracking Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: AppColors.primaryCyan,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Camera Tracking',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: trackingProv.isTracking
                          ? AppColors.statusOnline.withValues(alpha: 0.15)
                          : AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      trackingProv.isTracking ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: trackingProv.isTracking
                            ? AppColors.statusOnline
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Camera Selector
              if (trackingProv.cameras.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: trackingProv.selectedCamera?.id,
                  decoration: const InputDecoration(
                    labelText: 'Webcam Device',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: trackingProv.cameras.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (id) {
                    final selected = trackingProv.cameras.firstWhere(
                      (c) => c.id == id,
                    );
                    trackingProv.selectCamera(selected);
                  },
                ),
              const SizedBox(height: 12),

              // Manual Mode Switch
              Row(
                children: [
                  const Text('Manual Override', style: TextStyle(fontSize: 12)),
                  const Spacer(),
                  Switch(
                    value: trackingProv.state.isManualMode,
                    onChanged: (_) => trackingProv.toggleManualMode(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Sensitivity Slider
              Text(
                'Tracking Sensitivity: ${trackingProv.state.sensitivity.toStringAsFixed(1)}x',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Slider(
                value: trackingProv.state.sensitivity,
                min: 0.5,
                max: 2.0,
                onChanged: (v) => trackingProv.setSensitivity(v),
              ),

              // Smoothing Slider
              Text(
                'Pose Smoothing: ${trackingProv.state.smoothing.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Slider(
                value: trackingProv.state.smoothing,
                min: 0.1,
                max: 0.9,
                onChanged: (v) => trackingProv.setSmoothing(v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Microphone & Lip-Sync Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.mic, size: 16, color: AppColors.accentGreen),
                  const SizedBox(width: 8),
                  const Text(
                    'Voice & Lip-Sync',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      audioProv.isMuted ? Icons.volume_off : Icons.volume_up,
                      size: 16,
                      color: audioProv.isMuted
                          ? AppColors.accentRed
                          : AppColors.textPrimary,
                    ),
                    onPressed: () => audioProv.toggleMute(),
                    tooltip: audioProv.isMuted ? 'Unmute' : 'Mute',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Audio Level Meter
              Row(
                children: [
                  Text(
                    '${audioProv.state.inputLevelDb.toStringAsFixed(0)} dBFS',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: audioProv.state.normalizedLevel,
                        backgroundColor: AppColors.bgDarkest,
                        valueColor: AlwaysStoppedAnimation(
                          audioProv.state.isVoiceActive
                              ? AppColors.accentGreen
                              : AppColors.primaryBlue,
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Detected Viseme Indicator
              Row(
                children: [
                  const Text(
                    'Active Viseme: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primaryCyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      audioProv.state.currentViseme.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppColors.primaryCyan,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // VAD Threshold Slider
              Text(
                'VAD Threshold: ${audioProv.state.vadThreshold.toStringAsFixed(0)} dBFS',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Slider(
                value: audioProv.state.vadThreshold,
                min: -55.0,
                max: -20.0,
                onChanged: (v) => audioProv.setVadThreshold(v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCenterViewport(
    AvatarProvider avatarProv,
    ObsProvider obsProv,
    HardwareProvider hwProv,
  ) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AvatarViewport(showCheckerboard: _showCheckerboard),

          // Top Viewport Overlay Banner
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgDarkest.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Text(
                    avatarProv.activeAvatar.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${avatarProv.activeScene.name}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Viewport OBS Status
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgDarkest.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(
                    obsProv.isServerRunning
                        ? Icons.wifi_tethering
                        : Icons.wifi_tethering_off,
                    size: 16,
                    color: obsProv.isServerRunning
                        ? AppColors.statusOnline
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    obsProv.isServerRunning
                        ? 'OBS Source Live on ${obsProv.state.serverUrl} (${obsProv.state.connectedClients} Connected)'
                        : 'OBS Source Offline (Click "OBS STREAM" above to broadcast)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${hwProv.profile.currentFps.toStringAsFixed(0)} FPS',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryCyan,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightControlPanel(
    AvatarProvider avatarProv,
    TrackingProvider trackingProv,
  ) {
    return ListView(
      children: [
        // Expression Triggers Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.mood,
                    size: 16,
                    color: AppColors.accentPurple,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Facial Expressions',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildExpressionButton(
                    'Neutral',
                    AvatarExpression.neutral,
                    trackingProv,
                  ),
                  _buildExpressionButton(
                    'Smile',
                    AvatarExpression.smile,
                    trackingProv,
                  ),
                  _buildExpressionButton(
                    'Surprise',
                    AvatarExpression.surprise,
                    trackingProv,
                  ),
                  _buildExpressionButton(
                    'Wink',
                    AvatarExpression.wink,
                    trackingProv,
                  ),
                  _buildExpressionButton(
                    'Thoughtful',
                    AvatarExpression.thoughtful,
                    trackingProv,
                  ),
                  _buildExpressionButton(
                    'Laugh',
                    AvatarExpression.laugh,
                    trackingProv,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Pose Telemetry Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pose Telemetry',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _buildTelemetryRow(
                'Pitch (Up/Down)',
                trackingProv.state.pitch.toStringAsFixed(2),
              ),
              _buildTelemetryRow(
                'Yaw (Left/Right)',
                trackingProv.state.yaw.toStringAsFixed(2),
              ),
              _buildTelemetryRow(
                'Roll (Tilt)',
                trackingProv.state.roll.toStringAsFixed(2),
              ),
              _buildTelemetryRow(
                'Eye Blink (L/R)',
                '${(trackingProv.state.leftEyeBlink * 100).toInt()}% / ${(trackingProv.state.rightEyeBlink * 100).toInt()}%',
              ),
              _buildTelemetryRow(
                'Mouth Aperture',
                '${(trackingProv.state.mouthOpen * 100).toInt()}%',
              ),
              _buildTelemetryRow(
                'Confidence',
                '${(trackingProv.state.confidence * 100).toInt()}%',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Avatar Transform
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Avatar Positioning',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                'Scale: ${avatarProv.activeAvatar.scale.toStringAsFixed(2)}x',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Slider(
                value: avatarProv.activeAvatar.scale,
                min: 0.6,
                max: 1.6,
                onChanged: (v) => avatarProv.updateActiveAvatar(scale: v),
              ),
              Text(
                'Vertical Offset: ${avatarProv.activeAvatar.offsetY.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Slider(
                value: avatarProv.activeAvatar.offsetY,
                min: -0.5,
                max: 0.5,
                onChanged: (v) => avatarProv.updateActiveAvatar(offsetY: v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpressionButton(
    String label,
    AvatarExpression expression,
    TrackingProvider trackingProv,
  ) {
    final isSelected = trackingProv.activeExpression == expression;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.accentPurple.withValues(alpha: 0.2)
            : Colors.transparent,
        side: BorderSide(
          color: isSelected ? AppColors.accentPurple : AppColors.borderLight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: () => trackingProv.triggerExpression(expression),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: AppColors.primaryCyan,
            ),
          ),
        ],
      ),
    );
  }
}
