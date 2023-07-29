import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

import '../templates.dart';
import '../version.dart';
import 'base_command.dart';

final RegExp _packageRegExp = RegExp(r'^[a-z_][a-z0-9_]*$');

class CreateCommand extends BaseCommand {
  CreateCommand({super.logger}) {
    argParser.addOption(
      'template',
      abbr: 't',
      help: 'The template used to generate this new project.',
      mandatory: true,
      allowed: templates.map((element) => element.name).toList(),
      allowedHelp: templates.fold<Map<String, String>>(
        {},
        (h, e) => {
          ...h,
          e.name: e.description,
        },
      ),
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
  final bool requiresPubspec = false;

  @override
  Future<int> run() async {
    await super.run();

    if (argResults!.rest.isEmpty) {
      usageException('Specify a target directory.');
    }

    var targetPath = argResults!.rest.first;

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

    final templateName = argResults!['template'] as String?;
    var template = templates.firstWhere((element) => element.name == templateName);

    var progress = logger.progress('Bootstrapping');
    var generator = await MasonGenerator.fromBundle(template);
    final files = await generator.generate(
      DirectoryGeneratorTarget(directory),
      vars: {
        'name': name,
        'jasprCoreVersion': jasprCoreVersion,
        'jasprBuilderVersion': jasprBuilderVersion,
      },
      logger: logger,
    );
    progress.complete('Generated ${files.length} file(s)');

    var process = await Process.start('dart', ['pub', 'get'], workingDirectory: directory.absolute.path);

    await watchProcess(process, progress: 'Resolving dependencies...', hide: (s) => s.contains('+'));

    logger.info('\n'
        'Created project $name in $dir! In order to get started, run the following commands:\n\n'
        '  cd $dir\n'
        '  jaspr serve\n');

    return ExitCode.success.code;
  }
}
