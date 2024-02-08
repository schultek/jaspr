import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart' show ExitCode;
import 'package:meta/meta.dart';

import '../analytics.dart';
import '../config.dart';
import '../logging.dart';

abstract class BaseCommand extends Command<int> {
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
  Future<int> run() async {
    config = requiresPubspec ? await getConfig(logger) : null;

    await trackEvent(name, projectName: config?.pubspecYaml['name']);

    ProcessSignal.sigint.watch().listen((signal) => shutdown());
    if (!Platform.isWindows) {
      ProcessSignal.sigterm.watch().listen((signal) => shutdown());
    }

    return ExitCode.success.code;
  }

  Future<Never> shutdown([int exitCode = 1]) async {
    logger.complete(false);
    logger.write('Shutting down...');
    for (var g in guards) {
      await g();
    }
    guards.clear();
    exit(exitCode);
  }

  Future<String> getEntryPoint(String? input) async {
    var entryPoint = input ?? 'lib/main.dart';

    if (!File(entryPoint).existsSync()) {
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

  Future<void> watchProcess(
    String name,
    Process process, {
    required Tag tag,
    String? progress,
    bool Function(String)? hide,
    void Function()? onFail,
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
        wasKilled = true;
        await errSub.cancel();
        await outSub.cancel();
        await process.exitCode;
      }
    });

    exitCode = await process.exitCode;

    if (wasKilled) {
      return;
    }

    await errSub.cancel();
    await outSub.cancel();

    if (exitCode == 0) {
      logger.complete(true);
    } else {
      logger.complete(false);
      onFail?.call();
      shutdown(exitCode);
    }
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
