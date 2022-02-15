import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

void main(List<String> args) async {
  var runner = CommandRunner<int>("jaspr", "An experimental web framework for dart apps, supporting SPA and SSR.")
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

    webProcess.exitCode.then((code) {
      if (code != 0) {
        exit(code);
      }
    });

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

    process.stderr.listen((event) => stderr.add(event));
    process.stdout.listen((event) => stdout.add(event));

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
      dir.create();
    }

    var webProcess = await _runWebdev(['build', '--output=web:build/web']);

    String? entryPoint = await _getEntryPoint(argResults!['input']);

    if (entryPoint == null) {
      print("Cannot find entry point. Create a main.dart in lib/ or web/, or specify a file using --input.");
      return 1;
    }

    var process = await Process.start(
      'dart',
      ['compile', argResults!['target'], entryPoint, '-o', './build/app'],
    );

    process.stderr.listen((event) => stderr.add(event));
    process.stdout.listen((event) => stdout.add(event));

    var webResult = await webProcess.exitCode;
    var result = await process.exitCode;
    return webResult != 0 ? webResult : result;
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

  process.stderr.listen((event) => stderr.add(event));
  process.stdout.listen((event) => stdout.add(event));

  return process;
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
