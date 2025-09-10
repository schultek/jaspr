import 'dart:io';

import 'base_command.dart';

class CleanCommand extends BaseCommand {
  CleanCommand({super.logger}) {
    if (Platform.isMacOS || Platform.isLinux) {
      argParser.addFlag(
        'kill',
        abbr: 'k',
        help: 'Kill runaway processes.',
        defaultsTo: null,
        negatable: false,
      );
    }
  }

  @override
  String get description => 'Delete the `build/` and `.dart_tool/` directories.';

  @override
  String get name => 'clean';

  @override
  String get category => 'Tooling';

  @override
  Future<int> runCommand() async {
    if (project.pubspecYaml != null) {
      var genDir = Directory('.dart_tool/jaspr/').absolute;
      if (genDir.existsSync()) {
        logger.write('Deleting .dart_tool/jaspr...');
        genDir.deleteSync(recursive: true);
      }

      var chromeDir = Directory('.dart_tool/webdev/chrome_user_data').absolute;
      if (chromeDir.existsSync()) {
        chromeDir.deleteSync(recursive: true);
      }

      var buildDir = Directory('build/jaspr/').absolute;
      if (buildDir.existsSync()) {
        logger.write('Deleting build/jaspr...');
        buildDir.deleteSync(recursive: true);
      }

      logger.write("Running 'dart run build_runner clean'...");
      await Process.run('dart', ['run', 'build_runner', 'clean']);
    }

    // TODO support windows
    if (Platform.isMacOS || Platform.isLinux) {
      var pids = await findRunawayProcesses([
        // server, vm, build_runner, flutter
        '8080', '8181', '5467', '5678'
      ]);

      if (pids.isNotEmpty) {
        bool kill = false;
        if (argResults!['kill'] != null) {
          kill = argResults!['kill'];
          if (kill) {
            logger.write("Killing ${pids.length} runaway processes.");
          }
        } else if (stdout.hasTerminal) {
          kill = logger.logger!.confirm('Kill ${pids.length} runaway processes?');
        }

        if (kill) {
          for (var pid in pids) {
            Process.killPid(pid);
          }
        }
      }
    }

    return 0;
  }
}

Future<List<int>> findRunawayProcesses(List<String> ports) async {
  var pids = <int>[];

  for (var port in ports) {
    var proc = await Process.run('lsof', ['-i', ':$port']);

    if (proc.exitCode == 0) {
      pids.addAll(
        (proc.stdout as String)
            .split('\n')
            .skip(1)
            .where((s) => s.startsWith('dart'))
            .map((s) => s.split(RegExp(r'\s+')).skip(1).first)
            .map(int.parse),
      );
    }
  }
  return pids;
}
