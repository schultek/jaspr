import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:meta/meta.dart';

import '../config.dart';
import '../helpers/analytics.dart';
import '../logging.dart';

sealed class CommandResult {
  const factory CommandResult.done(int status) = DoneCommandResult;
  const factory CommandResult.running(Future<dynamic> future, Future<void> Function() stop) = RunningCommandResult;
}

extension CommandResultDone on CommandResult? {
  FutureOr<int> get done async => switch (this) {
        DoneCommandResult r => r.status as FutureOr<int>,
        RunningCommandResult r => r.future.then((v) => v is int ? v : 0),
        _ => 0,
      };
}

class DoneCommandResult implements CommandResult {
  final int status;

  const DoneCommandResult(this.status);
}

class RunningCommandResult implements CommandResult {
  final Future<dynamic> future;
  final Future<void> Function() stop;

  const RunningCommandResult(this.future, this.stop);
}

abstract class BaseCommand extends Command<CommandResult?> {
  Set<FutureOr<void> Function()> guards = {};

  BaseCommand({Logger? logger}) : _logger = logger {
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Enable verbose logging.',
      negatable: false,
    );
  }

  /// [Logger] instance used to wrap stdout.
  Logger get logger => _logger ??= Logger(verbose);
  Logger? _logger;

  late final bool verbose = argResults?['verbose'] as bool? ?? false;

  final bool requiresPubspec = true;
  late JasprConfig? config;

  @override
  @mustCallSuper
  Future<CommandResult?> run() async {
    config = requiresPubspec ? await getConfig(logger) : null;

    await trackEvent(name, projectName: config?.pubspecYaml['name'], projectMode: config?.mode.name);

    ProcessSignal.sigint.watch().listen((signal) => shutdown());
    if (!Platform.isWindows) {
      ProcessSignal.sigterm.watch().listen((signal) => shutdown());
    }

    return null;
  }

  Future<void> stop() async {
    var gs = [...guards];
    guards.clear();
    for (var g in gs) {
      await g();
    }
  }

  Future<Never> shutdown([int exitCode = 1]) async {
    logger.complete(false);
    logger.write('Shutting down...');
    await stop();
    exit(exitCode);
  }

  Future<String> getEntryPoint(String? input) async {
    var entryPoint = input ?? 'lib/main.dart';

    if (!File(entryPoint).absolute.existsSync()) {
      logger.complete(false);
      logger.write("Cannot find entry point. Create a lib/main.dart file, or specify a file using --input.",
          level: Level.critical);
      await shutdown();
    }

    if (!entryPoint.startsWith('lib/')) {
      logger.write("Entry point must be located inside lib/ folder, got '$entryPoint'.", level: Level.critical);
      await shutdown();
    }

    return entryPoint;
  }

  void guardResource(FutureOr<void> Function() fn) {
    guards.add(fn);
  }

  Future<int> watchProcess(
    String name,
    Process process, {
    required Tag tag,
    String? progress,
    int? childPid,
    bool Function(String)? hide,
    bool Function()? onFail,
  }) async {
    if (progress != null) {
      logger.write(progress, tag: tag, progress: ProgressState.running);
    }

    var errSub = process.stderr.listen((event) {
      logger.write(utf8.decode(event), tag: tag, level: Level.error, progress: ProgressState.completed);
    });

    var outSub = process.stdout.map(utf8.decode).splitLines().listen((log) {
      if (hide != null && hide.call(log)) return;

      if (progress != null) {
        logger.write(log, tag: tag, progress: ProgressState.running);
      } else {
        logger.write(log, tag: tag);
      }
    });

    int? exitCode;
    bool wasKilled = false;
    guardResource(() async {
      if (exitCode == null) {
        logger.write("Terminating $name...");
        process.kill();
        if (childPid != null) {
          Process.killPid(childPid);
        }
        wasKilled = true;
        await errSub.cancel();
        await outSub.cancel();
        await process.exitCode;
      }
    });

    exitCode = await process.exitCode;

    if (wasKilled) {
      return exitCode;
    }

    await Future.delayed(Duration(seconds: 10));

    await errSub.cancel();
    await outSub.cancel();

    if (exitCode != 0 && (onFail == null || onFail())) {
      logger.complete(false);
      shutdown(exitCode);
    }

    logger.complete(true);

    return exitCode;
  }
}

extension on Stream<String> {
  Stream<String> splitLines() {
    var data = '';
    return transform(StreamTransformer.fromHandlers(
      handleData: (d, s) {
        data += d;
        int index;
        while ((index = data.indexOf('\n')) != -1) {
          s.add(data.substring(0, index + 1));
          data = data.substring(index + 1);
        }
      },
      handleDone: (s) {
        s.add(data);
      },
    ));
  }
}
