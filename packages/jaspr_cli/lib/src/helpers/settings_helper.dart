import 'dart:convert';
import 'dart:io';

import 'package:dart_data_home/dart_data_home.dart';
import 'package:path/path.dart' as path;

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
  if (settingsDir == null) return null;

  final settingsFile = File('${settingsDir.path}${path.separator}$_settingsFileName').absolute;
  if (!settingsFile.existsSync()) {
    settingsFile.createSync();
    settingsFile.writeAsStringSync('{"analytics": true}');
  }

  return settingsFile;
}();

Directory? getSettingsDirectory({Map<String, String>? environment}) {
  final settingsDir = Directory(getDartDataHome('jaspr', environment: environment));
  if (!settingsDir.existsSync()) {
    final success = _moveToNewSettingsDir(settingsDir, environment: environment);
    if (!success) {
      return null;
    }
  }

  return settingsDir;
}

bool _moveToNewSettingsDir(Directory newDir, {Map<String, String>? environment}) {
  try {
    newDir.createSync();
  } catch (_) {
    return false;
  }

  final envKey = Platform.operatingSystem == 'windows' ? 'APPDATA' : 'HOME';
  final env = environment ?? Platform.environment;
  final home = env[envKey] ?? '.';

  final homeDir = Directory(home).absolute;
  if (!homeDir.existsSync()) return true;

  final legacyDir = Directory(path.join(homeDir.path, '.jaspr')).absolute;
  if (!legacyDir.existsSync()) return true;

  stdout.writeln('Moving Jaspr settings directory to "${newDir.path}" (was "${legacyDir.path}")');

  try {
    for (final file in legacyDir.listSync(recursive: true)) {
      final copyTo = path.join(newDir.path, path.relative(file.path, from: legacyDir.path));

      try {
        if (file is Directory) {
          Directory(copyTo).createSync(recursive: true);
        } else if (file is File) {
          File(file.path).copySync(copyTo);
        } else if (file is Link) {
          Link(copyTo).createSync(file.targetSync(), recursive: true);
        }
      } catch (e) {
        if (path.split(file.path).contains('chrome_user_data')) {
          continue;
        }
        rethrow;
      }
    }

    legacyDir.deleteSync(recursive: true);
  } catch (e) {
    stdout.writeln('Error moving settings directory: $e');
  }

  return true;
}
