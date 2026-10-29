import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../core/constants/default_face_swap_targets.dart';
import '../core/services/storage_service.dart';
import '../core/utils/path_sanitizer.dart';
import '../models/face_swap_model.dart';
import '../services/face_swap/face_swap_engine.dart';
import 'tracking_provider.dart';
import 'audio_sync_provider.dart';

class FaceSwapProvider extends ChangeNotifier {
  final StorageService storageService;
  final FaceSwapEngine _engine = FaceSwapEngine();

  final List<FaceSwapTarget> _targets = [...DefaultFaceSwapTargets.presets];
  FaceSwapTarget? _selectedTarget;
  FaceSwapSettings _settings = const FaceSwapSettings();
  FaceSwapFrame? _currentFrame;

  bool _isSwapping = false;
  bool _showMesh = false;
  final double _fps = 60.0;
  String _statusMessage = 'Select target face and click Start AI Face Swap.';

  FaceSwapProvider({required this.storageService}) {
    _selectedTarget = _targets.first;
  }

  List<FaceSwapTarget> get targets => _targets;
  FaceSwapTarget? get selectedTarget => _selectedTarget;
  FaceSwapSettings get settings => _settings;
  FaceSwapFrame? get currentFrame => _currentFrame;
  bool get isSwapping => _isSwapping;
  bool get showMesh => _showMesh;
  double get fps => _fps;
  String get statusMessage => _statusMessage;

  void selectTarget(FaceSwapTarget target) {
    _selectedTarget = target;
    notifyListeners();
  }

  void toggleMesh() {
    _showMesh = !_showMesh;
    notifyListeners();
  }

  void updateSettings(FaceSwapSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  /// Starts real-time AI Face-Swapping
  void startSwapping({
    required TrackingProvider trackingProvider,
    required AudioSyncProvider audioProvider,
  }) {
    if (_selectedTarget == null) return;

    _isSwapping = true;
    _statusMessage =
        'Real-time AI Face Swap active: ${_selectedTarget!.name} (60 FPS)';
    notifyListeners();

    _engine.start(
      target: _selectedTarget!,
      settings: _settings,
      getTracking: () => trackingProvider.state,
      getAudio: () => audioProvider.state,
      onFrameReady: (frame) {
        _currentFrame = frame;
        notifyListeners();
      },
    );
  }

  /// Stops face swap processing
  void stopSwapping() {
    _engine.stop();
    _isSwapping = false;
    _currentFrame = null;
    _statusMessage = 'AI Face Swap stopped. In standby.';
    notifyListeners();
  }

  /// Allows user to upload any reference photo (JPG/PNG) as a target face
  Future<bool> uploadCustomFacePhoto() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        dialogTitle: 'Select Target Face Photo for Real-Time Swap',
      );

      if (result.isNotEmpty && result.first.path != null) {
        final originalPath = result.first.path!;
        final sanitizedFileName = PathSanitizer.sanitizeFileName(
          p.basename(originalPath),
        );

        if (!PathSanitizer.isSupportedImage(sanitizedFileName)) {
          _statusMessage =
              'Unsupported file format. Please upload JPG, PNG, or WebP.';
          notifyListeners();
          return false;
        }

        // Copy photo to local application storage
        final destDir = Directory(
          p.join(Directory.current.path, '.avatar_studio_data', 'custom_faces'),
        );
        if (!await destDir.exists()) {
          await destDir.create(recursive: true);
        }

        final targetFilePath = p.join(
          destDir.path,
          '${DateTime.now().millisecondsSinceEpoch}_$sanitizedFileName',
        );
        await File(originalPath).copy(targetFilePath);

        final rawName = p.basenameWithoutExtension(sanitizedFileName).replaceAll('_', ' ').trim();
        final newTarget = FaceSwapTarget(
          id: 'custom_face_${DateTime.now().millisecondsSinceEpoch}',
          name: rawName.isEmpty ? 'Custom Face' : rawName,
          category: 'Custom Upload',
          description: 'User uploaded reference photo for real-time swap.',
          imagePath: targetFilePath,
          skinToneHex: '#E2B89B',
          isCustom: true,
          createdAt: DateTime.now(),
        );

        _targets.insert(0, newTarget);
        _selectedTarget = newTarget;
        _statusMessage =
            'Target face photo "${newTarget.name}" loaded successfully!';
        notifyListeners();
        return true;
      }
    } catch (e) {
      _statusMessage = 'Failed to load face photo: $e';
      notifyListeners();
    }
    return false;
  }

  @override
  void dispose() {
    _engine.stop();
    super.dispose();
  }
}
