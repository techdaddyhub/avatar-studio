import 'package:flutter/material.dart';
import '../core/constants/default_avatars.dart';
import '../core/services/storage_service.dart';
import '../core/utils/path_sanitizer.dart';
import '../models/avatar_model.dart';
import '../models/scene_preset.dart';

class AvatarProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<AvatarModel> _avatars = [];
  AvatarModel _activeAvatar = DefaultAvatars.nova;
  ScenePreset _activeScene = ScenePreset.studioDark;
  bool _isLoading = true;

  AvatarProvider(this._storageService) {
    _loadInitialData();
  }

  List<AvatarModel> get avatars => _avatars;
  AvatarModel get activeAvatar => _activeAvatar;
  ScenePreset get activeScene => _activeScene;
  bool get isLoading => _isLoading;

  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    _avatars = await _storageService.loadAvatars();
    if (_avatars.isNotEmpty) {
      _activeAvatar = _avatars.first;
    }
    _isLoading = false;
    notifyListeners();
  }

  void setActiveAvatar(AvatarModel avatar) {
    _activeAvatar = avatar;
    notifyListeners();
  }

  void setActiveScene(ScenePreset scene) {
    _activeScene = scene;
    notifyListeners();
  }

  Future<void> duplicateAvatar(AvatarModel target) async {
    final copy = target.copyWith(
      id: 'avatar_${DateTime.now().millisecondsSinceEpoch}',
      name: '${target.name} (Copy)',
      isCustom: true,
      createdAt: DateTime.now(),
    );
    _avatars.add(copy);
    _activeAvatar = copy;
    await _storageService.saveAvatars(_avatars);
    notifyListeners();
  }

  Future<void> renameAvatar(String id, String newName) async {
    final index = _avatars.indexWhere((a) => a.id == id);
    if (index != -1) {
      _avatars[index] = _avatars[index].copyWith(name: newName);
      if (_activeAvatar.id == id) {
        _activeAvatar = _avatars[index];
      }
      await _storageService.saveAvatars(_avatars);
      notifyListeners();
    }
  }

  Future<bool> deleteAvatar(String id) async {
    if (_avatars.length <= 1) return false; // Prevent deleting the last avatar
    _avatars.removeWhere((a) => a.id == id);
    if (_activeAvatar.id == id) {
      _activeAvatar = _avatars.first;
    }
    await _storageService.saveAvatars(_avatars);
    notifyListeners();
    return true;
  }

  Future<void> updateActiveAvatar({
    String? name,
    Color? skinTone,
    Color? eyeColor,
    Color? hairColor,
    Color? clothingColor,
    double? keyLightIntensity,
    Color? keyLightColor,
    double? ambientIntensity,
    double? scale,
    double? offsetY,
  }) async {
    _activeAvatar = _activeAvatar.copyWith(
      name: name,
      skinTone: skinTone,
      eyeColor: eyeColor,
      hairColor: hairColor,
      clothingColor: clothingColor,
      keyLightIntensity: keyLightIntensity,
      keyLightColor: keyLightColor,
      ambientIntensity: ambientIntensity,
      scale: scale,
      offsetY: offsetY,
    );

    final idx = _avatars.indexWhere((a) => a.id == _activeAvatar.id);
    if (idx != -1) {
      _avatars[idx] = _activeAvatar;
    }
    await _storageService.saveAvatars(_avatars);
    notifyListeners();
  }

  Future<String?> importAvatarFile(
    String filePath,
    String name, {
    String? description,
  }) async {
    final isModel = PathSanitizer.isSupportedModel(filePath);
    final isImage = PathSanitizer.isSupportedImage(filePath);

    if (!isModel && !isImage) {
      return 'Unsupported file format. Supported: .glb, .gltf, .vrm, .png, .jpg, .webp';
    }

    final copiedPath = await _storageService.copyAssetSafely(filePath);
    if (copiedPath == null) {
      return 'Failed to safely store imported asset file.';
    }

    final imported = AvatarModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Custom Avatar' : name.trim(),
      type: isModel ? AvatarType.customModel : AvatarType.customPortrait,
      styleId: 'custom',
      description: description ??
          'Imported user asset from ${PathSanitizer.sanitizeFileName(filePath)}',
      filePath: copiedPath,
      isCustom: true,
      createdAt: DateTime.now(),
    );

    _avatars.add(imported);
    _activeAvatar = imported;
    await _storageService.saveAvatars(_avatars);
    notifyListeners();
    return null;
  }
}
