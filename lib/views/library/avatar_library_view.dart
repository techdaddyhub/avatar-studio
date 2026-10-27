import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/avatar_model.dart';
import '../../providers/avatar_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/upload_avatar_dialog.dart';

class AvatarLibraryView extends StatelessWidget {
  const AvatarLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final avatarProv = context.watch<AvatarProvider>();

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
                      'Avatar Library',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage, duplicate, customize, and import 3D models (GLB, glTF, VRM) or portraits.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => UploadAvatarDialog.show(context),
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text('UPLOAD AVATAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCyan,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Avatars Grid (Item 0: Upload Card, followed by existing avatars)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              itemCount: avatarProv.avatars.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildUploadCard(context);
                }
                final avatar = avatarProv.avatars[index - 1];
                final isActive = avatar.id == avatarProv.activeAvatar.id;
                return _buildAvatarCard(context, avatar, isActive, avatarProv);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context) {
    return InkWell(
      onTap: () => UploadAvatarDialog.show(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryCyan.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryCyan.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.primaryCyan,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primaryCyan,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Upload Avatar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Import 2D portrait photo or 3D model (GLB, VRM)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCard(
    BuildContext context,
    AvatarModel avatar,
    bool isActive,
    AvatarProvider provider,
  ) {
    final hasValidFile = avatar.filePath != null &&
        File(avatar.filePath!).existsSync();

    return GlassCard(
      borderColor: isActive ? AppColors.primaryCyan : AppColors.borderSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail Preview Banner
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.bgDarkest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: (hasValidFile && avatar.type == AvatarType.customPortrait)
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(avatar.filePath!),
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.bgDarkest.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PORTRAIT',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryCyan,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: avatar.clothingColor,
                                border:
                                    Border.all(color: avatar.skinTone, width: 3),
                              ),
                              child: Icon(
                                avatar.type == AvatarType.customModel
                                    ? Icons.view_in_ar
                                    : (avatar.isCustom
                                        ? Icons.person_add
                                        : Icons.person),
                                size: 32,
                                color: avatar.skinTone,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bgElevated,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                avatar.type.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryCyan,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title & Description
          Row(
            children: [
              Expanded(
                child: Text(
                  avatar.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isActive)
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.primaryCyan,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            avatar.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isActive
                      ? null
                      : () => provider.setActiveAvatar(avatar),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    isActive ? 'SELECTED' : 'SELECT',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                tooltip: 'Duplicate Profile',
                onPressed: () => provider.duplicateAvatar(avatar),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 16),
                tooltip: 'Rename',
                onPressed: () => _showRenameDialog(context, avatar, provider),
              ),
              if (avatar.isCustom)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppColors.accentRed,
                  ),
                  tooltip: 'Delete',
                  onPressed: () => provider.deleteAvatar(avatar.id),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    AvatarModel avatar,
    AvatarProvider provider,
  ) {
    final controller = TextEditingController(text: avatar.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Rename Avatar Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Profile Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.renameAvatar(avatar.id, controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
