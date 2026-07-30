import 'dart:io';

import '../process_runner.dart';
import '../project.dart';
import 'base_command.dart';

class CleanCommand extends BaseCommand {
  CleanCommand({super.logger}) {
    argParser.addFlag('kill', abbr: 'k', help: 'Kill runaway processes.', defaultsTo: null, negatable: false);
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
      final genDir = Directory('.dart_tool/jaspr/').absolute;
      if (genDir.existsSync()) {
        logger.write('Deleting .dart_tool/jaspr...');
        genDir.deleteSync(recursive: true);
      }

      final chromeDir = Directory('.dart_tool/webdev/chrome_user_data').absolute;
      if (chromeDir.existsSync()) {
        chromeDir.deleteSync(recursive: true);
      }

      final buildDir = Directory('build/jaspr/').absolute;
      if (buildDir.existsSync()) {
        logger.write('Deleting build/jaspr...');
        buildDir.deleteSync(recursive: true);
      }

      logger.write("Running 'dart run build_runner clean'...");
      await ProcessRunner.instance.run(dartExecutable, ['run', 'build_runner', 'clean']);
    }

    final pids = await findRunawayProcesses([
      // server, vm, proxy, flutter
      defaultServePort, '8181', serverProxyPort, flutterProxyPort,
    ]);

    if (pids.isNotEmpty) {
      bool kill = false;
      if (argResults!.wasParsed('kill')) {
        kill = argResults!.flag('kill');
        if (kill) {
          logger.write('Killing ${pids.length} runaway processes.');
        }
      } else if (stdout.hasTerminal) {
        kill = await logger.confirm('Kill ${pids.length} runaway processes?');
      }

      if (kill) {
        for (final pid in pids) {
          Process.killPid(pid);
        }
      }
    }

    return 0;
  }
}

Future<List<int>> findRunawayProcesses(List<String> ports) async {
  final pids = <int>{};

  if (Platform.isWindows) {
    final proc = await ProcessRunner.instance.run('netstat', ['-ano']);
    if (proc.exitCode == 0) {
      final lines = (proc.stdout as String).split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        final tokens = trimmed.split(RegExp(r'\s+'));
        if (tokens.length < 4) continue;

        final localAddress = tokens[1];
        final parts = localAddress.split(':');
        if (parts.isNotEmpty) {
          final port = parts.last;
          if (ports.contains(port)) {
            final pidStr = tokens.last;
            final pid = int.tryParse(pidStr);
            if (pid != null && pid != 0) {
              pids.add(pid);
            }
          }
        }
      }
    }
  } else {
    for (final port in ports) {
      final proc = await ProcessRunner.instance.run('lsof', ['-i', ':$port']);

      if (proc.exitCode == 0) {
        final newPids = (proc.stdout as String)
            .split('\n')
            .skip(1)
            .where((s) => s.startsWith('dart'))
            .map((s) => s.split(RegExp(r'\s+')).skip(1).first)
            .map(int.parse);
        pids.addAll(newPids);
      }
    }
  }
  return pids.toList();
}
