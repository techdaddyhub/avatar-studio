import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/hardware_detector.dart';
import '../../providers/hardware_provider.dart';
import '../../widgets/glass_card.dart';

class PerformanceSettingsView extends StatelessWidget {
  const PerformanceSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final hwProv = context.watch<HardwareProvider>();
    final profile = hwProv.profile;
    final specs = hwProv.specs;

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
                      'Hardware Adaptation & Performance Profiles',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Engine adapts quality dynamically based on your processor, graphics, and RAM.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text(
                      'Auto-Adapt Quality',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: profile.autoAdapt,
                      onChanged: (v) => hwProv.setAutoAdapt(v),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Detected Hardware Specs Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.memory,
                    size: 28,
                    color: AppColors.primaryCyan,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detected System Architecture: ${specs.osName.toUpperCase()} (${specs.processorCount} Cores)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          specs.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Three Profiles Cards
            Row(
              children: [
                Expanded(
                  child: _buildProfileCard(
                    title: 'Economy Mode',
                    tier: HardwareTier.economy,
                    icon: Icons.energy_savings_leaf,
                    fpsCap: '30 FPS Cap',
                    target: 'Intel Core i3 / 4GB RAM',
                    description:
                        'Optimized 2D/3D avatars, reduced post-processing, low CPU/RAM footprint, basic tracking interpolation.',
                    isActive: profile.tier == HardwareTier.economy,
                    onSelect: () => hwProv.setTier(HardwareTier.economy),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProfileCard(
                    title: 'Balanced Mode',
                    tier: HardwareTier.balanced,
                    icon: Icons.balance,
                    fpsCap: '60 FPS Target',
                    target: 'Core i5/i7 / 8GB RAM',
                    description:
                        'Sharp 1080p output, smooth micro-expressions, balanced lighting, and responsive lip-sync.',
                    isActive: profile.tier == HardwareTier.balanced,
                    onSelect: () => hwProv.setTier(HardwareTier.balanced),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProfileCard(
                    title: 'Quality Mode',
                    tier: HardwareTier.quality,
                    icon: Icons.auto_awesome,
                    fpsCap: '60 FPS Ultra',
                    target: 'Dedicated GPU / 16GB+ RAM',
                    description:
                        'Sub-pixel antialiasing, high dynamic range lighting, uncompressed alpha, and maximum landmark fidelity.',
                    isActive: profile.tier == HardwareTier.quality,
                    onSelect: () => hwProv.setTier(HardwareTier.quality),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Real-Time Engine Diagnostics
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Real-Time Rendering Diagnostics',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDiagnosticStat(
                          'Render FPS',
                          '${profile.currentFps.toStringAsFixed(1)} FPS',
                          Icons.speed,
                          profile.currentFps >= 50
                              ? AppColors.statusOnline
                              : AppColors.statusWarning,
                        ),
                      ),
                      Expanded(
                        child: _buildDiagnosticStat(
                          'Frame Time',
                          '${profile.frameTimeMs.toStringAsFixed(1)} ms',
                          Icons.timer,
                          AppColors.primaryCyan,
                        ),
                      ),
                      Expanded(
                        child: _buildDiagnosticStat(
                          'Memory Usage (RSS)',
                          '${profile.memoryMb.toStringAsFixed(0)} MB',
                          Icons.pie_chart,
                          profile.memoryMb < 300
                              ? AppColors.statusOnline
                              : AppColors.statusWarning,
                        ),
                      ),
                      Expanded(
                        child: _buildDiagnosticStat(
                          'Est. Studio CPU',
                          '${profile.cpuPercent.toStringAsFixed(1)}%',
                          Icons.developer_board,
                          AppColors.primaryBlue,
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
    );
  }

  Widget _buildProfileCard({
    required String title,
    required HardwareTier tier,
    required IconData icon,
    required String fpsCap,
    required String target,
    required String description,
    required bool isActive,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: GlassCard(
        borderColor: isActive ? AppColors.primaryCyan : AppColors.borderSubtle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isActive
                      ? AppColors.primaryCyan
                      : AppColors.textSecondary,
                ),
                const Spacer(),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryCyan,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              fpsCap,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryCyan,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              target,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.bgDarkest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
