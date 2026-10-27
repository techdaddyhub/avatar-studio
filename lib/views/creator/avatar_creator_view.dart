import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/avatar_provider.dart';
import '../../widgets/glass_card.dart';
import '../studio/widgets/avatar_viewport.dart';

class AvatarCreatorView extends StatelessWidget {
  const AvatarCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final avatarProv = context.watch<AvatarProvider>();
    final active = avatarProv.activeAvatar;

    return Scaffold(
      backgroundColor: AppColors.bgDarkest,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Real-time Live Preview
            Expanded(
              flex: 3,
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.palette,
                          size: 18,
                          color: AppColors.primaryCyan,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Customizing: ${active.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Expanded(child: AvatarViewport()),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Right: Customizer controls
            Expanded(
              flex: 4,
              child: GlassCard(
                child: ListView(
                  children: [
                    const Text(
                      'Materials & Shading',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Skin Tone Selector
                    _buildColorSelector(
                      title: 'Skin Tone',
                      selected: active.skinTone,
                      swatches: const [
                        Color(0xFFF7D5C4),
                        Color(0xFFF5D0B5),
                        Color(0xFFE8B998),
                        Color(0xFFD49C76),
                        Color(0xFFA56845),
                        Color(0xFF6B4423),
                      ],
                      onSelect: (c) =>
                          avatarProv.updateActiveAvatar(skinTone: c),
                    ),
                    const Divider(height: 24),

                    // Eye Color
                    _buildColorSelector(
                      title: 'Iris / Eye Color',
                      selected: active.eyeColor,
                      swatches: const [
                        Color(0xFF0091EA), // Sapphire Blue
                        Color(0xFF2E7D32), // Emerald Green
                        Color(0xFFD500F9), // Cyber Violet
                        Color(0xFFFFB300), // Amber
                        Color(0xFF4E342E), // Deep Hazel
                      ],
                      onSelect: (c) =>
                          avatarProv.updateActiveAvatar(eyeColor: c),
                    ),
                    const Divider(height: 24),

                    // Hair Color
                    _buildColorSelector(
                      title: 'Hair Color',
                      selected: active.hairColor,
                      swatches: const [
                        Color(0xFF263238), // Jet Black
                        Color(0xFF4E342E), // Dark Chestnut
                        Color(0xFF8D6E63), // Light Auburn
                        Color(0xFFFBC02D), // Blonde
                        Color(0xFFECEFF1), // Silver / Platinum
                      ],
                      onSelect: (c) =>
                          avatarProv.updateActiveAvatar(hairColor: c),
                    ),
                    const Divider(height: 24),

                    // Clothing Color
                    _buildColorSelector(
                      title: 'Outfit / Clothing Color',
                      selected: active.clothingColor,
                      swatches: const [
                        Color(0xFF1E293B), // Charcoal Dark
                        Color(0xFF0D47A1), // Navy Blue
                        Color(0xFF2979FF), // Vibrant Electric Blue
                        Color(0xFFB71C1C), // Deep Crimson
                        Color(0xFF1B5E20), // Forest Green
                      ],
                      onSelect: (c) =>
                          avatarProv.updateActiveAvatar(clothingColor: c),
                    ),
                    const Divider(height: 24),

                    // Studio Lighting
                    const Text(
                      'Lighting & Atmosphere',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Key Light Intensity: ${(active.keyLightIntensity * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Slider(
                      value: active.keyLightIntensity,
                      min: 0.2,
                      max: 2.0,
                      onChanged: (v) =>
                          avatarProv.updateActiveAvatar(keyLightIntensity: v),
                    ),

                    Text(
                      'Ambient Light: ${(active.ambientIntensity * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Slider(
                      value: active.ambientIntensity,
                      min: 0.1,
                      max: 1.0,
                      onChanged: (v) =>
                          avatarProv.updateActiveAvatar(ambientIntensity: v),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector({
    required String title,
    required Color selected,
    required List<Color> swatches,
    required Function(Color) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          children: swatches.map((color) {
            final isChosen = selected.toARGB32() == color.toARGB32();
            return InkWell(
              onTap: () => onSelect(color),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isChosen
                        ? AppColors.primaryCyan
                        : AppColors.borderSubtle,
                    width: isChosen ? 3 : 1.5,
                  ),
                  boxShadow: isChosen
                      ? [
                          BoxShadow(
                            color: AppColors.primaryCyan.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: isChosen
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
