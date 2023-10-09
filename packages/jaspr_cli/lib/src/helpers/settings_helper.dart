import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

const String _settingsDirectoryName = '.jaspr';
const String _settingsFileName = 'jaspr.json';

T? getSetting<T>(String key) {
  try {
    return _settings?[key] as T?;
  } catch (_) {
    return null;
  }
}

void updateSetting(String key, Object value) {
  (_settings ?? {})[key] = value;
  _writeSettings();
}

Map<String, dynamic>? _settings = _loadSettings();

Map<String, dynamic>? _loadSettings() {
  if (settingsFile == null) {
    return null;
  }
  try {
    var str = settingsFile!.readAsStringSync();
    return jsonDecode(str);
  } catch (_) {
    return null;
  }
}

void _writeSettings() {
  if (settingsFile == null) {
    return;
  }
  try {
    settingsFile!.writeAsStringSync(jsonEncode(_settings ?? {}));
  } catch (_) {}
}

final File? settingsFile = () {
  final settingsDir = getSettingsDirectory();
  if (settingsDir == null) {
    // Some systems don't support user home directories.
    return null;
  }

  if (!settingsDir.existsSync()) {
    try {
      settingsDir.createSync();
    } catch (e) {
      // If we can't create the directory for the analytics settings, fail
      // gracefully by returning null.
      return null;
    }
  }

  final settingsFile = File('${settingsDir.absolute.path}${path.separator}$_settingsFileName');
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
/// This can return null under some conditions, including when the user's home
/// directory does not exist.
Directory? getSettingsDirectory() {
  var dir = homeDir;
  if (dir == null) {
    return null;
  }
  return Directory(path.join(dir.path, _settingsDirectoryName));
}

/// Return the user's home directory for the current platform.
Directory? get homeDir {
  var envKey = Platform.operatingSystem == 'windows' ? 'APPDATA' : 'HOME';
  var home = Platform.environment[envKey] ?? '.';

  var dir = Directory(home);
  return dir.existsSync() ? dir : null;
}
