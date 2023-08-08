import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart' show ExitCode;
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

import '../config.dart';
import '../logging.dart';

abstract class BaseCommand extends Command<int> {
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
  Logger get logger => _logger ??= Logger(verbose);
  Logger? _logger;

  late final bool verbose = argResults?['verbose'] as bool? ?? false;

  final bool requiresPubspec = true;

  late YamlMap? pubspecYaml;
  late JasprConfig config;

  bool get usesJasprWebCompilers => switch (pubspecYaml) {
        {'dev_dependencies': {'jaspr_web_compilers': _}} => true,
        _ => false,
      };

  @override
  @mustCallSuper
  Future<int> run() async {
    pubspecYaml = await getPubspec();
    config = JasprConfig.fromYaml(pubspecYaml, logger);

    ProcessSignal.sigint.watch().listen((signal) {
      shutdown();
    });

    return ExitCode.success.code;
  }

  Future<Never> shutdown([int exitCode = 1]) async {
    await Future.wait([for (var g in guards) g()]);
    exit(exitCode);
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

  Future<YamlMap?> getPubspec() async {
    var pubspecPath = 'pubspec.yaml';
    var pubspecFile = File(pubspecPath);
    if (!(await pubspecFile.exists())) {
      if (requiresPubspec) {
        throw 'Could not find pubspec.yaml file. Make sure to run jaspr in your root project directory.';
      } else {
        return null;
      }
    }

    var parsed = loadYaml(await pubspecFile.readAsString());
    return parsed as YamlMap;
  }

  void guardResource(Future<void> Function() fn) {
    guards.add(fn);
  }

  Future<void> watchProcess(
    Process process, {
    required Tag tag,
    String? progress,
    bool Function(String)? hide,
    void Function()? onFail,
  }) async {
    if (progress != null) {
      logger.write(progress, tag: tag, progress: ProgressState.running);
    }

    process.stderr.listen((event) {
      logger.write(utf8.decode(event), tag: tag, level: Level.error, progress: ProgressState.completed);
    });

    process.stdout.map(utf8.decode).listen((log) {
      if (hide != null && hide.call(log)) return;

      if (progress != null) {
        logger.write(log, tag: tag, progress: ProgressState.running);
      } else {
        logger.write(log, tag: tag);
      }
    });

    var exitCode = await process.exitCode;
    if (exitCode == 0) {
      logger.complete(true);
    } else {
      logger.complete(false);
      onFail?.call();
      shutdown(exitCode);
    }
  }
}
