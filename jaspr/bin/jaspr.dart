import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';

void main(List<String> args) async {
  var runner = CommandRunner<int>("jaspr", "An experimental web framework for dart apps, supporting SPA and SSR.")
    ..addCommand(CreateCommand())
    ..addCommand(ServeCommand())
    ..addCommand(BuildCommand());

  try {
    var result = await runner.run(args);
    exit(result ?? 0);
  } on UsageException catch (e) {
    print(e.message);
    print('');
    print(e.usage);
  }
}

class CreateCommand extends Command<int> {
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
  Future<int> run() async {
    if (argResults!.rest.isEmpty) {
      return usageException('Specify a target directory.');
    }

    var path = argResults!.rest.first;

    var directory = Directory(path);
    var dir = basename(path);
    var name = dir.replaceAll('-', '_');

    if (await directory.exists()) {
      return usageException('Directory $path already exists.');
    }

    var process = await Process.start('dart', ['create', '-t', 'web-simple', '--no-pub', directory.absolute.path]);

    _pipeProcess(process, until: (s) => s.contains('Created project'));

    await maybeExit(process.exitCode);

    var webMain = File(join(directory.absolute.path, 'web/main.dart'));
    var pubspecFile = File(join(directory.absolute.path, 'pubspec.yaml'));
    var libMain = File(join(directory.absolute.path, 'lib/main.dart'));
    var appDart = File(join(directory.absolute.path, 'lib/app.dart'));

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

    _pipeProcess(process, hide: (s) => s.contains('+'));
    await maybeExit(process.exitCode);

    print('\n'
        'Created project $name in $dir! In order to get started, run the following commands:\n\n'
        '  cd $dir\n'
        '  jaspr serve\n');

    return 0;
  }
}

class ServeCommand extends Command<int> {
  ServeCommand() {
    argParser.addOption(
      'input',
      abbr: 'i',
      help: 'Specify the input file for the web app',
    );
  }

  @override
  String get description => 'Runs a development server that serves the web app with SSR and '
      'reloads based on file system updates.';

  @override
  String get name => 'serve';

  @override
  Future<int> run() async {
    var webProcess = await _runWebdev(['serve', '--auto=refresh', 'web:5467']);

    var startupCompleter = Completer();
    _pipeProcess(webProcess, listen: (str) {
      if (str.contains('Serving `web`') && !startupCompleter.isCompleted) {
        startupCompleter.complete();
      }
    });
    maybeExit(webProcess.exitCode);

    await startupCompleter.future;

    String? entryPoint = await _getEntryPoint(argResults!['input']);

    if (entryPoint == null) {
      print("Cannot find entry point. Create a main.dart in lib or web, or specify a file using --input.");
      return 1;
    }

    var process = await Process.start(
      'dart',
      ['run', '--enable-vm-service', '--enable-asserts', entryPoint],
      environment: {
        'DART_WEB_MODE': 'DEBUG',
        'DART_WEB_PROXY_PORT': '5467',
      },
    );

    _pipeProcess(process);

    await Future.wait([webProcess.exitCode, process.exitCode]);
    return process.exitCode;
  }
}

class BuildCommand extends Command<int> {
  BuildCommand() {
    argParser.addOption(
      'input',
      abbr: 'i',
      help: 'Specify the input file for the web app',
      defaultsTo: 'lib/main.dart',
    );
    argParser.addOption(
      'target',
      abbr: 't',
      allowed: ['aot-snapshot', 'exe', 'jit-snapshot'],
      allowedHelp: {
        'aot-snapshot': 'Compile Dart to an AOT snapshot.',
        'exe': 'Compile Dart to a self-contained executable.',
        'jit-snapshot': 'Compile Dart to a JIT snapshot.',
      },
      defaultsTo: 'exe',
    );
  }

  @override
  String get description => 'Performs a single build on the specified target and then exits.';

  @override
  String get name => 'build';

  @override
  Future<int> run() async {
    var dir = Directory.fromUri(Uri.parse(Directory.current.path + "/build"));

    if (!await dir.exists()) {
      await dir.create();
    }

    var webProcess = await _runWebdev(['build', '--output=web:build/web']);
    _pipeProcess(webProcess);

    String? entryPoint = await _getEntryPoint(argResults!['input']);

    if (entryPoint == null) {
      print("Cannot find entry point. Create a main.dart in lib/ or web/, or specify a file using --input.");
      return 1;
    }

    var process = await Process.start(
      'dart',
      ['compile', argResults!['target'], entryPoint, '-o', './build/app'],
    );

    _pipeProcess(process);

    await Future.wait([maybeExit(webProcess.exitCode), maybeExit(process.exitCode)]);
    return 0;
  }
}

Future<Process> _runWebdev(List<String> args) async {
  var globalPackageList = await Process.run('dart', ['pub', 'global', 'list'], stdoutEncoding: Utf8Codec());
  var hasGlobalWebdev = (globalPackageList.stdout as String).contains('webdev');

  Process process;

  if (hasGlobalWebdev) {
    process = await Process.start('webdev', args);
  } else {
    process = await Process.start('dart', ['run', 'webdev', ...args]);
  }

  return process;
}

void _pipeError(Process process) {
  process.stderr.listen((event) => stderr.add(event));
}

void _pipeProcess(Process process,
    {bool Function(String)? until, bool Function(String)? hide, void Function(String)? listen}) {
  _pipeError(process);
  bool pipe = true;
  process.stdout.listen((event) {
    String? _decoded;
    String decoded() => _decoded ??= utf8.decode(event);

    if (pipe && until != null) {
      pipe = !until(decoded());
    }
    if (!pipe) return;
    if (hide?.call(decoded()) ?? false) return;
    listen?.call(decoded());
    stdout.add(event);
  });
}

Future<String?> _getEntryPoint(String? input) async {
  var entryPoints = [input, 'lib/main.dart', 'web/main.dart'];
  String? entryPoint;

  for (var path in entryPoints) {
    if (path == null) continue;
    if (await File(path).exists()) {
      entryPoint = path;
      break;
    }
  }

  return entryPoint;
}

Future<void> maybeExit(Future<int> exitResult) async {
  var exitCode = await exitResult;
  if (exitCode != 0) exit(exitCode);
}

String mainFileContent(package) => ""
    "import 'package:jaspr/jaspr.dart';\n"
    "import '$package/app.dart';\n"
    "\n"
    "void main() {\n"
    "  runApp(() => App(), id: 'output');\n"
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
    "  jaspr:\n"
    "    git:\n"
    "      url: https://github.com/schultek/jaspr\n"
    "      path: jaspr\n"
    "\n"
    "dev_dependencies:\n"
    "  build_runner: ^2.1.4\n"
    "  build_web_compilers: ^3.2.1\n"
    "  lints: ^1.0.0\n"
    "  webdev: ^2.7.7";
