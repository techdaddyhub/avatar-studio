import 'dart:io';

class ObsDetector {
  ObsDetector._();

  static Future<bool> isObsInstalled() async {
    try {
      if (Platform.isLinux) {
        if (await File('/usr/bin/obs').exists() ||
            await File('/usr/local/bin/obs').exists() ||
            await Directory(
              '/var/lib/flatpak/app/com.obsproject.Studio',
            ).exists()) {
          return true;
        }
        final result = await Process.run('which', ['obs']);
        return result.exitCode == 0;
      } else if (Platform.isWindows) {
        return await Directory(r'C:\Program Files\obs-studio').exists() ||
            await Directory(r'C:\Program Files (x86)\obs-studio').exists();
      } else if (Platform.isMacOS) {
        return await Directory('/Applications/OBS.app').exists();
      }
    } catch (_) {}
    return false;
  }
}
