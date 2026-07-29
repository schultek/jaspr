import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:async/async.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:pub_updater/pub_updater.dart';

import '../helpers/analytics.dart';
import '../logging.dart';
import '../project.dart';
import '../utils.dart';

abstract class BaseCommand extends Command<int> {
  Set<FutureOr<void> Function()> guards = {};

  BaseCommand({Logger? logger}) : _logger = logger {
    argParser.addFlag('verbose', abbr: 'v', help: 'Enable verbose logging.', negatable: false);
  }

  /// [Logger] instance used to wrap stdout.
  Logger get logger => _logger ??= Logger(verbose);
  Logger? _logger;

  late final bool verbose = argResults?.flag('verbose') ?? false;

  late final Project project = Project(logger);
  late final updater = PubUpdater(null, getPubDevBaseUrl());

  @override
  @mustCallSuper
  Future<int> run() async {
    await trackEvent(
      name,
      projectName: project.pubspecYaml?['name'] as String?,
      projectMode: project.modeOrNull?.name,
    );

    var cancelCount = 0;
    final cancelSub =
        StreamGroup.merge([
          ProcessSignal.sigint.watch(),
          // SIGTERM is not supported on Windows.
          Platform.isWindows ? const Stream<void>.empty() : ProcessSignal.sigterm.watch(),
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
    logger.clearFooter();
    final gs = [...guards];
    guards.clear();
    for (final g in gs) {
      await g();
    }
  }

  Future<Never>? _shutdownFuture;

  Future<Never> shutdown() async {
    if (_shutdownFuture != null) return _shutdownFuture!;

    _shutdownFuture = Future<Never>.sync(() async {
      logger.complete(false);

      if (guards.isNotEmpty) {
        logger.write('\nShutting down...');
        await stop();
      }

      exit(1);
    });

    return _shutdownFuture!;
  }

  Future<void> ensureInProject({
    bool requirePubspecYaml = true,
    bool requireJasprDependency = true,
    bool requireJasprMode = true,
    bool preferBuilderDependency = true,
    bool checkJasprDependencyVersion = true,
  }) async {
    if (requirePubspecYaml) {
      project.requirePubspecYaml;
    }
    if (requireJasprDependency) {
      project.requireJasprDependency;
    }
    if (requireJasprMode) {
      project.requireMode;
    }
    if (preferBuilderDependency) {
      await project.preferJasprBuilderDependency();
    }
    if (checkJasprDependencyVersion) {
      project.checkJasprDependencyVersion();
    }
  }

  Future<String?> getServerEntryPoint(String? target) async {
    if (project.requireMode == JasprMode.client) {
      return null; // No server entry point in client mode.
    }
    if (target != null) {
      if (!target.endsWith('.server.dart')) {
        logger.write(
          "Specified entry point '$target' must end in '.server.dart'.",
          level: Level.critical,
        );
        await shutdown();
      }
      if (!File(target).absolute.existsSync()) {
        logger.write(
          "Specified entry point '$target' does not exist.",
          level: Level.critical,
        );
        await shutdown();
      }
      return target;
    }

    final entryPoint = await _findServerEntrypoint();
    return entryPoint;
  }

  Future<String> _findServerEntrypoint() async {
    final mainFile = File('lib/main.server.dart');
    if (await mainFile.absolute.exists()) {
      return mainFile.path;
    }

    final binDir = Directory('bin/').absolute;
    final libDir = Directory('lib/').absolute;

    if (binDir.existsSync()) {
      await for (final entity in binDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.server.dart')) {
          return entity.path;
        }
      }
    }

    if (libDir.existsSync()) {
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.server.dart')) {
          return entity.path;
        }
      }
    }

    logger.write(
      'No server entrypoint found in "bin/" or "lib/". Make sure to have at least one "*.server.dart" file (usually "lib/main.server.dart") in your project.',
      level: Level.critical,
    );
    await shutdown();
  }

  void guardResource(FutureOr<void> Function() fn) {
    guards.add(fn);
  }

  Future<int> watchProcess(
    String name,
    Process process, {
    Tag tag = Tag.none,
    String? progress,
    bool Function(String)? hide,
    bool Function()? onFail,
    Level? Function(String)? levelFor,
    void Function(int)? onComplete,
  }) async {
    if (progress != null) {
      logger.write(progress, tag: tag, progress: ProgressState.running);
    }

    final errSub = process.stderr.listen((event) {
      logger.write(utf8.decode(event), tag: tag, level: Level.error, progress: ProgressState.completed);
    });

    final outSub = process.stdout.map(utf8.decode).splitLines().listen((log) {
      if (hide != null && hide.call(log)) return;

      final level = levelFor?.call(log) ?? Level.info;
      if (progress != null) {
        logger.write(log, tag: tag, level: level, progress: ProgressState.running);
      } else {
        logger.write(log, tag: tag, level: level);
      }
    });

    int? exitCode;
    bool wasKilled = false;
    guardResource(() async {
      if (exitCode == null) {
        logger.write('Terminating $name...', level: Level.debug);
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

    await Future<void>.delayed(Duration(milliseconds: 300));

    await errSub.cancel();
    await outSub.cancel();

    onComplete?.call(exitCode);

    if (exitCode != 0 && (onFail == null || onFail())) {
      logger.complete(false);
      await shutdown();
    }

    logger.complete(true);

    return exitCode;
  }

  Future<void> copyToBuildDir(String from, [List<String> targets = const ['']]) async {
    final to = project.requireMode != JasprMode.server ? 'build/jaspr' : 'build/jaspr/web';

    // Pending relative paths to copy or inspect in discovery order.
    final moveTargets = ListQueue<String>.of(targets);
    final visitedTargets = <String>{};

    final moves = <Future<void>>[];
    while (moveTargets.isNotEmpty) {
      final moveTarget = p.normalize(moveTargets.removeFirst());

      // Explicit targets could overlap with paths discovered while traversing directories.
      if (!visitedTargets.add(moveTarget)) {
        continue;
      }

      final file = File('$from/$moveTarget').absolute;
      final directory = Directory('$from/$moveTarget').absolute;
      if (file.existsSync()) {
        moves.add(file.copy(File('$to/$moveTarget').absolute.path));
      } else if (directory.existsSync()) {
        await Directory('$to/$moveTarget').absolute.create(recursive: true);

        // Queue only direct children.
        // Recursive listing here would enqueue descendants again
        // each time one of their parent directories is processed.
        await for (final entity in directory.list(recursive: false)) {
          final path = p.relative(entity.absolute.path, from: p.join(Directory.current.absolute.path, from));
          moveTargets.add(path);
        }
      }
    }

    await moves.wait;
  }
}

extension on Stream<String> {
  Stream<String> splitLines() {
    var data = '';
    return transform(
      StreamTransformer.fromHandlers(
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
      ),
    );
  }
}
