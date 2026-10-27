import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/avatar_provider.dart';
import '../providers/tracking_provider.dart';
import '../providers/audio_sync_provider.dart';
import '../providers/obs_provider.dart';
import '../providers/hardware_provider.dart';
import 'metric_badge.dart';
import 'td_logo.dart';

class TopStatusBar extends StatelessWidget {
  const TopStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final avatarProv = context.watch<AvatarProvider>();
    final trackingProv = context.watch<TrackingProvider>();
    final audioProv = context.watch<AudioSyncProvider>();
    final obsProv = context.watch<ObsProvider>();
    final hwProv = context.watch<HardwareProvider>();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgDarker,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 950;
          return Row(
            children: [
              // App Title Branding
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TdLogo(size: 26),
                  const SizedBox(width: 8),
                  const Text(
                    'TD-AVATAR-STUDIO',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'v2.4',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryCyan,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              if (!isNarrow) ...[
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person,
                          size: 13,
                          color: AppColors.primaryCyan,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            avatarProv.activeAvatar.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // System Status Indicators
              _buildPill(
                label: 'TRACKING',
                active: trackingProv.isTracking,
                activeColor: AppColors.statusOnline,
                inactiveColor: AppColors.statusStandby,
              ),
              const SizedBox(width: 6),

              _buildPill(
                label: 'MIC',
                active: audioProv.isListening && !audioProv.isMuted,
                activeColor: AppColors.statusOnline,
                inactiveColor: audioProv.isMuted
                    ? AppColors.statusWarning
                    : AppColors.statusStandby,
              ),
              const SizedBox(width: 6),

              _buildPill(
                label: 'OBS',
                active: obsProv.isServerRunning,
                activeColor: AppColors.statusOnline,
                inactiveColor: AppColors.statusStandby,
              ),
              const SizedBox(width: 8),

              MetricBadge(
                label: 'FPS',
                value: hwProv.profile.currentFps.toStringAsFixed(0),
                color: hwProv.profile.currentFps >= 50
                    ? AppColors.statusOnline
                    : AppColors.statusWarning,
              ),
              const SizedBox(width: 6),
              MetricBadge(
                label: 'TIER',
                value: hwProv.currentTier.name.toUpperCase(),
                color: AppColors.primaryBlue,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required bool active,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (active ? activeColor : inactiveColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (active ? activeColor : inactiveColor).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: active ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
