import 'dart:io';

import 'package:io/ansi.dart';
import 'package:mason/mason.dart' hide Level;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../bundles/new_component_bricks/new_async_component/new_async_component_bundle.dart';
import '../bundles/new_component_bricks/new_async_component_test/new_async_component_test_bundle.dart';
import '../bundles/new_component_bricks/new_component_test/new_component_test_bundle.dart';
import '../bundles/new_component_bricks/new_stateful_component/new_stateful_component_bundle.dart';
import '../bundles/new_component_bricks/new_stateless_component/new_stateless_component_bundle.dart';
import '../logging.dart';
import '../process_runner.dart';
import '../project.dart';
import 'base_command.dart';

Map<String, MasonBundle> compTypeToBundle = {
  'stateless': newStatelessComponentBundle,
  'stateful': newStatefulComponentBundle,
  'async': newAsyncComponentBundle,
};

Map<String, MasonBundle> compTypeToTestBundle = {
  'stateless': newComponentTestBundle,
  'stateful': newComponentTestBundle,
  'async': newAsyncComponentTestBundle,
};

class NewCommand extends BaseCommand {
  NewCommand({super.logger}) {
    addSubcommand(ComponentCommand(logger: logger));
  }

  @override
  String get invocation {
    return 'jaspr new <subcommand> [arguments]';
  }

  @override
  String get description => 'Create a new Jaspr component.';

  @override
  String get name => 'new';

  @override
  String get category => 'Project';

  @override
  Future<int> runCommand() async {
    // if no subcommand is provided, show usage
    usageException('Please specify a subcommand.');
  }
}

