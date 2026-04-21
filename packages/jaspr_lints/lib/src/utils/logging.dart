import 'dart:io';

import 'package:path/path.dart' as path;

final logFile = getLogFile();

void log(String message) {
  final time = DateTime.now();
  final timeStr =
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}:'
      '${time.second.toString().padLeft(2, '0')}';
  logFile.writeAsStringSync('$timeStr $message\n', mode: FileMode.append, flush: true);
}

File getLogFile() {
  Directory dir;
  if (homeDir case final homeDir?) {
    dir = Directory(path.join(homeDir.path, '.jaspr')).absolute;
  } else {
    dir = Directory.systemTemp.createTempSync('jaspr_plugin_log_');
  }
  return File(path.join(dir.path, 'plugin_log.log'))..createSync(recursive: true);
}

/// Return the user's home directory for the current platform.
Directory? get homeDir {
  final envKey = Platform.operatingSystem == 'windows' ? 'APPDATA' : 'HOME';
  final home = Platform.environment[envKey] ?? '.';

  final dir = Directory(home).absolute;
  return dir.existsSync() ? dir : null;
}
