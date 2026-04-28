import 'dart:io';

import 'package:dart_data_home/dart_data_home.dart';
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
  return File(path.join(dataHome, 'plugin_log.log'))..createSync(recursive: true);
}

final String dataHome = getDartDataHome('jaspr');