class ComponentCommand extends BaseCommand {
  ComponentCommand({super.logger}) {
    argParser.addOption(
      'path',
      abbr: 'p',
      help:
          'Location where the new component will be created (Defaults to ./lib/components)', // NOTE: the default path is set in getTargetDirectory
    );
    argParser.addFlag(
      'dry-run',
      help: 'Preview the proposed changes but make no changes',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addSeparator('Component flags: choose which type of component to create (Only use one of these 3 flags)');
    argParser.addFlag(
      'stateless',
      help: 'Create a new stateless component.',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addFlag(
      'stateful',
      help: 'Create a new stateful component.',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addFlag(
      'async',
      help: 'Create a new AsyncStatelessComponent.',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addSeparator('Additional options for the created component');
    argParser.addFlag(
      'client',
      help: 'Create a client component (Only for stateless or stateful components).',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addFlag(
      'with-styles',
      aliases: ['styled', 'with-style'],
      help: 'Add a style rules getter in the component (Only supported in server and static modes).',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addFlag(
      'with-test',
      help: 'Generate a test file for the component under test/ (uses the jaspr_test package).',
      negatable: false,
      defaultsTo: false,
    );
  }

  @override
  String get invocation {
    return 'jaspr new component [arguments] <name>';
  }

  @override
  String get description => 'Create a new Jaspr component.';

  @override
  String get name => 'component';

  late final bool isStateless = argResults!.flag('stateless');
  late final bool isStateful = argResults!.flag('stateful');
  late final bool isAsync = argResults!.flag('async');
  late final bool withStyles = argResults!.flag('with-styles');
  late final bool isClient = argResults!.flag('client');
  late final bool withTest = argResults!.flag('with-test');
  late final bool dryRun = argResults!.flag('dry-run');

  @override
  Future<int> runCommand() async {
    final (dir, name) = getTargetDirectory();

    // validate component flag combinations
    final componentFlagCount = [isStateless, isStateful, isAsync].where((f) => f).length;

    if (componentFlagCount > 1) {
      logger.write(
        'Cannot use multiple component type flags together. Please specify only one of: --stateless, --stateful, or --async.',
        tag: Tag.cli,
        level: Level.error,
      );
      return 1;
    }

    // Default to stateless if no flag is specified
    final useStateless = isStateless || (!isStateful && !isAsync);

    // don't create a client component if the component is an AsyncStatelessComponent
    // final useClient = isAsync && isClient ? false : isClient;
    var useClient = isClient;
    if (isAsync && isClient) {
      logger.write(
        'Cannot create a client AsyncStatelessComponent. Creating a server-side component instead.',
        level: Level.warning,
      );

      useClient = false;
    }

    return await createFromTemplate(
      dir,
      name,
      useStateless,
      isStateful,
      isAsync,
      withStyles,
      useClient,
      withTest,
    );
  }

  // Generate the component with the mason template
  Future<int> createFromTemplate(
    Directory dir,
    String name,
    bool isStateless,
    bool isStateful,
    bool isAsync,
    bool withStyles,
    bool isClient,
    bool withTest,
  ) async {
    final componentType = isAsync ? 'async' : (isStateless ? 'stateless' : 'stateful');

    if (dryRun) {
      logger.logger!.write(
        'Would generate ${isClient ? "client" : "server"} $componentType component ${yellow.wrap(name.pascalCase)}${withStyles ? " with styles" : ""} at dir ${blue.wrap(dir.path)}\n',
      );
      if (withTest) {
        logger.logger!.write(
          'Would generate test for ${blue.wrap(name.pascalCase)}\n',
        );
      }
      return 0;
    }

    final progress = logger.logger!.progress(
      'Generating $componentType component "$name"...',
    );

    // select the right bundle based on the required component type
    // e.g., stateful components will use the "new_stateful_component" bundle
    final generator = await MasonGenerator.fromBundle(compTypeToBundle[componentType]!);
    final files = await generator.generate(
      DirectoryGeneratorTarget(dir),
      vars: {
        'name': name,
        'stateless': isStateless,
        'stateful': isStateful,
        'async': isAsync,
        'styles': withStyles,
        'client': isClient,
      },
      logger: logger.logger,
    );

    // format the generated component
    Process.runSync('dart', ['format', files.first.path, '--line-length=120']);

    progress.complete('Generated $componentType component $name: ${blue.wrap(files.first.path)}');

    if (withTest) {
      return await createTestFromTemplate(files.first.path, name);
    }

    return 0;
  }

  // Generate a test for the newly created component under the /test dir
  Future<int> createTestFromTemplate(String componentPath, String name) async {
    final progress = logger.logger!.progress('Generating test for "$name"...');

    final componentFile = File(componentPath).absolute;
    final componentType = isAsync ? 'async' : (isStateless ? 'stateless' : 'stateful');

    // try to find the root of the project (where pubspec.yaml is), if it is the cwd then the command
    // was ran at the project root, otherwise it might have been ran elsewhere (e.g. "lib/components")
    final projectRoot = findProjectRoot(componentFile.parent) ?? Directory.current.absolute;

    // get the lib and test directories from the project root
    final libDir = Directory(p.join(projectRoot.path, 'lib'));
    var testPath = p.join(projectRoot.path, 'test');

    // since we are at the project root, we can also read the pubspec yaml file
    final packageName = readPubspec(projectRoot)?['name'] as String?;

    String import;

    // import the component with the package name (e.g., for a "ContactInfo" component located in "lib/components" it will be imported as "package:xyz/components/contact_info.dart")
    if (p.isWithin(libDir.path, componentFile.path) && packageName != null) {
      // since the component is in the lib dir somewhere, find the path relative to it
      final relativePath = p.relative(componentFile.path, from: libDir.path).replaceAll(r'\', '/');
      // discard the file name to get the relative path from lib (e.g., relative_path = /components/contact_info.dart -> relative_dir = /components)
      final relativeDir = p.dirname(relativePath);

      // for components in /lib, just put them in the /test dir as is, otherwise we put them in the same dir structure
      // e.g., /lib/components/contact_info.dart -> /test/components/contact_info_test.dart
      if (relativeDir != '.') {
        testPath = p.join(projectRoot.path, 'test', relativeDir);
      }

      import = 'package:$packageName/$relativePath';
    } else {
      // fallback: the component is outside of lib/ or the pubspec has no name, use an import
      // relative to the test dir
      import = p.split(p.relative(componentFile.path, from: testPath)).join('/');
    }

    final testDir = Directory(testPath).absolute;
    if (!testDir.existsSync()) {
      testDir.createSync(recursive: true);
    }


    final generator = await MasonGenerator.fromBundle(compTypeToTestBundle[componentType]!);
    final files = await generator.generate(
      DirectoryGeneratorTarget(testDir),
      vars: {
        'name': name,
        'import': import,
      },
      logger: logger.logger,
    );

    Process.runSync('dart', ['format', files.first.path, '--line-length=120']);

    progress.complete('Generated test for $name: ${blue.wrap(files.first.path)}');

    // if jaspr_test is not in the dev dependencies, prompt the user to add it
    ensureJasprTestDependency(projectRoot);

    return 0;
  }

  // if jaspr_test is not in the dev dependencies, prompt the user to add it
  void ensureJasprTestDependency(Directory projectRoot) {
    // check if the pubspec.yaml of the target project already contains the jaspr_test dep, if so return early
    final pubspecMap = readPubspec(projectRoot);
    if (pubspecMap != null && pubspecMap.containsKey('dev_dependencies')) {
      final devDeps = pubspecMap.nodes['dev_dependencies'];
      if (devDeps is YamlMap && devDeps.containsKey('jaspr_test')) {
        return;
      }
    }

    final log = logger.logger;
    if (log == null) {
      logger.write(
        "Cannot automatically add jaspr_test to pubspec.yaml, run ${yellow.wrap("dart pub add jaspr_test --dev")}",
        tag: Tag.cli,
        level: Level.warning,
      );
      return;
    }

    final result = logger.logger!.confirm(
      'The jaspr_test package is required to run the test, do you want to add jaspr_test to your dev_dependencies?',
      defaultValue: true,
    );

    if (!result) {
      logger.write(
        'Skipped adding jaspr_test. Run ${yellow.wrap("dart pub add jaspr_test --dev")} to be able to run the test',
        tag: Tag.cli,
        level: Level.warning,
      );
      return;
    }

    final pubCommand = ProcessRunner.instance.runSync(
      dartExecutable,
      ['pub', 'add', 'jaspr_test', '--dev'],
      workingDirectory: projectRoot.path,
    );
    if (pubCommand.exitCode != 0) {
      log.err(pubCommand.stderr as String?);
      logger.write(
        'Failed to run ${yellow.wrap("dart pub add jaspr_test --dev")}. There is probably more output above.',
        tag: Tag.cli,
        level: Level.error,
      );
      return;
    }

    log.success('Successfully added jaspr_test to your dev_dependencies.');
  }

  // Walk up from the start directory until we find the project root (i.e., when we find a pubspec.yaml file)
  // this means that in a monorepo (e.g., jaspr repo), this walk will stop at the current package's root
  Directory? findProjectRoot(Directory start) {
    var dir = start.absolute;
    while (true) {
      // stop as soon as you find a pubspec.yaml file
      if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
        return dir;
      }

      // otherwise try again in the parent directory
      final parent = dir.parent;
      if (parent.path == dir.path) {
        // reached the filesystem root without finding a pubspec.yaml
        return null;
      }
      dir = parent;
    }
  }

  // read the pubspec yaml file from a given directory, returns null if it doesn't exist
  YamlMap? readPubspec(Directory root) {
    final pubspecFile = File(p.join(root.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      return null;
    }
    final yaml = loadYaml(pubspecFile.readAsStringSync());
    return yaml is YamlMap ? yaml : null;
  }

  // figures out the component name and destination directory
  (Directory, String) getTargetDirectory() {
    if (argResults!.rest.length > 1) {
      usageException('Too many positional arguments were provided, please only provide the component name');
    }

    // componentName is the name for the component, it can be written in PascalCase, camelCase, or snake_cake because
    // the mason template transforms the name into snake_case for the filename and in PascalCase for the class name
    final componentName = argResults!.rest.firstOrNull ?? logger.logger!.prompt('Specify a component name:').trim();

    if (componentName.isEmpty) {
      usageException('"$componentName" is not a valid component name.');
    } else if (!componentName.pascalCase.contains(RegExp(r'^[a-zA-Z_$][a-zA-Z0-9_$]*$'))) {
      // check that the name is a valid dart identifier:
      //   - starts either with a letter or _ or $
      //   - the rest can be composed of letters, digits, _ or $
      //   - as a single word
      usageException('"${componentName.pascalCase}" is not a valid dart identifier.');
    }

    final pathOption = argResults!.option('path');
    Directory directory;
    if (pathOption == null) {
      // no path given, so we create the component in lib/components

      // try to find the root of the project (where pubspec.yaml is), if it is the cwd then the command
      // was ran at the project root, otherwise it might have been ran elsewhere (e.g. "lib/components")
      final projectRoot = findProjectRoot(Directory.current.absolute) ?? Directory.current.absolute;

      directory = Directory(p.join(projectRoot.path, 'lib/components'));
    } else {
      // if the user passed a directory, then we use that
      directory = Directory(pathOption).absolute;
    }

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return (directory, componentName);
  }
}
