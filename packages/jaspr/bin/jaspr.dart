import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

void main(List<String> args) async {
  var runner = CommandRunner<int>("jaspr", "An experimental web framework for dart apps, supporting SPA and SSR.")
    ..addCommand(CreateCommand())
    ..addCommand(ServeCommand())
    ..addCommand(BuildCommand());

  var n = 0;
  ProcessSignal.sigint.watch().listen((signal) {
    print(" caught ${++n} of 3");
    if (n == 3) {
      exit(0);
    }
  });

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

    var targetPath = argResults!.rest.first;

    var directory = Directory(targetPath);
    var dir = path.basename(targetPath);
    var name = dir.replaceAll('-', '_');

    if (await directory.exists()) {
      return usageException('Directory $targetPath already exists.');
    }

    var process = await Process.start('dart', ['create', '-t', 'web-simple', '--no-pub', directory.absolute.path]);

    _pipeProcess(process, until: (s) => s.contains('Created project'));

    await maybeExit(process.exitCode);

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
      help: 'Specify the input file for the web app.',
    );
    argParser.addOption(
      'mode',
      abbr: 'm',
      help: 'Sets the reload/refresh mode.',
      allowed: ['reload', 'refresh'],
      allowedHelp: {
        'reload': 'Reloads js modules without server reload (loses current state)',
        'refresh': 'Performs a full page refresh and server reload',
      },
      defaultsTo: 'reload',
    );
    argParser.addOption(
      'port',
      abbr: 'p',
      help: 'Specify a port to run the dev server on.',
      defaultsTo: '8080',
    );
    argParser.addFlag(
      'debug',
      abbr: 'd',
      help: 'Serves the app in debug mode.',
    );
    argParser.addFlag('verbose', abbr: 'v', help: 'Enable verbose logging.');
  }

  @override
  String get description => 'Runs a development server that serves the web app with SSR and '
      'reloads based on file system updates.';

  @override
  String get name => 'serve';

  @override
  Future<int> run() async {
    var webProcess = await _runWebdev([
      'serve',
      '--auto=${argResults!['mode'] == 'reload' ? 'restart' : 'refresh'}',
      'web:5467',
      '--',
      '--delete-conflicting-outputs'
    ]);

    print("Starting jaspr development server...");

    var buildCompleted = StreamController<int>.broadcast();
    var build = 0;

    checkWebdevStarted(String str) {
      if (str.contains('Running build completed')) {
        buildCompleted.add(build++);
      }
    }

    var verbose = argResults!['verbose'] as bool;

    if (verbose) {
      _pipeProcess(webProcess, listen: checkWebdevStarted);
    } else {
      _pipeError(webProcess);
      webProcess.stdout.map(utf8.decode).listen(checkWebdevStarted);
    }

    maybeExit(
      webProcess.exitCode,
      onExit: !verbose
          ? () => stdout.write('webdev serve exited unexpectedly. Run again with -v to see verbose output')
          : null,
    );

    await buildCompleted.stream.first;

    var args = [
      'run',
      '--enable-vm-service',
      '--enable-asserts',
      '-Djaspr.debug=true',
      '-Djaspr.hotreload=true',
    ];

    if (argResults!['debug']) {
      args.add('--pause-isolates-on-start');
    }

    String? entryPoint = await _getEntryPoint(argResults!['input']);

    if (entryPoint == null) {
      print("Cannot find entry point. Create a main.dart in lib or web, or specify a file using --input.");
      return 1;
    }

    args.add(entryPoint);

    args.addAll(argResults!.rest);

    var process = await Process.start(
      'dart',
      args,
      environment: {'PORT': argResults!['port'], 'JASPR_PROXY_PORT': '5467'},
    );

    _pipeProcess(process);
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
    var dir = Directory('build');
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
    process = await Process.start('dart', ['pub', 'global', 'run', 'webdev', ...args]);
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

Future<void> maybeExit(Future<int> exitResult, {void Function()? onExit}) async {
  var exitCode = await exitResult;
  if (exitCode != 0) {
    onExit?.call();
    exit(exitCode);
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
