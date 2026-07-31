import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:mason/mason.dart' hide Level;
import 'package:path/path.dart' as p;

import '../bundles/new_component_bricks/new_content_page/new_content_page_bundle.dart';
import '../commands/base_command.dart';
import '../helpers/pubspec_helpers.dart';
import '../logging.dart';
import '../project.dart';

class NewPageCommand extends BaseCommand with PubspecHelper {
  NewPageCommand({super.logger}) {
    argParser.addOption(
      'path',
      abbr: 'p',
      help:
          'Location where the new page will be created (Defaults to ./content)', // NOTE: the default path is set in getTargetDirectory
    );
    argParser.addOption('format', help: 'Page format', defaultsTo: 'md');
    argParser.addOption('layout', help: 'Layout to use for the new page.');
    argParser.addOption(
      'title',
      help:
          'Frontmatter title to use for the new page. Defaults to the name in Title Case.', // default is not set here for obvious reasons
    );
    argParser.addOption('description', help: 'Front matter description to use for the new page.');
    argParser.addSeparator('Flags');
    argParser.addFlag(
      'dry-run',
      aliases: ['dry'],
      help: 'Preview the proposed changes but make no changes',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addFlag(
      'index',
      help: 'Create an index page instead of a normal page',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addFlag(
      'sitemap',
      help: 'Include sitemap configuration keys in the frontmatter',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addFlag(
      'meta',
      help: 'Include sample meta tag keys in the frontmatter',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addFlag(
      'sitemap-exclude',
      aliases: ['exclude-from-sitemap', 'sitemap-excluded'],
      help: 'Prevent the new page page from being included in the sitemap.',
      defaultsTo: false,
      negatable: false,
    );
    argParser.addFlag(
      'frontmatter',
      help: 'Enable/Disable the frontmatter entirely.',
      negatable: true,
      defaultsTo: true,
    );
  }

  @override
  String get invocation {
    return 'jaspr new page [arguments] <name>';
  }

  @override
  String get description => 'Create a new jaspr_content page.';

  @override
  String get name => 'page';

  // options
  late String pageFormat = argResults!.option('format')!; // defaults to md
  late String pageLayout = argResults!.option('layout') ?? '';
  late String pageTitle = argResults!.option('title') ?? '';
  late String pageDescription = argResults!.option('description') ?? '';

  // flags
  late final bool dryRun = argResults!.flag('dry-run');
  late final bool isIndexPage = argResults!.flag('index');
  late bool withSitemap = argResults!.flag('sitemap');
  late bool excludeFromSitemap = argResults!.flag('sitemap-exclude');
  late bool withMeta = argResults!.flag('meta');
  late bool withFrontmatter = argResults!.flag('frontmatter');

  @override
  Future<int> runCommand() async {
    // warn the user if they used both the flag to exclude the page from the sitemap and the one to include sample sitemap settings
    if (excludeFromSitemap && withSitemap) {
      logger.write(
        'Cannot both exclude the page from the sitemap and have sitemap configuration keys in the frontmatter at the same time. Ignoring the sitemap keys in frontmatter, page will be excluded from sitemap',
        tag: Tag.cli,
        level: Level.warning,
      );
      withSitemap = false;
    }

    // warn the user if they used the flag to disable the frontmatter but also set frontmatter related flags
    if (!withFrontmatter && (withMeta || withSitemap || excludeFromSitemap)) {
      logger.write(
        'No frontmatter will be created, ignoring all other frontmatter related flags',
        tag: Tag.cli,
        level: Level.warning,
      );
      withSitemap = false;
      withMeta = false;
      excludeFromSitemap = false;
    }

    final (customContentDir, parsers, layouts) = await checkContentApp();

    final (dir, name) = getTargetDirectory(customContentDir);

    final projectRoot = findProjectRoot(Directory.current.absolute) ?? Directory.current.absolute;
    final pubspecMap = readPubspec(projectRoot);

    if (dryRun) {
      logger.write(
        'Would generate new jaspr_content page $name.$pageFormat with title=$pageTitle, description=$pageDescription, layout=$pageLayout, dir=${blue.wrap(dir.path)}\n',
        tag: Tag.cli,
        level: Level.info,
      );

      if (!hasDep(pubspecMap, 'jaspr_content')) {
        logger.write(
          'Would prompt to add jaspr_content to dependencies.',
          tag: Tag.cli,
          level: Level.info,
        );
      }

      return 0;
    }

    if (project.requireMode == JasprMode.client) {
      logger.write(
        'Unable to create new jaspr_content page: jaspr_content cannot run as a client-side application.',
        tag: Tag.cli,
        level: Level.error,
      );
      return 1;
    }

    conditionallyInstallDeps(projectRoot, ['jaspr_content'], isDevDependency: false);

    return await createFromTemplate(
      dir,
      name,
      projectRoot,
      parsers,
      layouts,
    );
  }

  // figures out the page name and destination directory
  (Directory, String) getTargetDirectory(String customContentDir) {
    if (argResults!.rest.length > 1) {
      usageException(
        'Too many positional arguments were provided, please only provide the page name as positional argument.',
      );
    }

    final rawName = argResults!.rest.firstOrNull ?? logger.logger!.prompt('Specify a page name:');

    // the name may contain directories (e.g. "guides/deploying"), if that is the case then every segment except the last one
    // will be treated as directories nested under the target directory, with the last segment being the page name itself
    final segments = p
        .split(rawName.trim().replaceAll(r'\', '/'))
        .where((segment) => segment.isNotEmpty && segment != '.')
        .toList();

    // don't allow for path navigation when parsing the name
    if (p.isAbsolute(rawName) || segments.contains('..')) {
      usageException('The page name must be a relative path without "..", got "$rawName".');
    }

    // the last segment is the page name, everything before it are directories
    final pageName = segments.isEmpty ? '' : segments.removeLast().snakeCase;
    final nestedDirs = segments.map((segment) => segment.snakeCase).toList();

    if (pageName.isEmpty) {
      usageException('"$rawName" is not a valid page name.');
    } else if (pageName.startsWith(RegExp(r'_|\.'))) {
      logger.write('"$pageName" starts with "_" or "." and will not be loaded!', tag: Tag.cli, level: Level.warning);
    }

    if (pageTitle.isEmpty) {
      pageTitle = pageName.titleCase;
    }

    final pathOption = argResults!.option('path');
    Directory directory;
    if (pathOption == null) {
      // no path given, so we create the page in the default path (/content)

      // try to find the root of the project (where pubspec.yaml is), if it is the cwd then the command
      // was ran at the project root, otherwise it might have been ran elsewhere (e.g. "lib/components")
      final projectRoot = findProjectRoot(Directory.current.absolute) ?? Directory.current.absolute;

      final String defaultDir = customContentDir.isNotEmpty ? customContentDir : 'content';
      directory = Directory(p.join(projectRoot.path, defaultDir));
    } else {
      // if the user passed a directory, then we use that
      directory = Directory(pathOption).absolute;
    }

    // nest the page under the directories that were given as part of the name
    if (nestedDirs.isNotEmpty) {
      directory = Directory(p.joinAll([directory.path, ...nestedDirs]));
    }

    // for an index page we nest the file in a directory named after the page and name the file "index"
    // e.g. "jaspr new page guides --index" creates "content/guides/index.md" instead of "content/guides.md"
    // note that the frontmatter title is still based on the page name and not on "index"
    var fileName = pageName;
    if (isIndexPage) {
      directory = Directory(p.join(directory.path, pageName.snakeCase));
      fileName = 'index';
    }

    if (!dryRun && !directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return (directory, fileName);
  }

  /// Generate the page with the mason template
  Future<int> createFromTemplate(
    Directory dir,
    String name,
    Directory projectRoot,
    List<String> parsers,
    List<String> layouts,
  ) async {
    logger.write(
      'Generating new page "$name.$pageFormat"...',
      tag: Tag.cli,
      level: Level.info,
      progress: ProgressState.running,
    );

    // if no custom parsers are used and the format provided is not parsable, then warn the user
    // e.g., if the user want's a markdown page but only the HtmlParser is used
    if (parsers.isNotEmpty && !parsers.contains(pageFormat) && !parsers.contains('custom')) {
      final confirmRes =
          logger.logger?.confirm(
            '\n[WARNING] Could not find the parser required to parse the provided format "$pageFormat". Do you want to continue anyway?',
            defaultValue: false,
          ) ??
          false;
      if (!confirmRes) {
        logger.write(
          'Cancelling... Please add the required parser to parse $pageFormat',
          tag: Tag.cli,
          level: Level.error,
        );
        return 1;
      }
    }

    // if the layouts section isnt empty and the user has passed in a specific layout, but that layout isn't a predefined layout and the layouts section does not contain a custom layout
    // then warn the user that this layout may or may not work as they expect
    if (layouts.isNotEmpty && pageLayout.isNotEmpty && !layouts.contains(pageLayout) && !layouts.contains('custom')) {
      final confirmRes =
          logger.logger?.confirm(
            '\n[WARNING] Could not find the prebuilt layout to display the requested "$pageLayout" and no custom layout is defined. Do you want to continue anyway?',
            defaultValue: false,
          ) ??
          false;
      if (!confirmRes) {
        logger.write(
          'Cancelling... Please add the required prebuilt layout to correctly display $pageLayout',
          tag: Tag.cli,
          level: Level.error,
        );
        return 1;
      }
    }

    // select the right bundle based on the required component type
    final generator = await MasonGenerator.fromBundle(newContentPageBundle);
    final files = await generator.generate(
      DirectoryGeneratorTarget(dir),
      vars: {
        'name': name,
        'title': pageTitle,
        'description': pageDescription.isEmpty ? false : pageDescription,
        'layout': pageLayout.isEmpty ? false : pageLayout,
        'format': pageFormat,
        'meta': withMeta,
        'sitemap': withSitemap,
        'sitemap-exclude': excludeFromSitemap,
        'frontmatter': withFrontmatter,
        'date': () {
          // sitemap date
          final n = DateTime.now();
          return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
        }(),
        'isMd': pageFormat.contains('md'),
        'isHtml': pageFormat == 'html',
      },
      logger: logger.logger,
    );

    logger.write(
      'Generated new page $name.$pageFormat ${blue.wrap(p.relative(files.first.path, from: projectRoot.path))}',
      tag: Tag.cli,
      level: Level.info,
      progress: ProgressState.completed,
    );

    return 0;
  }

  Future<(String, List<String>, List<String>)> checkContentApp() async {
    final String? serverEntrypointPath = await getServerEntryPoint(null);
    if (serverEntrypointPath == null) {
      logger.write(
        'Could not find server entrypoint and therefore unable to find ContentApp.',
        level: Level.warning,
        tag: Tag.cli,
      );
      return ('', <String>[], <String>[]);
    } else {
      final File serverEntrypoint = File(serverEntrypointPath);
      final content = serverEntrypoint.readAsStringSync();

      final result = parseString(
        content: content,
        featureSet: FeatureSet.latestLanguageVersion(flags: ['dot-shorthands']),
      );

      final ContentAppVisitor contentAppVisitor = ContentAppVisitor();
      result.unit.visitChildren(contentAppVisitor);

      if (contentAppVisitor.contentApp == null) {
        logger.write(
          'Could not find ContentApp in the server entrypoint',
          level: Level.warning,
          tag: Tag.cli,
        );
        return ('', <String>[], <String>[]);
      }

      final namedArgs = contentAppVisitor.contentApp!.argumentList.arguments.whereType<NamedExpression>();

      // small helper to get the expression for an argument
      Expression? argument(String name) => namedArgs.where((a) => a.name.label.name == name).firstOrNull?.expression;

      // get the expression from the directory arg, if the argument is present, then the pages may be located elsewhere than "content"
      final customContentDir = switch (argument('directory')) {
        StringLiteral(:final stringValue?) => stringValue,
        _ => '',
      };

      logger.write(
        'Found custom content directory ${blue.wrap(customContentDir)}.',
        level: Level.verbose,
        tag: Tag.cli,
      );

      // obtain the list of parsers that are in use to warn the user if the wanted format is not parsable
      final parsers = _parserFormats(argument('parsers'));

      logger.write(
        'Found parsers: ${yellow.wrap(parsers.toString())}.',
        level: Level.verbose,
        tag: Tag.cli,
      );

      // obtain the list of layouts that are in use
      final layouts = _layoutNames(argument('layouts'));

      logger.write(
        'Found parsers: ${yellow.wrap(parsers.toString())}.',
        level: Level.verbose,
        tag: Tag.cli,
      );

      return (customContentDir, parsers, layouts);
    }
  }
}

/// returns the file extensions that are by the parsers listed in ContentApp(parsers: [...],...).
/// the mardown parser will return ['md', 'mdx'], the html parser ['html'], and any custom parser will return ['custom']
List<String> _parserFormats(Expression? parsers) {
  if (parsers is! ListLiteral) return const [];
  return [
    for (final element in parsers.elements)
      ...switch (element) {
        // e.g., MarkdownParser()
        MethodInvocation() => _parserExtensions(element.methodName.name),
        // e.g., const MarkdownParser()
        InstanceCreationExpression() => _parserExtensions(element.constructorName.type.toSource()),
        _ => const ['custom'],
      },
  ];
}

List<String> _parserExtensions(String name) => switch (name) {
  'MarkdownParser' => const ['md', 'mdx'],
  'HtmlParser' => const ['html'],
  _ => const ['custom'],
};

List<String> _layoutNames(Expression? layouts) {
  if (layouts is! ListLiteral) return const [];

  return [
    for (final element in layouts.elements)
      switch (element) {
        // e.g. BlogLayout()
        MethodInvocation() => _defaultLayoutToName(element.methodName.name),
        // eg. const BlogLayout()
        InstanceCreationExpression() => _defaultLayoutToName(element.constructorName.type.toSource()),
        _ => 'custom',
      },
  ];
}

String _defaultLayoutToName(String defaultLayoutName) => switch (defaultLayoutName) {
  'DocsLayout' => 'docs',
  'BlogLayout' => 'blog',
  'EmptyLayout' => 'empty',
  _ => 'custom',
};

class ContentAppVisitor extends RecursiveAstVisitor<void> {
  MethodInvocation? contentApp;
  bool isCustom = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    final target = node.target?.toSource();
    if (contentApp == null) {
      if (name == 'ContentApp') {
        contentApp = node;
      } else if (target == 'ContentApp') {
        // named contructor of ContentApp (e.g., ContentApp.custom())
        contentApp = node;
        isCustom = name == 'custom';
      }
    }

    super.visitMethodInvocation(node);
  }
}
