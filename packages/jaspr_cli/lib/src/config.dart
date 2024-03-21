import 'dart:io';

import 'package:yaml/yaml.dart';

import 'logging.dart';

enum JasprMode { static, server, client }

class JasprConfig {
  const JasprConfig({
    required this.pubspecYaml,
    required this.mode,
    this.usesFlutter = false,
    this.usesJasprWebCompilers = false,
    this.devCommand,
  });

  final YamlMap pubspecYaml;
  final JasprMode mode;

  final bool usesFlutter;
  final bool usesJasprWebCompilers;
  final String? devCommand;

  String? get projectName => pubspecYaml['name'];
}

Future<JasprConfig> getConfig(Logger logger) async {
  var pubspecPath = 'pubspec.yaml';
  var pubspecFile = File(pubspecPath).absolute;
  if (!(await pubspecFile.exists())) {
    throw 'Could not find pubspec.yaml file. Make sure to run jaspr in your root project directory.';
  }

  var pubspecYaml = loadYaml(await pubspecFile.readAsString()) as YamlMap;

  if (pubspecYaml case {'dependencies': {'jaspr': _}}) {
    // ok
  } else {
    throw 'Missing dependency on jaspr in pubspec.yaml file. Make sure to add jaspr to your dependencies.';
  }

  if (pubspecYaml case {'dev_dependencies': {'jaspr_builder': _}}) {
    // ok
  } else {
    var result = logger.logger.confirm(
        'Missing dependency on jaspr_builder package. Do you want to add jaspr_builder to your dev_dependencies now?',
        defaultValue: true);
    if (result) {
      var result = Process.runSync('dart', ['pub', 'add', '--dev', 'jaspr_builder']);
      if (result.exitCode != 0) {
        logger.logger.err(result.stderr);
        throw 'Failed to run "dart pub add --dev jaspr_builder". There is probably more output above.';
      }

      logger.logger.success('Successfully added jaspr_builder to your dev_dependencies.');
    }
  }

  var usesJasprWebCompilers = switch (pubspecYaml) {
    {'dev_dependencies': {'jaspr_web_compilers': _}} => true,
    _ => false,
  };

  var usesFlutter = switch (pubspecYaml) {
    {'dependencies': {'flutter': _}} => true,
    _ => false,
  };

  var configYaml = pubspecYaml['jaspr'];
  JasprMode mode;
  String? devCommand;

  try {
    if (configYaml == null) {
      throw "Missing 'jaspr' options.";
    }
    if (configYaml is! YamlMap) {
      throw "'jaspr' options must be a yaml map.";
    }

    var modeYaml = configYaml['mode'];
    if (modeYaml == null) {
      throw "'jaspr.mode' option is required but missing.";
    }
    var modeOrNull = JasprMode.values.where((v) => v.name == modeYaml).firstOrNull;
    if (modeOrNull == null) {
      throw "'jaspr.mode' must be one of ${JasprMode.values.map((v) => v.name).join(', ')}.";
    }
    mode = modeOrNull;

    var devCommandYaml = configYaml['dev-command'];
    if (devCommandYaml != null) {
      if (devCommandYaml is! String) throw "'jaspr.dev-command' must be a string.";

      devCommand = devCommandYaml;
    }
  } catch (e) {
    throw 'Invalid jaspr configuration in pubspec.yaml: $e';
  }

  return JasprConfig(
    pubspecYaml: pubspecYaml,
    mode: mode,
    usesFlutter: usesFlutter,
    usesJasprWebCompilers: usesJasprWebCompilers,
    devCommand: devCommand,
  );
}
