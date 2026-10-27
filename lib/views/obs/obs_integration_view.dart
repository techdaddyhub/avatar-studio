import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/obs_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/audio_sync_provider.dart';
import '../../widgets/glass_card.dart';

class ObsIntegrationView extends StatefulWidget {
  const ObsIntegrationView({super.key});

  @override
  State<ObsIntegrationView> createState() => _ObsIntegrationViewState();
}

class _ObsIntegrationViewState extends State<ObsIntegrationView> {
  final _hostController = TextEditingController(text: '127.0.0.1');
  final _portController = TextEditingController(text: '4455');
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final obsProv = context.watch<ObsProvider>();
    final avatarProv = context.watch<AvatarProvider>();
    final trackingProv = context.watch<TrackingProvider>();
    final audioProv = context.watch<AudioSyncProvider>();

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
                      'OBS Studio Integration Center',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Deliver your animated avatar with native alpha transparency directly into OBS Studio.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    obsProv.toggleServer(
                      avatarProvider: avatarProv,
                      trackingProvider: trackingProv,
                      audioProvider: audioProv,
                    );
                  },
                  icon: Icon(
                    obsProv.isServerRunning
                        ? Icons.stop_circle
                        : Icons.cast_connected,
                  ),
                  label: Text(
                    obsProv.isServerRunning
                        ? 'STOP SOURCE SERVER'
                        : 'START SOURCE SERVER',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: obsProv.isServerRunning
                        ? AppColors.accentRed
                        : AppColors.primaryCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Top Status Row: OBS Installed indicator + Server status
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    child: Row(
                      children: [
                        Icon(
                          obsProv.state.isObsInstalled
                              ? Icons.check_circle
                              : Icons.info_outline,
                          color: obsProv.state.isObsInstalled
                              ? AppColors.statusOnline
                              : AppColors.statusWarning,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OBS Studio Installation',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              obsProv.state.isObsInstalled
                                  ? 'OBS Studio Detected on System'
                                  : 'OBS Studio Not Found in Standard Paths',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassCard(
                    child: Row(
                      children: [
                        Icon(
                          obsProv.isServerRunning
                              ? Icons.sensors
                              : Icons.sensors_off,
                          color: obsProv.isServerRunning
                              ? AppColors.statusOnline
                              : AppColors.statusStandby,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Local Browser Source Server',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              obsProv.isServerRunning
                                  ? 'Active on Port ${obsProv.state.serverPort} (${obsProv.state.connectedClients} Connected)'
                                  : 'Server Offline',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Primary Setup Instructions & URL
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'OBS Studio Browser Source Setup (Transparent Alpha Stream)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'To add the avatar with a transparent background to your OBS scenes:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStepRow(
                    1,
                    'In OBS Studio, click the "+" button under the Sources dock.',
                  ),
                  _buildStepRow(
                    2,
                    'Select "Browser" and name it "Avatar Studio Source".',
                  ),
                  _buildStepRow(
                    3,
                    'Paste the URL below into the URL input field.',
                  ),
                  _buildStepRow(
                    4,
                    'Set Width: 1920, Height: 1080 (or 1280x720). Check "Shutdown source when not visible".',
                  ),
                  _buildStepRow(
                    5,
                    'Your avatar will immediately appear with full transparency over your game or presentation!',
                  ),
                  const SizedBox(height: 16),

                  // URL Box with Copy Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgDarkest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.link,
                          size: 20,
                          color: AppColors.primaryCyan,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SelectableText(
                            obsProv.state.serverUrl,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryCyan,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: obsProv.state.serverUrl),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Copied Browser Source URL to clipboard!',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('COPY URL'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings & Controls Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source Settings
                Expanded(
                  flex: 3,
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Source Configuration',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Transparent Background Toggle
                        Row(
                          children: [
                            const Text(
                              'Transparent Alpha Background',
                              style: TextStyle(fontSize: 13),
                            ),
                            const Spacer(),
                            Switch(
                              value: obsProv.state.transparentBackground,
                              onChanged: (v) =>
                                  obsProv.setTransparentBackground(v),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Output Resolution Dropdown
                        Row(
                          children: [
                            const Text(
                              'Target Output Resolution',
                              style: TextStyle(fontSize: 13),
                            ),
                            const Spacer(),
                            DropdownButton<String>(
                              value: obsProv.state.outputResolution,
                              items: const [
                                DropdownMenuItem(
                                  value: '1920x1080',
                                  child: Text('1920 x 1080 (1080p)'),
                                ),
                                DropdownMenuItem(
                                  value: '1280x720',
                                  child: Text('1280 x 720 (720p)'),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) obsProv.setOutputResolution(v);
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Output FPS
                        Row(
                          children: [
                            const Text(
                              'Target Frame Rate',
                              style: TextStyle(fontSize: 13),
                            ),
                            const Spacer(),
                            DropdownButton<int>(
                              value: obsProv.state.outputFps,
                              items: const [
                                DropdownMenuItem(
                                  value: 60,
                                  child: Text('60 FPS (Smooth)'),
                                ),
                                DropdownMenuItem(
                                  value: 30,
                                  child: Text('30 FPS (Core i3)'),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) obsProv.setOutputFps(v);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // OBS WebSocket & Virtual Camera
                Expanded(
                  flex: 3,
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.cable,
                              size: 16,
                              color: AppColors.accentPurple,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'OBS WebSocket v5 Controller',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: obsProv.isObsConnected
                                    ? AppColors.statusOnline.withValues(
                                        alpha: 0.15,
                                      )
                                    : AppColors.bgElevated,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                obsProv.isObsConnected
                                    ? 'CONNECTED'
                                    : 'NOT CONNECTED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: obsProv.isObsConnected
                                      ? AppColors.statusOnline
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Connect via OBS WebSocket to switch scenes, toggle streams, and trigger the OBS Virtual Camera directly from Avatar Studio.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _hostController,
                                decoration: const InputDecoration(
                                  labelText: 'Host IP',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _portController,
                                decoration: const InputDecoration(
                                  labelText: 'Port',
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: obsProv.isObsConnected
                                  ? OutlinedButton(
                                      onPressed: () =>
                                          obsProv.disconnectObsWebSocket(),
                                      child: const Text('DISCONNECT'),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        final port =
                                            int.tryParse(
                                              _portController.text,
                                            ) ??
                                            4455;
                                        obsProv.connectToObsWebSocket(
                                          host: _hostController.text.trim(),
                                          port: port,
                                          password: _passwordController.text,
                                        );
                                      },
                                      child: const Text('CONNECT TO OBS'),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: obsProv.isObsConnected
                                  ? () => obsProv.toggleVirtualCam()
                                  : null,
                              icon: const Icon(Icons.videocam, size: 16),
                              label: const Text('VIRTUAL CAM'),
                            ),
                          ],
                        ),
                        if (obsProv.state.lastError != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            obsProv.state.lastError!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.accentRed,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Virtual Camera Workflow Guide
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Virtual Camera Workflow (Zoom, Teams, Discord, Meet)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '1. Avatar Studio renders your avatar in real-time.\n'
                    '2. Add the avatar as a Browser Source to your OBS Studio scene.\n'
                    '3. In OBS Studio, click "Start Virtual Camera" in the bottom-right Controls dock.\n'
                    '4. Open Zoom, Microsoft Teams, Discord, or Google Meet, go to Video Settings, and select "OBS Virtual Camera" as your camera.\n'
                    'Note: Most video meeting apps do not support transparent backgrounds for camera feeds — your background will appear as composited in OBS.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryCyan.withValues(alpha: 0.15),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryCyan,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
