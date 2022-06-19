import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../../jaspr.dart';

abstract class BaseCommand extends Command<void> {
  Set<Process> activeProcesses = {};

  @override
  @mustCallSuper
  Future<void> run() async {
    ProcessSignal.sigint.watch().listen((signal) {
      shutdown();
    });
  }

  Future<void> waitActiveProcesses() {
    return Future.wait(activeProcesses.map((p) => p.exitCode));
  }

  Never shutdown([int exitCode = 1]) {
    for (var process in activeProcesses) {
      process.kill();
    }
    exit(exitCode);
  }

  Future<Process> runWebdev(List<String> args) async {
    var getDeps =
        await Process.run('dart', ['pub', 'deps', '--json'], stdoutEncoding: Utf8Codec(), stderrEncoding: Utf8Codec());

    if (getDeps.exitCode != 0) {
      stderr.write(getDeps.stderr);
      shutdown(getDeps.exitCode);
    }

    var depsJson = jsonDecode(getDeps.stdout as String);
    var webdev = (depsJson['packages'] as List).where((p) => p['name'] == 'webdev');

    Process process;

    if (webdev.isEmpty || webdev.first['kind'] == 'transitive') {
      var globalPackageList = await Process.run('dart', ['pub', 'global', 'list'], stdoutEncoding: Utf8Codec());
      var hasGlobalWebdev = (globalPackageList.stdout as String).contains('webdev');

      if (hasGlobalWebdev) {
        process = await Process.start('dart', ['pub', 'global', 'run', 'webdev', ...args]);
      } else {
        print("Jaspr needs webdev as a dev dependency in your project.\n"
            "Please run `dart pub add webdev --dev` and try again.");
        shutdown(1);
      }
    } else {
      process = await Process.start('dart', ['run', 'webdev', ...args]);
    }

    return process;
  }

  Future<String?> getEntryPoint(String? input) async {
    var entryPoints = [input, 'lib/main.dart', 'web/main.dart'];
    String? entryPoint;

    for (var path in entryPoints) {
      if (path == null) continue;
      if (await File(path).exists()) {
        entryPoint = path;
        break;
      } else if (path == input) {
        return null;
      }
    }

    return entryPoint;
  }

  Future<void> watchProcess(
    Process process, {
    bool pipeStdout = true,
    bool pipeStderr = true,
    bool Function(String)? until,
    bool Function(String)? hide,
    void Function(String)? listen,
    void Function()? onExit,
  }) async {
    if (pipeStderr) {
      process.stderr.listen((event) => stderr.add(event));
    }
    if (pipeStdout || listen != null) {
      bool pipe = pipeStdout;
      process.stdout.listen((event) {
        String? _decoded;
        String decoded() => _decoded ??= utf8.decode(event);

        listen?.call(decoded());

        if (pipe && until != null) pipe = !until(decoded());
        if (!pipe || (hide?.call(decoded()) ?? false)) return;
        stdout.add(event);
      });
    }
    activeProcesses.add(process);
    var exitCode = await process.exitCode;
    activeProcesses.remove(process);
    if (exitCode != 0) {
      onExit?.call();
      shutdown(exitCode);
    }
  }
}
