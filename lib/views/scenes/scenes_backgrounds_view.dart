import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/scene_preset.dart';
import '../../providers/avatar_provider.dart';
import '../../widgets/glass_card.dart';

class ScenesBackgroundsView extends StatelessWidget {
  const ScenesBackgroundsView({super.key});

  @override
  Widget build(BuildContext context) {
    final avatarProv = context.watch<AvatarProvider>();
    final presets = ScenePreset.defaults;

    return Scaffold(
      backgroundColor: AppColors.bgDarkest,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Backgrounds & Scene Presets',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select background environments or choose transparent alpha for OBS compositing.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Presets Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final preset = presets[index];
                final isSelected = avatarProv.activeScene.id == preset.id;
                return _buildSceneCard(context, preset, isSelected, avatarProv);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneCard(
    BuildContext context,
    ScenePreset preset,
    bool isSelected,
    AvatarProvider provider,
  ) {
    return InkWell(
      onTap: () => provider.setActiveScene(preset),
      borderRadius: BorderRadius.circular(12),
      child: GlassCard(
        borderColor: isSelected
            ? AppColors.primaryCyan
            : AppColors.borderSubtle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scene Graphic Preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: preset.isTransparent
                      ? null
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [preset.primaryColor, preset.secondaryColor],
                        ),
                  color: preset.isTransparent ? const Color(0xFF161E30) : null,
                ),
                child: Center(
                  child: preset.isTransparent
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.opacity,
                              size: 28,
                              color: AppColors.primaryCyan,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'TRANSPARENT ALPHA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryCyan,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Text(
                    preset.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.primaryCyan,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
