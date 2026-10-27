import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../models/avatar_model.dart';
import '../../models/billing_models.dart';
import '../constants/default_avatars.dart';
import '../utils/path_sanitizer.dart';

class StorageService {
  Directory? _appDir;

  Future<void> init() async {
    try {
      _appDir = await getApplicationSupportDirectory();
    } catch (_) {
      // Fallback for desktop test environments
      _appDir = Directory(
        p.join(Directory.current.path, '.avatar_studio_data'),
      );
    }
    if (!await _appDir!.exists()) {
      await _appDir!.create(recursive: true);
    }
  }

  File get _profilesFile => File(p.join(_appDir!.path, 'avatar_profiles.json'));
  File get _settingsFile => File(p.join(_appDir!.path, 'user_settings.json'));
  File get _subscriptionFile =>
      File(p.join(_appDir!.path, 'active_subscription.json'));

  Future<SubscriptionRecord?> loadSubscription() async {
    try {
      if (await _subscriptionFile.exists()) {
        final content = await _subscriptionFile.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return SubscriptionRecord.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveSubscription(SubscriptionRecord record) async {
    try {
      await _subscriptionFile.writeAsString(jsonEncode(record.toJson()));
    } catch (_) {}
  }

  Future<void> clearSubscription() async {
    try {
      if (await _subscriptionFile.exists()) {
        await _subscriptionFile.delete();
      }
    } catch (_) {}
  }

  Future<List<AvatarModel>> loadAvatars() async {
    try {
      if (!await _profilesFile.exists()) {
        final initial = DefaultAvatars.all;
        await saveAvatars(initial);
        return initial;
      }
      final content = await _profilesFile.readAsString();
      final List<dynamic> list = jsonDecode(content) as List<dynamic>;
      final avatars = list
          .map((item) => AvatarModel.fromJson(item as Map<String, dynamic>))
          .toList();
      if (avatars.isEmpty) {
        return DefaultAvatars.all;
      }
      return avatars;
    } catch (e) {
      return DefaultAvatars.all;
    }
  }

  Future<void> saveAvatars(List<AvatarModel> avatars) async {
    try {
      final jsonList = avatars.map((a) => a.toJson()).toList();
      await _profilesFile.writeAsString(jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<Map<String, dynamic>> loadSettings() async {
    try {
      if (await _settingsFile.exists()) {
        final content = await _settingsFile.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      await _settingsFile.writeAsString(jsonEncode(settings));
    } catch (_) {}
  }

  /// Copies an imported avatar file into safe sandboxed local storage
  Future<String?> copyAssetSafely(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      final safeName =
          '${DateTime.now().millisecondsSinceEpoch}_${PathSanitizer.sanitizeFileName(p.basename(sourcePath))}';
      final assetsDir = Directory(p.join(_appDir!.path, 'assets'));
      if (!await assetsDir.exists()) {
        await assetsDir.create(recursive: true);
      }
      final destinationPath = p.join(assetsDir.path, safeName);
      await sourceFile.copy(destinationPath);
      return destinationPath;
    } catch (_) {
      return null;
    }
  }
}
