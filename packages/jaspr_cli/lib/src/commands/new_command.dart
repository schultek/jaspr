import 'dart:io';

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
import '../helpers/flutter_embed_helpers.dart';
import '../helpers/pubspec_helpers.dart';
import '../logging.dart';
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

class ComponentCommand extends BaseCommand with PubspecHelper, FlutterEmbedSetupHelper {
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

  // nullable bool so that we know if the user passed the flag (true), negated the flag (false), or didn't pass it in (null)
  // if null, then prompt the user to ask if they want to generate the sample widget or not. If false, we respect it and don't prompt it
  late bool? withSampleFlutterWidget = argResults!.wasParsed('with-sample-flutter-widget')
      ? argResults!.flag('with-sample-flutter-widget')
      : null;

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

  // figures out the component name and destination directory
  (Directory, String) getTargetDirectory() {
    if (argResults!.rest.length > 1) {
      usageException(
        'Too many positional arguments were provided, please only provide the component name as positional argument.',
      );
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
    conditionallyInstallDeps(projectRoot, ['jaspr_test'], isDevDependency: true);

    return 0;
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
        '--with-test argument ignored for FlutterEmbeddedView components.',
        tag: Tag.cli,
        level: Level.warning,
      );
    }

    final projectRoot = findProjectRoot(Directory.current.absolute) ?? Directory.current.absolute;

    if (dryRun) {
      dryRunFlutterViewComponent(dir, name, projectRoot);
      return 0;
    }

    // add flutter and jaspr_flutter_embed in dependencies if they aren't present (prompts to add them)
    conditionallyInstallDeps(projectRoot, ['flutter', 'jaspr_flutter_embed'], isDevDependency: false);
    // also install other useful deps
    conditionallyInstallDeps(projectRoot, ['flutter_lints', 'flutter_test'], isDevDependency: true);

    // set jaspr.flutter mode to embedded if it isn't the case
    // If the flutter mode is set to plugins, then we ask the user if they
    // want to overwrite it or not
    setFlutterMode(projectRoot);

    // set flutter.uses-material-design to true in pubspec.yaml
    setUseMaterialDesignPubspec(projectRoot);

    // create the flutter_bootstrap.js script
    createFlutterBootstrapScript(projectRoot);

    // Include a reference to the bootstrap script in the proper document depending on the current rendering mode
    // for server or static, we include it in the head of the Document found in the server entrypoint
    // for client side applications, we include it in the index.html file
    final mode = readMode(readPubspec(projectRoot));
    if (mode == null) {
      warnManualIncludeRef();
    } else if (mode.isServerOrStatic) {
      includeBootstrapRefInDoc(projectRoot);
    } else {
      includeInIndexHtml(projectRoot);
    }

    // generate the FlutterEmbeddedView component and optionally a sample Flutter widget/app
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
}
