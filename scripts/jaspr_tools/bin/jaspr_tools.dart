import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  var runner = CommandRunner<int>("jaspr_tools", "Development tools for jaspr")
    ..addCommand(SetupCommand())
    ..addCommand(CleanCommand());

  try {
    var result = await runner.run(args);
    exit(result ?? 0);
  } on UsageException catch (e) {
    print(e.message);
    print('');
    print(e.usage);
  }
}

class SetupCommand extends Command<int> {
  SetupCommand();

  @override
  String get invocation {
    return "tools setup [arguments]";
  }

  @override
  String get description => 'Setup dependency_overrides for all projects';

  @override
  String get name => 'setup';

  @override
  Future<int> run() async {
    var pubspecYaml = File('pubspec.yaml');

    if (!pubspecYaml.existsSync()) {
      stdout.write('Cannot find pubspec.yaml file in current directory.');
      return 1;
    }

    var pubspecContent = await pubspecYaml.readAsString();
    var pubspecDoc = loadYamlDocument(pubspecContent).contents;
    var pubspecDeps = (pubspecDoc as Map)['dependencies'] as Map;
    var pubspecDevDeps = (pubspecDoc as Map)['dev_dependencies'] as Map;
    var pubspecDepsOvr = (pubspecDoc as Map)['dependency_overrides'] as YamlMap?;

    String? checkPackage(String package) {
      return pubspecDeps.containsKey(package) || pubspecDevDeps.containsKey(package) ? package : null;
    }

    var dependencies = [
      checkPackage('jaspr'),
      checkPackage('jaspr_test'),
      checkPackage('jaspr_riverpod'),
    ].whereType<String>();

    if (dependencies.isEmpty) {
      return 0;
    }

    String pubspecPre, pubspecPost;

    if (pubspecDepsOvr != null) {
      var splitIndex = pubspecDepsOvr.span.end.offset;
      while (pubspecContent[splitIndex - 1].trim().isEmpty) {
        splitIndex--;
      }

      pubspecPre = pubspecContent.substring(0, splitIndex);
      pubspecPost = pubspecContent.substring(splitIndex);
    } else {
      pubspecPre = pubspecContent.trimRight() + '\n\ndependency_overrides:';
      pubspecPost = '';
    }

    var packagesDir = path.relative(path.join(Platform.environment['MELOS_ROOT_PATH']!, 'packages'));

    for (var package in dependencies) {
      pubspecPre += '\n  $package: \n    path: $packagesDir/$package';
    }

    await pubspecYaml.writeAsString(pubspecPre + pubspecPost);

    return 0;
  }
}

class CleanCommand extends Command<int> {
  CleanCommand();

  @override
  String get invocation {
    return "tools clean [arguments]";
  }

  @override
  String get description => 'Cleanup dependency_overrides for all projects';

  @override
  String get name => 'clean';

  @override
  Future<int> run() async {
    var pubspecYaml = File('pubspec.yaml');

    if (!pubspecYaml.existsSync()) {
      stdout.write('Cannot find pubspec.yaml file in current directory.');
      return 1;
    }

    var pubspecContent = await pubspecYaml.readAsString();
    var pubspecDoc = loadYamlDocument(pubspecContent).contents;
    var pubspecDeps = (pubspecDoc as Map)['dependencies'] as Map;
    var pubspecDevDeps = (pubspecDoc as Map)['dev_dependencies'] as Map;
    var pubspecDepsOvr = (pubspecDoc as Map)['dependency_overrides'] as YamlMap?;

    if (pubspecDepsOvr == null) {
      stdout.write('No dependency_overrides set, nothing to do.');
      return 0;
    }

    String? checkPackage(String package) {
      return pubspecDepsOvr.containsKey(package) ? package : null;
    }

    var dependencies = [
      checkPackage('jaspr'),
      checkPackage('jaspr_test'),
      checkPackage('jaspr_riverpod'),
    ].whereType<String>();

    if (dependencies.isEmpty) {
      return 0;
    }

    var clearOverrides = dependencies.length == pubspecDepsOvr.nodes.length;
    print("CLEAR: $clearOverrides");

    var pubspecPre = pubspecContent.substring(0, pubspecDepsOvr.span.start.offset).trimRight();
    var pubspecPost = pubspecContent.substring(pubspecDepsOvr.span.end.offset);

    if (!clearOverrides) {
      for (var package in pubspecDepsOvr.keys) {
        if (dependencies.contains(package)) {
          continue;
        }
        var node = pubspecDepsOvr[package]!;
        pubspecPre += '\n  $package: ${(node is YamlNode) ? '\n    ' + node.span.text.trimRight() : node}';
      }
    } else {
      if (pubspecPre.endsWith('\ndependency_overrides:')) {
        pubspecPre = pubspecPre.substring(0, pubspecPre.length - '\ndependency_overrides:'.length);
      }
    }

    await pubspecYaml.writeAsString(pubspecPre + pubspecPost);

    return 0;
  }
}
