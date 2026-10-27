import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/avatar_provider.dart';

class UploadAvatarDialog extends StatefulWidget {
  const UploadAvatarDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const UploadAvatarDialog(),
    );
  }

  @override
  State<UploadAvatarDialog> createState() => _UploadAvatarDialogState();
}

class _UploadAvatarDialogState extends State<UploadAvatarDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String? _selectedFilePath;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isModel = false;
  bool _isImporting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedFilePath = null;
          _selectedFileName = null;
          _selectedFileSize = null;
          _errorMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickFile({required bool forModel}) async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final allowed = forModel
          ? ['glb', 'gltf', 'vrm']
          : ['png', 'jpg', 'jpeg', 'webp'];

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowed,
      );

      if (result.isNotEmpty && result.first.path != null) {
        final path = result.first.path!;
        final file = File(path);
        final exists = await file.exists();
        if (!exists) {
          setState(() => _errorMessage = 'Selected file does not exist on disk.');
          return;
        }

        final size = await file.length();
        final rawName = p.basenameWithoutExtension(path);

        setState(() {
          _selectedFilePath = path;
          _selectedFileName = p.basename(path);
          _selectedFileSize = size;
          _isModel = forModel;
          if (_nameController.text.trim().isEmpty) {
            _nameController.text = _formatAutoName(rawName);
          }
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to open file picker: $e');
    }
  }

  String _formatAutoName(String raw) {
    if (raw.isEmpty) return 'My Avatar';
    return raw
        .replaceAll(RegExp(r'[_-]'), ' ')
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join(' ');
  }

  Future<void> _handleUpload(AvatarProvider provider) async {
    if (_selectedFilePath == null) {
      setState(() => _errorMessage = 'Please choose a file to upload first.');
      return;
    }

    final avatarName = _nameController.text.trim().isEmpty
        ? (_selectedFileName ?? 'Custom Avatar')
        : _nameController.text.trim();

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    final error = await provider.importAvatarFile(
      _selectedFilePath!,
      avatarName,
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isImporting = false;
        _errorMessage = error;
      });
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Avatar "$avatarName" successfully imported and set active!'),
          backgroundColor: AppColors.primaryCyan,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AvatarProvider>();

    return Dialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.primaryCyan,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload New Avatar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Import your 2D portrait photo or 3D rigged avatar model',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryCyan,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primaryCyan,
              indicatorWeight: 2.5,
              tabs: const [
                Tab(
                  icon: Icon(Icons.portrait, size: 18),
                  text: '2D Portrait Photo',
                ),
                Tab(
                  icon: Icon(Icons.view_in_ar, size: 18),
                  text: '3D Avatar Model',
                ),
              ],
            ),

            // Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPortraitTab(),
                  _buildModelTab(),
                ],
              ),
            ),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.accentRed, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12, color: AppColors.accentRed),
                      ),
                    ),
                  ],
                ),
              ),

            // Footer actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isImporting || _selectedFilePath == null
                        ? null
                        : () => _handleUpload(provider),
                    icon: _isImporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: Text(_isImporting ? 'IMPORTING...' : 'SAVE & ACTIVATE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildPortraitTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropZone(
            forModel: false,
            title: 'Click to select a portrait image',
            subtitle: 'Supports PNG (transparent recommended), JPG, JPEG, or WebP',
            icon: Icons.add_photo_alternate_outlined,
          ),
          const SizedBox(height: 20),
          if (_selectedFilePath != null && !_isModel) ...[
            _buildFileSelectedPreview(isImage: true),
            const SizedBox(height: 20),
          ],
          _buildMetadataInputs(),
          const SizedBox(height: 16),
          _buildFeatureNotice(
            icon: Icons.auto_awesome,
            title: 'Real-Time Portrait Animation',
            description:
                'Uploaded portraits are animated using real-time face tracking (yaw, pitch, roll tilt, natural blinking) and voice energy-driven lip synchronization.',
          ),
        ],
      ),
    );
  }

  Widget _buildModelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropZone(
            forModel: true,
            title: 'Click to select a 3D avatar model',
            subtitle: 'Supports GLB (binary glTF), glTF, or VRM humanoid models',
            icon: Icons.view_in_ar_outlined,
          ),
          const SizedBox(height: 20),
          if (_selectedFilePath != null && _isModel) ...[
            _buildFileSelectedPreview(isImage: false),
            const SizedBox(height: 20),
          ],
          _buildMetadataInputs(),
          const SizedBox(height: 16),
          _buildFeatureNotice(
            icon: Icons.layers_outlined,
            title: 'Rig & Blendshape Mapping',
            description:
                'Supports VRM and standard glTF blendshapes: eye blinking, visemes (aa, ee, oh), jaw open, and head rotation bones for high-fidelity live performance.',
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone({
    required bool forModel,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => _pickFile(forModel: forModel),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.bgDarkest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedFilePath != null && _isModel == forModel
                ? AppColors.primaryCyan
                : AppColors.borderSubtle,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Icon(icon, color: AppColors.primaryCyan, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectedPreview({required bool isImage}) {
    final sizeKb = (_selectedFileSize ?? 0) / 1024;
    final sizeString = sizeKb > 1024
        ? '${(sizeKb / 1024).toStringAsFixed(2)} MB'
        : '${sizeKb.toStringAsFixed(1)} KB';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (isImage && _selectedFilePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_selectedFilePath!),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.bgDarkest,
                  child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                ),
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.bgDarkest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primaryCyan,
                size: 32,
              ),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFileName ?? 'Selected File',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sizeString,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedFilePath ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.change_circle_outlined, color: AppColors.primaryCyan),
            tooltip: 'Pick another file',
            onPressed: () => _pickFile(forModel: !isImage),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avatar Name',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g. Creator Avatar, Virtual Host',
            filled: true,
            fillColor: AppColors.bgDarkest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Description / Tags (Optional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _descController,
          decoration: InputDecoration(
            hintText: 'e.g. Transparent portrait for YouTube / Twitch streaming',
            filled: true,
            fillColor: AppColors.bgDarkest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureNotice({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgDarkest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryCyan),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
