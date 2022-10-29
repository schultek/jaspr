import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'command.dart';
import 'templates/templates.dart';

final RegExp _packageRegExp = RegExp(r'^[a-z_][a-z0-9_]*$');

class CreateCommand extends BaseCommand {
  CreateCommand() {
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
  Future<void> run() async {
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

    if (name.isEmpty || !_packageRegExp.hasMatch(name)) {
      usageException('"$name" is not a valid package name.');
    }

    var logger = Logger();
    final templateName = argResults!['template'] as String?;
    var template = templates.firstWhere((element) => element.name == templateName);

    var progress = logger.progress('Bootstrapping');
    var generator = await MasonGenerator.fromBundle(template);
    final files = await generator.generate(
      DirectoryGeneratorTarget(directory),
      vars: {'name': name, 'jasprCoreVersion': '0.1.0', 'jasprBuilderVersion': '0.1.0'},
      logger: logger,
    );
    progress.complete('Generated ${files.length} file(s)');

    var process = await Process.start('dart', ['pub', 'get'], workingDirectory: directory.absolute.path);

    await watchProcess(process, hide: (s) => s.contains('+'));

    print('\n'
        'Created project $name in $dir! In order to get started, run the following commands:\n\n'
        '  cd $dir\n'
        '  jaspr serve\n');
  }
}
