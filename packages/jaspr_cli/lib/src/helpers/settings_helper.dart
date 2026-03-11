import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

const String _settingsDirectoryName = '.jaspr';
const String _settingsFileName = 'jaspr.json';

T? getSetting<T>(String key) {
  try {
    return _settings[key] as T?;
  } catch (_) {
    return null;
  }
}

void updateSetting(String key, Object value) {
  _settings[key] = value;
  _writeSettings();
}

Map<String, Object?> _settings = _loadSettings() ?? {};

Map<String, Object?>? _loadSettings() {
  if (settingsFile case final settingsFile?) {
    try {
      final str = settingsFile.readAsStringSync();
      return jsonDecode(str) as Map<String, Object?>;
    } catch (_) {}
  }
  return null;
}

void _writeSettings() {
  if (settingsFile case final settingsFile?) {
    try {
      settingsFile.writeAsStringSync(jsonEncode(_settings));
    } catch (_) {}
  }
}

final File? settingsFile = () {
  final settingsDir = getSettingsDirectory();
  if (!settingsDir.existsSync()) {
    try {
      settingsDir.createSync();
    } catch (e) {
      // If we can't create the directory for the analytics settings, fail
      // gracefully by returning null.
      return null;
    }
  }

  final settingsFile = File('${settingsDir.path}${path.separator}$_settingsFileName').absolute;
  if (!settingsFile.existsSync()) {
    settingsFile.createSync();
    settingsFile.writeAsStringSync('{"analytics": true}');
  }

  return settingsFile;
}();

/// The directory used to store the settings file.
///
/// Typically, the directory is `~/.dart/`.
///
/// When the user's home directory does not exist, a temporary directory is used.
Directory getSettingsDirectory() {
  final dir = homeDir ?? Directory(path.join(Directory.systemTemp.path, Platform.environment['USER'] ?? ''));
  final settingsDir = Directory(path.join(dir.path, _settingsDirectoryName));
  settingsDir.createSync(recursive: true);
  return settingsDir.absolute;
}

/// Return the user's home directory for the current platform.
Directory? get homeDir {
  final envKey = Platform.operatingSystem == 'windows' ? 'APPDATA' : 'HOME';
  final home = Platform.environment[envKey] ?? '.';

  final dir = Directory(home).absolute;
  return dir.existsSync() ? dir : null;
}
