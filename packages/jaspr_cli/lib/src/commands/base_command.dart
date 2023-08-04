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

  bool get verbose => argResults?['verbose'] as bool? ?? false;

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
    config = getConfig();

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

  JasprConfig getConfig() {
    if (pubspecYaml case {'jaspr': var configYaml}) {
      try {
        if (configYaml is! YamlMap) {
          throw "'jaspr' must be a map.";
        }

        JasprSSRConfig? ssr;
        if (configYaml['ssr'] case var ssrYaml) {
          if (ssrYaml is! bool && ssrYaml is! Map) throw "'jaspr.ssr' must be a boolean or map.";

          if (ssrYaml is bool) {
            ssr = JasprSSRConfig(enabled: ssrYaml);
          } else {
            var enabled = ssrYaml['enabled'];
            if (enabled == null) {
              ssr = JasprSSRConfig(enabled: true);
            } else {
              if (enabled is! bool) throw "'jaspr.ssr.enabled' must be a boolean.";
              ssr = JasprSSRConfig(enabled: enabled);
            }
          }
        }

        bool? usesFlutter;
        if (configYaml['uses-flutter'] case var flutterYaml) {
          if (flutterYaml != null) {
            if (flutterYaml is! bool) throw "'jaspr.uses-flutter' must be a boolean.";

            usesFlutter = flutterYaml;
          } else {
            usesFlutter = false;
          }
        }

        return JasprConfig(ssr: ssr, usesFlutter: usesFlutter);
      } catch (e) {
        logger.write('Invalid jaspr configuration in pubspec.yaml: $e', level: Level.critical);
      }
    }

    return JasprConfig();
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
