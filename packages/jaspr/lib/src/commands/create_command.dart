import 'dart:io';

import 'package:path/path.dart' as path;

import 'command.dart';

class CreateCommand extends BaseCommand {
  CreateCommand();

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
    var dir = path.basename(targetPath);
    var name = dir.replaceAll('-', '_');

    if (await directory.exists()) {
      usageException('Directory $targetPath already exists.');
    }

    var process = await Process.start('dart', ['create', '-t', 'web-simple', '--no-pub', directory.absolute.path]);

    await watchProcess(process, until: (s) => s.contains('Created project'));

    var webMain = File(path.join(directory.absolute.path, 'web/main.dart'));
    var pubspecFile = File(path.join(directory.absolute.path, 'pubspec.yaml'));
    var libMain = File(path.join(directory.absolute.path, 'lib/main.dart'));
    var appDart = File(path.join(directory.absolute.path, 'lib/app.dart'));

    await Future.wait([
      webMain.writeAsString(mainFileContent('package:$name')),
      pubspecFile.writeAsString(pubspecYaml(name)),
      libMain
          .create(recursive: true)
          .then((_) => libMain.writeAsString(mainFileContent('.')))
          .then((_) => print('  lib/app.dart')),
      appDart
          .create(recursive: true)
          .then((_) => appDart.writeAsString(appFileContent()))
          .then((_) => print('  lib/app.dart')),
    ]);

    print('');

    process = await Process.start('dart', ['pub', 'get'], workingDirectory: directory.absolute.path);

    await watchProcess(process, hide: (s) => s.contains('+'));

    print('\n'
        'Created project $name in $dir! In order to get started, run the following commands:\n\n'
        '  cd $dir\n'
        '  jaspr serve\n');
  }
}

String mainFileContent(package) => ""
    "import 'package:jaspr/jaspr.dart';\n"
    "import '$package/app.dart';\n"
    "\n"
    "void main() {\n"
    "  runApp(App());\n"
    "}";
String appFileContent() => ""
    "import 'package:jaspr/jaspr.dart';\n"
    "\n"
    "class App extends StatelessComponent {\n"
    "  @override\n"
    "  Iterable<Component> build(BuildContext context) sync* {\n"
    "    yield DomComponent(\n"
    "      tag: 'p',\n"
    "      child: Text('Hello World'),\n"
    "    );\n"
    "  }\n"
    "}";
String pubspecYaml(String name) => ""
    "name: $name\n"
    "description: A minimal jaspr web app.\n"
    "version: 0.0.1\n"
    "\n"
    "environment:\n"
    "  sdk: '>=2.16.0 <3.0.0'\n"
    "\n"
    "dependencies:\n"
    "  jaspr: ^0.1.0\n"
    "\n"
    "dev_dependencies:\n"
    "  build_runner: ^2.1.4\n"
    "  build_web_compilers: ^3.2.1\n"
    "  lints: ^1.0.0\n"
    "  webdev: 2.7.7";
