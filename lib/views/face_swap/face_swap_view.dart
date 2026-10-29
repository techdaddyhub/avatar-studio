import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/audio_sync_provider.dart';
import '../../providers/face_swap_provider.dart';
import '../../providers/obs_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/metric_badge.dart';
import 'widgets/face_swap_painter.dart';

class FaceSwapView extends StatelessWidget {
  const FaceSwapView({super.key});

  @override
  Widget build(BuildContext context) {
    final swapProv = context.watch<FaceSwapProvider>();
    final trackingProv = context.watch<TrackingProvider>();
    final audioProv = context.watch<AudioSyncProvider>();
    final obsProv = context.watch<ObsProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDarkest,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header with Status & Action Buttons
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Real-Time AI Face Swap',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: swapProv.isSwapping
                                ? AppColors.statusOnline.withValues(alpha: 0.2)
                                : AppColors.statusStandby.withValues(
                                    alpha: 0.2,
                                  ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: swapProv.isSwapping
                                  ? AppColors.statusOnline
                                  : AppColors.statusStandby,
                            ),
                          ),
                          child: Text(
                            swapProv.isSwapping ? 'LIVE SWAPPING' : 'STANDBY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: swapProv.isSwapping
                                  ? AppColors.statusOnline
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Replace your live camera face with any reference photo in real-time for OBS Studio, Zoom, Teams, and Discord.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => swapProv.toggleMesh(),
                  icon: Icon(
                    swapProv.showMesh
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 16,
                  ),
                  label: Text(
                    swapProv.showMesh ? 'HIDE MESH' : 'SHOW MESH',
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (swapProv.isSwapping) {
                      swapProv.stopSwapping();
                    } else {
                      // Ensure tracking is active
                      if (!trackingProv.isTracking) {
                        trackingProv.startTracking();
                      }
                      swapProv.startSwapping(
                        trackingProvider: trackingProv,
                        audioProvider: audioProvider(context),
                      );
                    }
                  },
                  icon: Icon(
                    swapProv.isSwapping ? Icons.stop : Icons.play_arrow,
                    size: 18,
                  ),
                  label: Text(
                    swapProv.isSwapping
                        ? 'STOP FACE SWAP'
                        : 'START REAL-TIME SWAP',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: swapProv.isSwapping
                        ? AppColors.accentRed
                        : AppColors.primaryCyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Main Dual Viewport Area (Left: Output Canvas | Right: Controls & Targets)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Live AI Swapped Viewport
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      Container(
                        height: 480,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: swapProv.isSwapping
                                ? AppColors.primaryCyan.withValues(alpha: 0.8)
                                : AppColors.borderSubtle,
                            width: swapProv.isSwapping ? 2 : 1,
                          ),
                          boxShadow: [
                            if (swapProv.isSwapping)
                              BoxShadow(
                                color: AppColors.primaryCyan.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 20,
                              ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: FaceSwapPainter(
                                  frame: swapProv.currentFrame,
                                  target: swapProv.selectedTarget,
                                  settings: swapProv.settings,
                                  showMesh: swapProv.showMesh,
                                ),
                              ),
                            ),
                            // Top overlay metrics
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.face_retouching_natural,
                                      size: 14,
                                      color: AppColors.primaryCyan,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      swapProv.selectedTarget != null
                                          ? 'TARGET: ${swapProv.selectedTarget!.name.toUpperCase()}'
                                          : 'NO TARGET SELECTED',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 14,
                              right: 14,
                              child: MetricBadge(
                                label: 'FPS',
                                value: swapProv.isSwapping ? '60' : '0',
                                color: swapProv.isSwapping
                                    ? AppColors.statusOnline
                                    : AppColors.statusStandby,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tuning Controls Card below Canvas
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Face Blend & Real-Time Tuning',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSlider(
                                    label: 'Blend Opacity',
                                    value: swapProv.settings.blendOpacity,
                                    min: 0.5,
                                    max: 1.0,
                                    onChanged: (v) => swapProv.updateSettings(
                                      swapProv.settings.copyWith(
                                        blendOpacity: v,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildSlider(
                                    label: 'Edge Feathering',
                                    value: swapProv.settings.edgeFeathering,
                                    min: 5.0,
                                    max: 30.0,
                                    onChanged: (v) => swapProv.updateSettings(
                                      swapProv.settings.copyWith(
                                        edgeFeathering: v,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSlider(
                                    label: 'Expression Sensitivity',
                                    value: swapProv
                                        .settings
                                        .expressionSensitivity,
                                    min: 0.5,
                                    max: 2.0,
                                    onChanged: (v) => swapProv.updateSettings(
                                      swapProv.settings.copyWith(
                                        expressionSensitivity: v,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Skin Tone Harmonization',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: swapProv
                                            .settings
                                            .skinToneHarmonization,
                                        onChanged: (v) => swapProv.updateSettings(
                                          swapProv.settings.copyWith(
                                            skinToneHarmonization: v,
                                          ),
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
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Right Column: Target Face Selection & OBS Stream Card
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target Face Library Header
                      Row(
                        children: [
                          const Text(
                            'Target Face Reference',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => swapProv.uploadCustomFacePhoto(),
                            icon: const Icon(Icons.add_photo_alternate, size: 14),
                            label: const Text('UPLOAD PHOTO'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // List of Target Faces
                      ...swapProv.targets.map((target) {
                        final isSelected =
                            swapProv.selectedTarget?.id == target.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () {
                              swapProv.selectTarget(target);
                              if (swapProv.isSwapping) {
                                swapProv.startSwapping(
                                  trackingProvider: trackingProv,
                                  audioProvider: audioProvider(context),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryCyan.withValues(
                                        alpha: 0.12,
                                      )
                                    : AppColors.bgCard,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryCyan
                                      : AppColors.borderSubtle,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.bgDarkest,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primaryCyan.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: AppColors.primaryCyan,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              target.name,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            if (target.isCustom)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 1,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.statusOnline
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: const Text(
                                                  'CUSTOM',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.statusOnline,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          target.category,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primaryCyan,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      // OBS Studio Broadcast Card
                      GlassCard(
                        borderColor: obsProv.isServerRunning
                            ? AppColors.statusOnline
                            : AppColors.borderSubtle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.cast_connected,
                                  size: 18,
                                  color: obsProv.isServerRunning
                                      ? AppColors.statusOnline
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'OBS Stream Output',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: obsProv.isServerRunning,
                                  onChanged: (on) {
                                    if (on) {
                                      obsProv.startServer(
                                        avatarProvider:
                                            context.read(),
                                        trackingProvider: trackingProv,
                                        audioProvider: audioProv,
                                      );
                                    } else {
                                      obsProv.stopServer();
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add this URL in OBS Studio as a Browser Source to stream the real-time AI face-swapped video directly into your stream:',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bgDarkest,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      obsProv.state.serverUrl,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        color: AppColors.primaryCyan,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 14),
                                    tooltip: 'Copy URL',
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: obsProv.state.serverUrl,
                                        ),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'OBS URL copied to clipboard!',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
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

  AudioSyncProvider audioProvider(BuildContext context) =>
      context.read<AudioSyncProvider>();

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: AppColors.primaryCyan,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppColors.primaryCyan,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
