import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:async/async.dart';
import 'package:meta/meta.dart';

import '../config.dart';
import '../helpers/analytics.dart';
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
  JasprConfig get config => _config!;
  JasprConfig? _config;

  @override
  @mustCallSuper
  Future<int> run() async {
    if (requiresPubspec) {
      _config = await getConfig(logger);
    }

    await trackEvent(name, projectName: _config?.pubspecYaml['name'], projectMode: _config?.mode.name);

    var cancelCount = 0;
    final cancelSub = StreamGroup.merge([
      ProcessSignal.sigint.watch(),
      // SIGTERM is not supported on Windows.
      Platform.isWindows ? const Stream.empty() : ProcessSignal.sigterm.watch()
    ]).listen((signal) async {
      cancelCount++;
      if (cancelCount > 1) exit(1);
      shutdown();
    });

    try {
      final result = await runCommand();
      return result;
    } finally {
      await cancelSub.cancel();
      await stop();
    }
  }

  Future<int> runCommand();

  Future<void> stop() async {
    var gs = [...guards];
    guards.clear();
    for (var g in gs) {
      await g();
    }
  }

  bool _isShutdown = false;

  Future<void> shutdown() async {
    if (_isShutdown) return;
    _isShutdown = true;

    logger.complete(false);
    logger.write('Shutting down...');

    await stop();
    logger.logger?.flush();
  }

  Future<String> getEntryPoint(String? input, [bool forceInsideLib = false]) async {
    var entryPoint = input ?? 'lib/main.dart';

    if (!File(entryPoint).absolute.existsSync()) {
      logger.complete(false);
      logger.write("Cannot find entry point. Create a lib/main.dart file, or specify a file using --input.",
          level: Level.critical);
      await shutdown();
      exit(1);
    }

    if (forceInsideLib && !entryPoint.startsWith('lib/')) {
      logger.write("Entry point must be located inside lib/ folder, got '$entryPoint'.", level: Level.critical);
      await shutdown();
      exit(1);
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
        wasKilled = true;
        await errSub.cancel();
        await outSub.cancel();
        await process.exitCode;
      }
    });

    exitCode = await process.exitCode.then<int>((c) => Future.delayed(Duration(seconds: 1), () => c));

    if (wasKilled) {
      return exitCode;
    }

    await Future.delayed(Duration(seconds: 2));

    await errSub.cancel();
    await outSub.cancel();

    if (exitCode != 0 && (onFail == null || onFail())) {
      logger.complete(false);
      await shutdown();
      exit(exitCode);
    }

    logger.complete(true);

    return exitCode;
  }

  void checkWasmSupport() {
    var package = '${config.usesJasprWebCompilers ? 'jaspr' : 'build'}_web_compilers';
    var version = config.pubspecYaml['dev_dependencies']?[package];
    if (version is! String || !version.startsWith(RegExp(r'\^?4.1.'))) {
      usageException('Using "--experimental-wasm" requires $package 4.1.0 or newer.');
    }

    if (config.usesFlutter) {
      usageException('Using "--experimental-wasm" is not supported together with flutter embedding.');
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
