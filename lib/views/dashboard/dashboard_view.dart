import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/obs_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/audio_sync_provider.dart';
import '../../providers/hardware_provider.dart';
import '../../providers/billing_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/sidebar_nav.dart';
import '../../widgets/td_logo.dart';
import '../studio/widgets/avatar_viewport.dart';

class DashboardView extends StatelessWidget {
  final Function(StudioSection) onNavigate;

  const DashboardView({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final avatarProv = context.watch<AvatarProvider>();
    final obsProv = context.watch<ObsProvider>();
    final trackingProv = context.watch<TrackingProvider>();
    final audioProv = context.watch<AudioSyncProvider>();
    final hwProv = context.watch<HardwareProvider>();
    final billProv = context.watch<BillingProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDarkest,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              children: [
                const TdLogo(size: 48, glow: true),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome to TD-Avatar-Studio',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Production-grade cross-platform 3D avatar workspace for OBS Studio livestreaming, Paystack/NOWPayments billing, and video creation.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => onNavigate(StudioSection.aiFaceSwap),
                  icon: const Icon(Icons.face_retouching_natural, size: 18),
                  label: const Text('AI FACE SWAP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCyan,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => onNavigate(StudioSection.liveStudio),
                  icon: const Icon(Icons.play_circle_fill, size: 18),
                  label: const Text('3D STUDIO'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Subscription Renewal Reminder Banner (only for time-limited licenses)
            if (!billProv.isLifetime && (billProv.isExpiringSoon || billProv.isExpired)) ...[
              _buildRenewalReminderBanner(billProv),
              const SizedBox(height: 20),
            ],

            // Top Quick Status Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Active Avatar',
                    value: avatarProv.activeAvatar.name,
                    icon: Icons.person,
                    iconColor: AppColors.primaryCyan,
                    subtitle: avatarProv.activeAvatar.type.name,
                    onTap: () => onNavigate(StudioSection.avatarLibrary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'OBS Source Status',
                    value: obsProv.isServerRunning
                        ? 'LIVE (${obsProv.state.connectedClients} Client)'
                        : 'OFFLINE',
                    icon: Icons.cast_connected,
                    iconColor: obsProv.isServerRunning
                        ? AppColors.statusOnline
                        : AppColors.statusOffline,
                    subtitle: obsProv.state.serverUrl,
                    onTap: () => onNavigate(StudioSection.obsIntegration),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Hardware Profile',
                    value: hwProv.profile.tier.name.toUpperCase(),
                    icon: Icons.speed,
                    iconColor: AppColors.primaryBlue,
                    subtitle:
                        '${hwProv.profile.currentFps.toStringAsFixed(0)} FPS • ${hwProv.profile.memoryMb.toStringAsFixed(0)} MB RAM',
                    onTap: () => onNavigate(StudioSection.performanceSettings),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Center Content: Quick Viewport + OBS Stream Box
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Viewport Preview
                Expanded(
                  flex: 3,
                  child: GlassCard(
                    height: 380,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.preview,
                              size: 18,
                              color: AppColors.primaryCyan,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Live Avatar Preview',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.fullscreen, size: 18),
                              onPressed: () =>
                                  onNavigate(StudioSection.liveStudio),
                              tooltip: 'Open Full Workspace',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Expanded(child: AvatarViewport()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // OBS Browser Source Integration Card
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.sensors,
                                  size: 18,
                                  color: AppColors.primaryCyan,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'OBS Browser Source',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: obsProv.isServerRunning,
                                  onChanged: (_) {
                                    obsProv.toggleServer(
                                      avatarProvider: avatarProv,
                                      trackingProvider: trackingProv,
                                      audioProvider: audioProv,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Add this URL in OBS Studio as a "Browser Source" with transparent background enabled.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bgDarkest,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      obsProv.state.serverUrl,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: AppColors.primaryCyan,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 16),
                                    tooltip: 'Copy URL for OBS',
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: obsProv.state.serverUrl,
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'OBS Source URL copied to clipboard!',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => onNavigate(
                                      StudioSection.obsIntegration,
                                    ),
                                    child: const Text('SETUP OBS'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Quick Controls
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Status',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildQuickStatusRow(
                              'Face Tracking',
                              trackingProv.isTracking ? 'Active' : 'Standby',
                              trackingProv.isTracking,
                            ),
                            const SizedBox(height: 8),
                            _buildQuickStatusRow(
                              'Voice Lip-Sync',
                              audioProv.isListening ? 'Active' : 'Standby',
                              audioProv.isListening,
                            ),
                            const SizedBox(height: 8),
                            _buildQuickStatusRow(
                              'OBS Studio Installed',
                              obsProv.state.isObsInstalled
                                  ? 'Detected'
                                  : 'Not Found',
                              obsProv.state.isObsInstalled,
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
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

  Widget _buildRenewalReminderBanner(BillingProvider billProv) {
    final isExpired = billProv.isExpired;
    final color = isExpired ? AppColors.accentRed : AppColors.statusWarning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            isExpired ? Icons.error_outline : Icons.notification_important_outlined,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpired
                      ? '30-DAY ACCESS CODE EXPIRED'
                      : 'SUBSCRIPTION RENEWAL REMINDER (${billProv.daysRemaining} DAYS REMAINING)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isExpired
                      ? 'Your 30-day Access Code has expired. Renew your subscription to generate a new 30-day code and unlock commercial OBS streaming.'
                      : 'Your 30-day subscription will expire soon (${billProv.activeSubscription?.renewsAt.toLocal().toString().split(' ').first}). Renew now to maintain uninterrupted access.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          ElevatedButton.icon(
            onPressed: () => onNavigate(StudioSection.accountSubscription),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('RENEW NOW'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatusRow(String label, String status, bool ok) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 14,
          color: ok ? AppColors.statusOnline : AppColors.textMuted,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ok ? AppColors.statusOnline : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
