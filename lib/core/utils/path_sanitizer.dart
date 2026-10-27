import 'dart:io';
import 'package:path/path.dart' as p;

class PathSanitizer {
  PathSanitizer._();

  static const List<String> supportedModelExtensions = [
    '.glb',
    '.gltf',
    '.vrm',
  ];

  static const List<String> supportedImageExtensions = [
    '.png',
    '.jpg',
    '.jpeg',
    '.webp',
  ];

  /// Validates file extension
  static bool isSupportedModel(String path) {
    final ext = p.extension(path).toLowerCase();
    return supportedModelExtensions.contains(ext);
  }

  static bool isSupportedImage(String path) {
    final ext = p.extension(path).toLowerCase();
    return supportedImageExtensions.contains(ext);
  }

  /// Sanitizes filename to prevent directory traversal
  static String sanitizeFileName(String fileName) {
    final baseName = p.basename(fileName);
    // Remove control characters, null bytes, backslashes, and path separators
    final cleaned = baseName.replaceAll(
      RegExp(r'[\/\\:\*\?"<>\|\x00-\x1F]'),
      '_',
    );
    return cleaned.trim();
  }

  /// Validates that target path stays strictly inside the designated directory
  static bool isSafeSubpath(String parentDir, String candidatePath) {
    final canonicalParent = Directory(parentDir).resolveSymbolicLinksSync();
    final canonicalCandidate = File(candidatePath).resolveSymbolicLinksSync();
    return p.isWithin(canonicalParent, canonicalCandidate);
  }
}
