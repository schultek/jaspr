import 'dart:io';

import 'package:mason/mason.dart';

Future<void> cleanProject(Logger logger) async {
  var genDir = Directory('.dart_tool/jaspr/');

  if (await genDir.exists()) {
    logger.info('Deleting .dart_tool/jaspr/');
    await genDir.delete(recursive: true);
  }

  var buildDir = Directory('build/jaspr/');

  if (await buildDir.exists()) {
    logger.info('Deleting build/jaspr/');
    await buildDir.delete(recursive: true);
  }

  // server
  await closeProcesses('8080', logger);
  // vm service
  await closeProcesses('8181', logger);
  // build runner
  await closeProcesses('5467', logger);
  // flutter
  await closeProcesses('5678', logger);
}

Future<void> closeProcesses(String port, Logger logger) async {
  var ports = await Process.run('lsof', ['-i', ':$port']);

  if (ports.exitCode == 0) {
    var pids = (ports.stdout as String)
        .split('\n')
        .skip(1)
        .where((s) => s.startsWith('dart'))
        .map((s) => s.split(RegExp(r'\s+')).skip(1).first);
    logger.info('Killing ${pids.length} processes on port $port.');
    await Future.wait([
      for (var pid in pids) Process.run('kill', [pid]),
    ]);
  }
}
