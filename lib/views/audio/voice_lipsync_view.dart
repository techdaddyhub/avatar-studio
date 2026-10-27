import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/audio_sync_provider.dart';
import '../../widgets/glass_card.dart';
import '../studio/widgets/avatar_viewport.dart';

class VoiceLipsyncView extends StatelessWidget {
  const VoiceLipsyncView({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProv = context.watch<AudioSyncProvider>();
    final state = audioProv.state;

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
                      'Voice & Lip-Sync Engine',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Low-latency acoustic energy and viseme analysis for accurate voice-to-mouth synchronization.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => audioProv.toggleListening(),
                  icon: Icon(state.isListening ? Icons.mic_off : Icons.mic),
                  label: Text(
                    state.isListening ? 'STOP LISTENING' : 'START MIC CAPTURE',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isListening
                        ? AppColors.accentRed
                        : AppColors.accentGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Controls & Meter
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Audio Device & Sliders
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.settings_voice,
                                  size: 16,
                                  color: AppColors.accentGreen,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Microphone Input',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                OutlinedButton.icon(
                                  onPressed: () => audioProv.toggleMute(),
                                  icon: Icon(
                                    state.isMuted
                                        ? Icons.volume_off
                                        : Icons.volume_up,
                                    size: 16,
                                  ),
                                  label: Text(
                                    state.isMuted ? 'MUTED' : 'ACTIVE',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            if (audioProv.microphones.isNotEmpty)
                              DropdownButtonFormField<String>(
                                initialValue: audioProv.selectedMicrophone?.id,
                                decoration: const InputDecoration(
                                  labelText: 'Select Audio Input Device',
                                  border: OutlineInputBorder(),
                                ),
                                items: audioProv.microphones.map((m) {
                                  return DropdownMenuItem(
                                    value: m.id,
                                    child: Text(m.name),
                                  );
                                }).toList(),
                                onChanged: (id) {
                                  final mic = audioProv.microphones.firstWhere(
                                    (m) => m.id == id,
                                  );
                                  audioProv.selectMicrophone(mic);
                                },
                              ),
                            const SizedBox(height: 18),

                            // Real-time Volume Level Meter
                            const Text(
                              'Input Volume (dBFS Meter)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: state.normalizedLevel,
                                minHeight: 18,
                                backgroundColor: AppColors.bgDarkest,
                                valueColor: AlwaysStoppedAnimation(
                                  state.isVoiceActive
                                      ? AppColors.accentGreen
                                      : AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text(
                                  '-60 dBFS (Silence)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${state.inputLevelDb.toStringAsFixed(1)} dBFS',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryCyan,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  '0 dBFS (Peak)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Lip-Sync Sensitivity Slider
                            Text(
                              'Lip-Sync Sensitivity: ${state.sensitivity.toStringAsFixed(2)}x',
                            ),
                            Slider(
                              value: state.sensitivity,
                              min: 0.5,
                              max: 2.5,
                              onChanged: (v) => audioProv.setSensitivity(v),
                            ),

                            // VAD Threshold Slider
                            Text(
                              'Voice Activity Detection Threshold: ${state.vadThreshold.toStringAsFixed(0)} dBFS',
                            ),
                            Slider(
                              value: state.vadThreshold,
                              min: -55.0,
                              max: -25.0,
                              onChanged: (v) => audioProv.setVadThreshold(v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Viseme Breakdown Visualizer
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Active Viseme Breakdown',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildVisemePill(
                                  'SIL',
                                  state.currentViseme == 'sil',
                                ),
                                _buildVisemePill(
                                  'AA',
                                  state.currentViseme == 'aa',
                                ),
                                _buildVisemePill(
                                  'EE',
                                  state.currentViseme == 'ee',
                                ),
                                _buildVisemePill(
                                  'OH',
                                  state.currentViseme == 'oh',
                                ),
                                _buildVisemePill(
                                  'CH',
                                  state.currentViseme == 'ch',
                                ),
                                _buildVisemePill(
                                  'M',
                                  state.currentViseme == 'm',
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

                // Right Column: Live Viewport
                Expanded(
                  flex: 3,
                  child: GlassCard(
                    height: 480,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lip-Sync Visualizer',
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisemePill(String name, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.accentGreen.withValues(alpha: 0.2)
            : AppColors.bgElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? AppColors.accentGreen : AppColors.borderSubtle,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: isActive ? AppColors.accentGreen : AppColors.textMuted,
        ),
      ),
    );
  }
}
