import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
// ignore: implementation_imports
import 'package:webdev/src/logging.dart';

abstract class BaseCommand extends Command<int> {
  Set<Process> activeProcesses = {};
  Set<Future<void> Function()> guards = {};

  BaseCommand({Logger? logger}) : _logger = logger {
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Enable verbose logging.',
      negatable: false,
    );
  }

  /// [Logger] instance used to wrap stdout.
  Logger get logger => _logger ??= Logger();

  Logger? _logger;

  bool get verbose => argResults?['verbose'] as bool? ?? false;

  @override
  @mustCallSuper
  Future<int> run() async {
    logger.level = verbose ? Level.verbose : Level.info;

    configureLogWriter(false, customLogWriter:
        (level, message, {loggerName, error, stackTrace}) {
      if (!verbose) return;
      if (level.value < 800) return;

      var log = formatLog(level, message,
          error: error,
          loggerName: loggerName,
          stackTrace: stackTrace,
          withColors: true);

      if (!log.endsWith('\n')) {
        log += '\n';
      }

      logger.write(log);
    });

    ProcessSignal.sigint.watch().listen((signal) {
      shutdown();
    });

    return ExitCode.success.code;
  }

  Future<void> waitActiveProcesses() {
    return Future.wait(activeProcesses.map((p) => p.exitCode));
  }

  Future<Never> shutdown([int exitCode = 1]) async {
    // for (var process in activeProcesses) {
    //   // this would leave open files and ports broken
    //   // we should wait for https://github.com/dart-lang/sdk/issues/49234 to implement a better way
    //   process.kill();
    // }

    await Future.wait([for (var g in guards) g()]);

    exit(exitCode);
  }

  Future<Process> runWebdev(List<String> args) async {
    var getDeps = await Process.run('dart', ['pub', 'deps', '--json'],
        stdoutEncoding: Utf8Codec(), stderrEncoding: Utf8Codec());

    if (getDeps.exitCode != 0) {
      stderr.write(getDeps.stderr);
      shutdown(getDeps.exitCode);
    }

    var depsJson = jsonDecode(getDeps.stdout as String);
    var webdev = (depsJson['packages'] as List).where((p) => p['name'] == 'webdev');

    Process process;

    if (webdev.isEmpty || webdev.first['kind'] == 'transitive') {
      var globalPackageList =
          await Process.run('dart', ['pub', 'global', 'list'], stdoutEncoding: Utf8Codec());
      var hasGlobalWebdev = (globalPackageList.stdout as String).contains('webdev');

      if (hasGlobalWebdev) {
        process = await Process.start('dart', ['pub', 'global', 'run', 'webdev', ...args]);
      } else {
        logger.err("Jaspr needs webdev as a dev dependency in your project.\n"
            "Please run `dart pub add webdev --dev` and try again.");
        await shutdown(1);
      }
    } else {
      process = await Process.start('dart', ['run', 'webdev', ...args]);
    }

    return process;
  }

  Future<String?> getEntryPoint(String? input) async {
    var entryPoints = [input, 'lib/main.dart', 'web/main.dart'];

    for (var path in entryPoints) {
      if (path == null) continue;
      if (await File(path).exists()) {
        return path;
      } else if (path == input) {
        return null;
      }
    }

    return null;
  }

  void guardResource(Future<void> Function() fn) {
    guards.add(fn);
  }

  Future<void> watchProcess(
    Process process, {
    bool pipeStdout = true,
    bool pipeStderr = true,
    String? progress,
    bool Function(String)? until,
    bool Function(String)? hide,
    void Function(String)? listen,
    void Function()? onExit,
  }) async {
    Progress? pg;
    if (progress != null) {
      pg = logger.progress(progress);
    }
    if (pipeStderr) {
      process.stderr.listen((event) {
        if (pg != null) {
          pg!.fail(utf8.decode(event).trimRight());
          pg = null;
          return;
        }
        logger.err(utf8.decode(event));
      });
    }
    if (pipeStdout || listen != null) {
      bool pipe = pipeStdout;
      process.stdout.listen((event) {
        String? decoded;
        String decode() => decoded ??= utf8.decode(event);

        listen?.call(decode());

        if (pipe && until != null) pipe = !until(decode());
        if (!pipe || (hide?.call(decode()) ?? false)) return;

        if (pg != null) {
          pg!.update(decode().trimRight());
          return;
        }
        logger.write(utf8.decode(event));
      });
    }
    activeProcesses.add(process);
    var exitCode = await process.exitCode;
    activeProcesses.remove(process);
    if (exitCode == 0) {
      pg?.complete();
    } else {
      pg?.fail();
      onExit?.call();
      shutdown(exitCode);
    }
  }
}
