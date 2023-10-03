import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

import '../logging.dart';
import '../templates.dart';
import '../version.dart';
import 'base_command.dart';

final RegExp _packageRegExp = RegExp(r'^[a-z_][a-z0-9_]*$');

final templatesByName = {for (var t in templates) t.name: t};
final templateDescriptionByName = {for (var t in templates) t.name: t.description};

class CreateCommand extends BaseCommand {
  CreateCommand({super.logger}) {
    argParser.addOption(
      'template',
      abbr: 't',
      help: 'The template used to generate this new project.',
      allowed: templatesByName.keys,
      allowedHelp: templateDescriptionByName,
    );
    argParser.addFlag(
      'experimental-web-compilers',
      abbr: 'c',
      help:
          'Use jaspr web compilers (experimental)? This enables the use of flutter web plugins and direct flutter embedding.',
      defaultsTo: null,
    );
  }

  @override
  String get invocation {
    return "jaspr create [arguments] <directory>";
  }

  @override
  String get description => 'Create a new jaspr project.';

  @override
  String get name => 'create';

  @override
  bool get requiresPubspec => false;

  @override
  Future<int> run() async {
    await super.run();

    var targetPath = argResults!.rest.firstOrNull;
    targetPath ??= logger.logger.prompt('Specify a target directory:');

    var directory = Directory(targetPath);
    var dir = path.basenameWithoutExtension(directory.path);
    var name = dir.replaceAll('-', '_');

    if (await directory.exists()) {
      usageException('Directory $targetPath already exists.');
    }

    if (name.isEmpty) {
      usageException('You must specify a snake_case package name.');
    } else if (!_packageRegExp.hasMatch(name)) {
      usageException('"$name" is not a valid package name.\n\n'
          'You should use snake_case for the package name e.g. my_jaspr_project');
    }

    var templateName = argResults!['template'] as String?;
    templateName ??= logger.logger.chooseOne('Choose a template:',
        choices: templatesByName.keys.toList(), display: (name) => '$name: ${templateDescriptionByName[name]}');

    var template = templatesByName[templateName]!;

    var useJasprCompilers = argResults!['experimental-web-compilers'] as bool?;
    useJasprCompilers ??= logger.logger.confirm(
        'Use jaspr web compilers (experimental)? This enables the use of flutter web plugins and direct flutter embedding.',
        defaultValue: true);

    var progress = logger.logger.progress('Bootstrapping');
    var generator = await MasonGenerator.fromBundle(template);
    final files = await generator.generate(
      DirectoryGeneratorTarget(directory),
      vars: {
        'name': name,
        'jasprCoreVersion': jasprCoreVersion,
        'jasprBuilderVersion': jasprBuilderVersion,
        'webCompilersPackage': useJasprCompilers ? 'jaspr_web_compilers' : 'build_web_compilers',
        'webCompilersVersion': useJasprCompilers ? '4.0.4' : '4.0.4', // TODO get latest version from pub
      },
      logger: logger.logger,
    );
    progress.complete('Generated ${files.length} file(s)');

    var process = await Process.start('dart', ['pub', 'get'], workingDirectory: directory.absolute.path);

    await watchProcess('pub', process,
        tag: Tag.cli, progress: 'Resolving dependencies...', hide: (s) => s.contains('+'));

    logger.write('\n'
        'Created project $name in $dir! In order to get started, run the following commands:\n\n'
        '  cd $dir\n'
        '  jaspr serve\n');

    return ExitCode.success.code;
  }
}
