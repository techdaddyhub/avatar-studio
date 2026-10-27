import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum StudioSection {
  dashboard,
  liveStudio,
  avatarLibrary,
  avatarCreator,
  faceTracking,
  voiceLipSync,
  obsIntegration,
  backgroundsScenes,
  performanceSettings,
  accountSubscription,
  diagnosticsHelp,
}

class SidebarNav extends StatelessWidget {
  final StudioSection currentSection;
  final Function(StudioSection) onSectionSelected;

  const SidebarNav({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: AppColors.bgDarker,
        border: Border(right: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildNavItem(
                  section: StudioSection.dashboard,
                  title: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                ),
                _buildNavItem(
                  section: StudioSection.liveStudio,
                  title: 'Live Avatar Studio',
                  icon: Icons.play_circle_outline,
                  activeIcon: Icons.play_circle_fill,
                  isHighlighted: true,
                ),
                const Divider(height: 18),
                _buildCategoryHeader('AVATAR WORKSPACE'),
                _buildNavItem(
                  section: StudioSection.avatarLibrary,
                  title: 'Avatar Library',
                  icon: Icons.folder_shared_outlined,
                  activeIcon: Icons.folder_shared,
                ),
                _buildNavItem(
                  section: StudioSection.avatarCreator,
                  title: 'Avatar Creator',
                  icon: Icons.auto_fix_high_outlined,
                  activeIcon: Icons.auto_fix_high,
                ),
                _buildNavItem(
                  section: StudioSection.backgroundsScenes,
                  title: 'Backgrounds & Scenes',
                  icon: Icons.wallpaper_outlined,
                  activeIcon: Icons.wallpaper,
                ),
                const Divider(height: 18),
                _buildCategoryHeader('INPUT & SYNC'),
                _buildNavItem(
                  section: StudioSection.faceTracking,
                  title: 'Face Tracking',
                  icon: Icons.videocam_outlined,
                  activeIcon: Icons.videocam,
                ),
                _buildNavItem(
                  section: StudioSection.voiceLipSync,
                  title: 'Voice & Lip-Sync',
                  icon: Icons.mic_none_outlined,
                  activeIcon: Icons.mic,
                ),
                const Divider(height: 18),
                _buildCategoryHeader('BROADCAST'),
                _buildNavItem(
                  section: StudioSection.obsIntegration,
                  title: 'OBS Integration',
                  icon: Icons.cast_connected_outlined,
                  activeIcon: Icons.cast_connected,
                  badge: 'SOURCE',
                ),
                const Divider(height: 18),
                _buildCategoryHeader('SYSTEM'),
                _buildNavItem(
                  section: StudioSection.performanceSettings,
                  title: 'Performance',
                  icon: Icons.speed_outlined,
                  activeIcon: Icons.speed,
                ),
                _buildNavItem(
                  section: StudioSection.accountSubscription,
                  title: 'Account & License',
                  icon: Icons.verified_user_outlined,
                  activeIcon: Icons.verified_user,
                ),
                _buildNavItem(
                  section: StudioSection.diagnosticsHelp,
                  title: 'Help & Diagnostics',
                  icon: Icons.help_outline,
                  activeIcon: Icons.help,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.desktop_windows,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Cross-Platform Desktop',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.statusOnline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required StudioSection section,
    required String title,
    required IconData icon,
    required IconData activeIcon,
    bool isHighlighted = false,
    String? badge,
  }) {
    final isSelected = currentSection == section;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSectionSelected(section),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isHighlighted
                        ? AppColors.primaryCyan.withValues(alpha: 0.15)
                        : AppColors.bgElevated)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected && isHighlighted
                  ? Border.all(
                      color: AppColors.primaryCyan.withValues(alpha: 0.4),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 18,
                  color: isSelected
                      ? (isHighlighted
                            ? AppColors.primaryCyan
                            : AppColors.textPrimary)
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryCyan,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
