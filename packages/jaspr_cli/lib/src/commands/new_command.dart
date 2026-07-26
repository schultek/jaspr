import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:mason/mason.dart' hide Level;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../bundles/new_component_bricks/new_async_component/new_async_component_bundle.dart';
import '../bundles/new_component_bricks/new_async_component_test/new_async_component_test_bundle.dart';
import '../bundles/new_component_bricks/new_component_test/new_component_test_bundle.dart';
import '../bundles/new_component_bricks/new_flutter_embedded_view/new_flutter_embedded_view_bundle.dart';
import '../bundles/new_component_bricks/new_sample_flutter_widget/new_sample_flutter_widget_bundle.dart';
import '../bundles/new_component_bricks/new_stateful_component/new_stateful_component_bundle.dart';
import '../bundles/new_component_bricks/new_stateless_component/new_stateless_component_bundle.dart';
import '../logging.dart';
import '../migrations/migration_models.dart' show EditBuilder;
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
      aliases: ['dry'],
      help: 'Preview the proposed changes but make no changes',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addSeparator('Component flags: choose which type of component to create (Only use one of these 4 flags)');
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
    argParser.addFlag(
      'flutter',
      help: 'Create a new FlutterEmbedView component.',
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
    argParser.addSeparator('Additional arguments used when creating a Flutter embedded view');
    argParser.addOption(
      'flutter-app-name',
      aliases: ['app-name', 'flutter-name', 'flutter-widget-name'],
      help: 'Provide the name of the Flutter App/Widget to embed (Used only when creating a FlutterEmbeddedView)',
      valueHelp: 'MyFlutterApp',
    );
    argParser.addFlag(
      'with-sample-flutter-widget',
      aliases: [
        'with-flutter-widget',
        'with-sample-flutter-app',
        'with-flutter-app',
        'sample-flutter-app',
        'sample-flutter-widget',
      ],
      help: 'Generate a sample flutter widget.',
      negatable: true,
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
  late final bool isFlutter = argResults!.flag('flutter');
  late final bool withStyles = argResults!.flag('with-styles');
  late final bool isClient = argResults!.flag('client');
  late final bool withTest = argResults!.flag('with-test');
  late final bool dryRun = argResults!.flag('dry-run');
  late String flutterAppName = argResults!.option('flutter-app-name') ?? '';
  late bool? withSampleFlutterWidget = argResults!.flag('with-sample-flutter-widget');

  @override
  Future<int> runCommand() async {
    final (dir, name) = getTargetDirectory();

    // validate component flag combinations
    final componentFlagCount = [isStateless, isStateful, isAsync, isFlutter].where((f) => f).length;

    if (componentFlagCount > 1) {
      logger.write(
        'Cannot use multiple component type flags together. Please specify only one of: --stateless, --stateful, --async, or --flutter.',
        tag: Tag.cli,
        level: Level.error,
      );
      return 1;
    }

    if (isFlutter) {
      return createFlutterViewComponent(dir, name);
    }

    // Default to stateless if no flag is specified
    final useStateless = isStateless || (!isStateful && !isAsync && !isFlutter);

    // don't create a client component if the component is an AsyncStatelessComponent
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

  /// Walk up from the start directory until we find the project root (i.e., when we find a pubspec.yaml file)
  /// this means that in a monorepo (e.g., jaspr repo), this walk will stop at the current package's root
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
  // Note that this doesn't use project.pubspecYaml or pubspecFile because this command could conceivebly be used in another dir
  // than the root, so it makes sense to walk up to the root of the project and use the file we find there.
  YamlMap? readPubspec(Directory root) {
    final file = File(p.join(root.path, 'pubspec.yaml'));
    if (!file.existsSync()) {
      return null;
    }

    try {
      final yaml = loadYaml(file.readAsStringSync());
      return yaml is YamlMap ? yaml : null;
    } catch (_) {
      return null;
    }
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

  /// Generate the component with the mason template
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
      logger.write(
        'Would generate ${isClient ? "client" : "server"} $componentType component ${yellow.wrap(name.pascalCase)}${withStyles ? " with styles" : ""} at dir ${blue.wrap(dir.path)}\n',
        tag: Tag.cli,
        level: Level.info,
      );
      if (withTest) {
        logger.write(
          'Would generate test for ${blue.wrap(name.pascalCase)}\n',
          tag: Tag.cli,
          level: Level.info,
        );
      }
      return 0;
    }

    logger.write(
      'Generating $componentType component "$name"...',
      tag: Tag.cli,
      level: Level.info,
      progress: ProgressState.running,
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

    final projectRoot = findProjectRoot(dir) ?? Directory.current.absolute;

    logger.write(
      'Generated $componentType component $name: ${blue.wrap(p.relative(files.first.path, from: projectRoot.path))}',
      tag: Tag.cli,
      level: Level.info,
      progress: ProgressState.completed,
    );

    if (withTest) {
      return await createTestFromTemplate(files.first.path, name);
    }

    return 0;
  }

  /// Generate a test for the newly created component under the /test dir
  Future<int> createTestFromTemplate(String componentPath, String name) async {
    logger.write(
      'Generating test for "$name"...',
      progress: ProgressState.running,
      tag: Tag.cli,
      level: Level.info,
    );

    final componentFile = File(componentPath).absolute;
    final componentType = isAsync ? 'async' : (isStateless ? 'stateless' : 'stateful');

    // try to find the root of the project (where pubspec.yaml is), if it is the cwd then the command
    // was ran at the project root, otherwise it might have been ran elsewhere (e.g. "lib/components")
    final projectRoot = findProjectRoot(componentFile.parent) ?? Directory.current.absolute;

    // get the lib and test directories from the project root
    final libDir = Directory(p.join(projectRoot.path, 'lib'));
    var testPath = p.join(projectRoot.path, 'test');

    // since we are at the project root, we can also read the pubspec yaml file
    final pubspec = readPubspec(projectRoot);
    final nameNode = pubspec?['name'];
    final packageName = nameNode is String ? nameNode : null;

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

    logger.write(
      'Generated test for $name: ${blue.wrap(p.relative(files.first.path, from: projectRoot.path))}',
      tag: Tag.cli,
      level: Level.info,
      progress: ProgressState.completed,
    );

    // if jaspr_test is not in the dev dependencies, prompt the user to add it
    conditionallyInstalDeps(projectRoot, ['jaspr_test'], isDevDependency: true);

    return 0;
  }

  /// for a given list of packages, check if they are already installed, if not then prompt the user to install them
  void conditionallyInstalDeps(Directory projectRoot, List<String> packages, {bool isDevDependency = false}) {
    // check if the pubspec.yaml of the target project already contains the jaspr_test dep, if so return early

    final pubspecMap = readPubspec(projectRoot);
    if (pubspecMap == null) {
      logger.write(
        'Failed to find pubspec.yaml file in dir ${blue.wrap(projectRoot.path)}',
        tag: Tag.cli,
        level: Level.error,
      );
      return;
    }

    for (String packageName in packages) {
      final String depString = isDevDependency ? 'dev_dependencies' : 'dependencies';
      final String pubAddArg = isDevDependency ? '--dev' : '';

      // exit quietly if the package is already installed
      if (pubspecMap.containsKey(depString)) {
        final deps = pubspecMap.nodes[depString];
        if (deps is YamlMap && deps.containsKey(packageName)) {
          continue;
        }
      }

      final log = logger.logger;
      if (log == null) {
        logger.write(
          "Cannot automatically add $packageName to pubspec.yaml, run ${yellow.wrap("dart pub add $packageName $pubAddArg")}",
          tag: Tag.cli,
          level: Level.warning,
        );
        continue;
      }

      final result = logger.logger!.confirm(
        'The ${cyan.wrap(packageName)} package is required. Do you want to add $packageName to your $depString?',
        defaultValue: true,
      );

      if (!result) {
        logger.write(
          'Skipped adding $packageName. Run ${yellow.wrap("dart pub add $packageName $pubAddArg")}',
          tag: Tag.cli,
          level: Level.warning,
        );
        continue;
      }

      // if we are adding the flutter dependency, we need to specify that we want to use flutter from the currently installed sdk
      if (packageName == 'flutter' || packageName == 'flutter_test') {
        packageName = '$packageName@{sdk: flutter}';
      }

      final pubCommand = ProcessRunner.instance.runSync(
        dartExecutable,
        ['pub', 'add', '${isDevDependency ? "dev:" : ""}$packageName'],
        workingDirectory: projectRoot.path,
      );
      if (pubCommand.exitCode != 0) {
        log.err(pubCommand.stderr as String?);
        logger.write(
          'Failed to run ${yellow.wrap("dart pub add $packageName $pubAddArg")}. There is probably more output above.',
          tag: Tag.cli,
          level: Level.error,
        );
        continue;
      }

      logger.write(
        'Successfully added ${green.wrap(packageName)} to your $depString.',
        tag: Tag.cli,
        level: Level.info,
      );
    }

    return;
  }

  /// Create and setup the project to add a FlutterEmbeddedView component
  Future<int> createFlutterViewComponent(Directory dir, String name) async {
    // if no flutter app name was provided, prompt for one
    if (flutterAppName.isEmpty) {
      flutterAppName = logger.logger!
          .prompt(
            'Specify the Flutter App/Widget name (i.e., name of the Flutter App/Widget you wish to embed):',
            defaultValue: 'MyFlutterApp',
          )
          .trim()
          .pascalCase;

      logger.write(
        'Will create Jaspr component to embed ${yellow.wrap(flutterAppName)}.',
        tag: Tag.cli,
        level: Level.info,
      );
    }

    // ask the user whether to generate a sample flutter app or not
    withSampleFlutterWidget ??= logger.logger!.confirm(
      'Do you wish to generate a sample Flutter widget with name $flutterAppName?',
      defaultValue: true,
    );

    if (withTest) {
      logger.write(
        '--with-test argument ignored for FlutterEmbeddedView components',
        tag: Tag.cli,
        level: Level.warning,
      );
    }

    final projectRoot = findProjectRoot(Directory.current.absolute) ?? Directory.current.absolute;

    if (dryRun) {
      dryRunFlutterViewComponent(dir, name, projectRoot);
      return 0;
    }

    // add flutter and jaspr_flutter_embed in dependenies if they aren't present (prompts to add them)
    conditionallyInstalDeps(projectRoot, ['flutter', 'jaspr_flutter_embed'], isDevDependency: false);
    // also install other useful deps
    conditionallyInstalDeps(projectRoot, ['flutter_lints', 'flutter_test'], isDevDependency: true);

    setFlutterMode(projectRoot);

    setUseMaterialDesignPubspec(projectRoot);

    createFlutterBootstrapScript(projectRoot);

    final mode = readMode(readPubspec(projectRoot));
    if (mode == null) {
      warnManualIncludeRef();
    } else if (mode.isServerOrStatic) {
      includeBootstrapRefInDoc(projectRoot);
    } else {
      includeInIndexHtml(projectRoot);
    }

    await generateFlutterEmbeddedViewComponent(dir, name, projectRoot);

    return 0;
  }

  /// preview the changes that createFlutterViewComponent would make, without modifying any file
  void dryRunFlutterViewComponent(Directory dir, String name, Directory projectRoot) {
    final pubspecMap = readPubspec(projectRoot);

    void wouldDo(String message) {
      logger.write(message, tag: Tag.cli, level: Level.info);
    }

    /// check if the pubspec file contains the packageName as a dep
    bool hasDep(String packageName, {bool isDevDependency = false}) {
      final deps = pubspecMap?.nodes[isDevDependency ? 'dev_dependencies' : 'dependencies'];
      return deps is YamlMap && deps.containsKey(packageName);
    }

    // dependency install check
    final missingDeps = ['flutter', 'jaspr_flutter_embed'].where((d) => !hasDep(d));
    final missingDevDeps = ['flutter_lints', 'flutter_test'].where((d) => !hasDep(d, isDevDependency: true));
    if (missingDeps.isNotEmpty) {
      wouldDo('Would prompt to add ${missingDeps.map((d) => cyan.wrap(d)).join(', ')} to dependencies');
    }
    if (missingDevDeps.isNotEmpty) {
      wouldDo('Would prompt to add ${missingDevDeps.map((d) => cyan.wrap(d)).join(', ')} to dev_dependencies');
    }

    // jaspr flutter mode change
    if (project.flutterMode != FlutterMode.embedded) {
      if (project.flutterMode == FlutterMode.plugins) {
        wouldDo(
          'Would prompt to overwrite the jaspr.flutter mode with ${yellow.wrap('embedded')} in pubspec.yaml',
        );
      } else {
        wouldDo('Would set ${yellow.wrap('flutter: embedded')} in the jaspr block of pubspec.yaml');
      }
    }

    // uses-material-design change
    final flutterNode = pubspecMap?.nodes['flutter'];
    final hasUsesMaterialDesign = flutterNode is YamlMap && flutterNode.containsKey('uses-material-design');
    if (!hasUsesMaterialDesign) {
      wouldDo('Would set ${yellow.wrap('uses-material-design: true')} in the flutter block of pubspec.yaml');
    }

    // creation of bootstrap script
    if (!File(p.join(projectRoot.path, 'web', 'flutter_bootstrap.js')).existsSync()) {
      wouldDo('Would create ${blue.wrap('web/flutter_bootstrap.js')}');
    }

    // inclusion of bootstrap script in Document
    final mode = readMode(pubspecMap);
    if (mode == null) {
      wouldDo('Could not read the jaspr mode, the flutter_bootstrap.js script ref would need to be included manually');
    } else if (mode.isServerOrStatic) {
      wouldDo(
        'Would include a flutter_bootstrap.js script ref in the head of the Document in ${blue.wrap('lib/main.server.dart')}',
      );
    } else {
      wouldDo('Would include a flutter_bootstrap.js script tag in the head of ${blue.wrap('web/index.html')}');
    }

    // generation of component and sample widget
    wouldDo(
      'Would generate FlutterEmbeddedView component ${yellow.wrap(name.pascalCase)} embedding $flutterAppName at dir ${blue.wrap(dir.path)}',
    );
    if (withSampleFlutterWidget == true) {
      wouldDo('Would generate sample Flutter widget ${yellow.wrap(flutterAppName)} in ${blue.wrap('lib/widgets/')}');
    }
  }

  /// Sets the flutter mode to embedded in the pubspec.yaml file for the project
  /// if the project has jaspr.flutter set to 'plugins', we ask the user if they want to change it to embedded or not
  void setFlutterMode(Directory projectRoot) {
    if (project.flutterMode != FlutterMode.embedded) {
      // NOTE: we re-read the pubspec file after the potential installation of packages
      final pubspecMap = readPubspec(projectRoot);
      if (pubspecMap != null) {
        logger.write(
          'Enabling Flutter embedding support in pubspec.yaml.',
          tag: Tag.cli,
          level: Level.info,
        );

        try {
          final pubspecContent = project.pubspecFile.readAsStringSync();
          final builder = EditBuilder(LineInfo.fromContent(pubspecContent));

          if (pubspecMap.nodes['jaspr'] case final YamlMap jasprMap) {
            // if there is already a flutter mode, then it presumably is set to "plugins", so we ask the user to confirm that they want to change it
            if (jasprMap.nodes['flutter'] case final YamlScalar flutterNode when flutterNode.value != null) {
              final bool overwritePlugins = logger.logger!.confirm(
                'This project is set with jaspr.flutter mode set to plugins. Do you want to overwrite it to "embedded" to allow Flutter embedding?',
                defaultValue: false,
              );
              if (overwritePlugins) {
                builder.replace(flutterNode.span.start.offset, flutterNode.span.length, 'embedded');
              }
            } else {
              // there was presumably no flutter mode set in the jaspr block, so we add it.
              // we need an offset to be able to add this new line with the flutter mode, and we know that there will
              // always be a mode key for the rendering mode in the jaspr map, so we can just insert the new line below that

              if (jasprMap.nodes['mode'] case final YamlScalar jasprModeNode when jasprModeNode.value != null) {
                builder.insert(jasprModeNode.span.end.offset, '\n  flutter: embedded');
              }
            }
          }

          project.pubspecFile.writeAsStringSync(builder.apply(pubspecContent));
        } catch (e) {
          logger.write(
            'Failed to update pubspec.yaml: $e',
            level: Level.error,
            tag: Tag.cli,
          );
        }
      } else {
        logger.write(
          'Could not find pubspec.yaml file, please run this command in the root directory of your project.',
          tag: Tag.cli,
          level: Level.error,
        );
        exit(1);
      }
    }
  }

  /// ensure that "uses-material-design: true" is set in the flutter block of pubspec.yaml
  /// it allows the embedded Flutter app to use Material icons and fonts
  void setUseMaterialDesignPubspec(Directory projectRoot) {
    final pubspecMap = readPubspec(projectRoot);
    if (pubspecMap == null) {
      logger.write(
        'Failed to find pubspec.yaml file in dir ${blue.wrap(projectRoot.path)}',
        tag: Tag.cli,
        level: Level.error,
      );
      return;
    }

    final pubspecFile = File(p.join(projectRoot.path, 'pubspec.yaml'));

    try {
      final pubspecContent = pubspecFile.readAsStringSync();
      final builder = EditBuilder(LineInfo.fromContent(pubspecContent));

      final flutterNode = pubspecMap.nodes['flutter'];

      if (flutterNode is YamlMap) {
        if (flutterNode.nodes['uses-material-design'] case final YamlScalar _) {
          // if the key is present, it might be true or false, if false we don't want to overwrite it
          return;
        } else {
          // the flutter block is present but doesn't have the uses-material-design key, so we add it as the first entry
          // reusing the indentation of the existing entries
          final indent = ''.padLeft(flutterNode.span.start.column);
          builder.insert(flutterNode.span.start.offset, 'uses-material-design: true\n$indent');
        }
      } else if (flutterNode == null) {
        // there is no flutter block, append one at the end of the file
        final trailingNewline = pubspecContent.endsWith('\n') ? '' : '\n';
        builder.insert(pubspecContent.length, '$trailingNewline\nflutter:\n  uses-material-design: true\n');
      } else {
        logger.write(
          'Could not set uses-material-design in pubspec.yaml, please add it manually in the flutter block.',
          tag: Tag.cli,
          level: Level.warning,
        );
        return;
      }

      logger.write(
        'Enabled uses-material-design in pubspec.yaml.',
        tag: Tag.cli,
        level: Level.info,
      );

      pubspecFile.writeAsStringSync(builder.apply(pubspecContent));
    } catch (e) {
      logger.write(
        'Failed to update pubspec.yaml: $e',
        level: Level.error,
        tag: Tag.cli,
      );
    }
  }

  /// Create the flutter bootstrap script in the web dir
  void createFlutterBootstrapScript(Directory projectRoot) {
    // creating the flutter_bootstrap.js file, this doesn't modify an existing file
    final bootstrapFile = File(p.join(projectRoot.path, 'web', 'flutter_bootstrap.js'));
    try {
      if (!bootstrapFile.existsSync()) {
        bootstrapFile
          ..createSync(recursive: true)
          ..writeAsStringSync('{{flutter_js}}\n{{flutter_build_config}}\n');

        logger.write(
          'Created ${blue.wrap(p.relative(bootstrapFile.path, from: projectRoot.path))}.',
          tag: Tag.cli,
          level: Level.info,
        );
      } else {
        logger.write('web/flutter_bootstrap.js already exists, leaving unchanged', level: Level.info, tag: Tag.cli);
      }
    } catch (e) {
      logger.write('Failed to open or create web/flutter_bootstrap.js: $e', level: Level.error, tag: Tag.cli);
    }
  }

  /// generate the FlutterEmbeddedView component at dirrectory dir and with a specified name
  /// also generates a sample flutter widget depending on the withSampleFlutterWidget command flag
  Future<void> generateFlutterEmbeddedViewComponent(Directory dir, String name, Directory projectRoot) async {
    logger.write('Generating FlutterEmbeddedView component "$name"...', progress: ProgressState.running);
    final generator = await MasonGenerator.fromBundle(newFlutterEmbeddedViewBundle);
    final files = await generator.generate(
      DirectoryGeneratorTarget(dir),
      vars: {
        'name': name,
        'static_or_server': project.requireMode.isServerOrStatic,
        'flutterAppName': flutterAppName,
      },
      logger: logger.logger,
    );

    Process.runSync('dart', ['format', files.first.path, '--line-length=120']);
    logger.write(
      'Generated FlutterEmbeddedView component $name: ${blue.wrap(p.relative(files.first.path, from: projectRoot.path))}',
      progress: ProgressState.completed,
    );

    if (withSampleFlutterWidget != null && withSampleFlutterWidget!) {
      // if required, create the sample widget in the widgets dir
      final sampleWidgetDir = Directory(p.join(projectRoot.path, 'lib/widgets/'));

      if (!sampleWidgetDir.existsSync()) {
        sampleWidgetDir.createSync(recursive: true);
      }

      logger.write('Generating sample Flutter widget "$flutterAppName"...', progress: ProgressState.running);

      final generator = await MasonGenerator.fromBundle(newSampleFlutterWidgetBundle);
      final files = await generator.generate(
        DirectoryGeneratorTarget(sampleWidgetDir),
        vars: {
          'flutterAppName': flutterAppName,
        },
        logger: logger.logger,
      );
      Process.runSync('dart', ['format', files.first.path, '--line-length=120']);
      logger.write(
        'Generated sample Flutter widget $flutterAppName: ${blue.wrap(p.relative(files.first.path, from: projectRoot.path))}',
        progress: ProgressState.completed,
      );
    }
  }

  /// read the current jaspr mode in the provided pubspec yaml file
  JasprMode? readMode(YamlMap? pubspec) {
    if (pubspec?['jaspr'] case final YamlMap jaspr) {
      if (jaspr['mode'] case final String mode) {
        return JasprMode.values.where((v) => v.name == mode).firstOrNull;
      }
    }
    return null;
  }

  /// include a ref to the bootstrap script in the main document, used when jaspr.mode is either server or static
  void includeBootstrapRefInDoc(Directory projectRoot) {
    final File? serverEntrypoint = getServerEntrypoint(projectRoot);
    if (serverEntrypoint == null) {
      logger.write(
        "Either couldn't find main.server.dart, or couldn't find a Document constructor in main.server.dart. You will need to add the following in the head of your Document: ${cyan.wrap('script(src: "flutter_bootstrap.js", async: true)')}",
        level: Level.warning,
        tag: Tag.cli,
      );
    } else {
      // the server entrypoint contains a document, so we'll insert the script ref in the head
      final String scriptTag = 'script(src: "flutter_bootstrap.js", async: true),';

      final content = serverEntrypoint.readAsStringSync();
      final result = parseString(
        content: content,
        featureSet: FeatureSet.latestLanguageVersion(flags: ['dot-shorthands']),
      );
      final builder = EditBuilder(result.lineInfo);

      MethodInvocation? document;
      result.unit.visitChildren(DocumentVisitor((node) => document ??= node));

      // we didn't find the Document somehow, so warn the user that they must include the script ref themselves
      if (document == null) {
        warnManualIncludeRef();
        return;
      }

      final headArgument = document!.argumentList.arguments
          .whereType<NamedExpression>()
          .where((a) => a.name.label.name == 'head')
          .firstOrNull;

      if (headArgument == null) {
        // there was no head arg, so we add it as the first argument
        final anchor = document!.argumentList.arguments.firstOrNull;
        // we'll place the head arg right before the first existing arg, if there are none, we just place it after the left parenthesis of DOcument()
        final offset = anchor?.offset ?? document!.argumentList.leftParenthesis.end;
        builder.insert(offset, 'head: [\n        $scriptTag\n      ],\n      ');
      } else if (headArgument.expression case final ListLiteral list) {
        // if there already exists a head argument, we can add the script ref in there only if it doesn't already exist
        if (!list.toSource().contains('flutter_bootstrap.js')) {
          final indent = list.elements.isNotEmpty
              ? ''.padLeft(builder.getLineIndent(list.elements.last))
              : ''.padLeft(builder.getLineIndent(headArgument) + 2);
          builder.insert(list.rightBracket.offset, '$scriptTag\n$indent');
        }
      }

      // add an import for dom if not present
      final hasDomImport = result.unit.directives.whereType<ImportDirective>().any(
        (d) => d.uri.stringValue == 'package:jaspr/dom.dart',
      );

      // we place the import last, this gets sorted by dart format later on
      if (!hasDomImport) {
        final lastImport = result.unit.directives.whereType<ImportDirective>().lastOrNull;
        if (lastImport != null) {
          builder.insert(lastImport.end, "\nimport 'package:jaspr/dom.dart';");
        } else {
          // there were no other imports, add to the top
          builder.insert(0, "import 'package:jaspr/dom.dart';\n");
        }
      }

      serverEntrypoint.writeAsStringSync(builder.apply(content));
      Process.runSync('dart', ['format', serverEntrypoint.path, '--line-length=120']);
    }
  }

  /// include a ref to the flutter_bootstrap script in the index.html file
  /// used for client mode apps
  void includeInIndexHtml(Directory projectRoot) {
    final indexFile = File(p.join(projectRoot.path, 'web', 'index.html'));

    if (indexFile.existsSync()) {
      final html = indexFile.readAsStringSync();
      if (!html.contains('flutter_bootstrap.js')) {
        // place the script ref before the end of the head section
        final endOfHead = html.indexOf('</head>');
        indexFile.writeAsStringSync(
          html.replaceRange(endOfHead, endOfHead, '    <script src="flutter_bootstrap.js" async></script>\n'),
        );
      }
    } else {
      warnManualIncludeRef();
    }
  }

  /// returns the main.server.dart file if it exists and contains a Document, null otherwise
  File? getServerEntrypoint(Directory projectRoot) {
    final libDir = Directory(p.join(projectRoot.path, 'lib'));
    if (!libDir.existsSync()) return null;

    final file = File(p.join(libDir.path, 'main.server.dart'));
    if (!file.existsSync()) {
      return null;
    }

    if (file.readAsStringSync().contains('Document(')) {
      return file;
    }
    return null;
  }

  /// warn the user if the reference to the flutter_bootstrap.js script was not automatically included
  void warnManualIncludeRef() {
    logger.write(
      'Could not automatically include the Flutter bootstrap script.\n'
      '${project.requireMode.isServerOrStatic ? 'Add this to the head of your Document:\n  ${green.wrap('script(src: "flutter_bootstrap.js", async: true),')}' : 'Add this to the head of web/index.html:\n  ${green.wrap('<script src="flutter_bootstrap.js" async></script>')}'}',
      tag: Tag.cli,
      level: Level.warning,
    );
  }
}

class DocumentVisitor extends RecursiveAstVisitor<void> {
  DocumentVisitor(this.onDocument);
  final void Function(MethodInvocation) onDocument;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'Document') {
      onDocument(node);
      return;
    }
    super.visitMethodInvocation(node);
  }
}
