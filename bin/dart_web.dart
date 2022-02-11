import 'dart:io';

import 'package:args/command_runner.dart';

void main(List<String> args) async {
  var runner = CommandRunner<int>("dart_web", "An experimental web framework for dart apps, supporting SPA and SSR.")
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
      defaultsTo: 'lib/main.dart',
    );
  }

  @override
  String get description => 'Runs a development server that serves the web app with SSR and '
      'reloads based on file system updates.';

  @override
  String get name => 'serve';

  @override
  Future<int> run() async {
    var webProcess = await Process.start(
      'webdev',
      ['serve', '--auto=refresh', 'web:5467'],
    );

    webProcess.stderr.listen((event) => stderr.add(event));
    webProcess.stdout.listen((event) => stdout.add(event));

    var process = await Process.start(
      'dart',
      ['run', '--enable-vm-service', '--enable-asserts', argResults!['input']],
      environment: {
        'DART_WEB_MODE': 'DEBUG',
        'DART_WEB_PROXY_PORT': '5467',
      },
    );

    process.stderr.listen((event) => stderr.add(event));
    process.stdout.listen((event) => stdout.add(event));

    return await process.exitCode;
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

    var webProcess = await Process.start(
      'webdev',
      ['build', '--output=web:build/web'],
    );

    webProcess.stderr.listen((event) => stderr.add(event));
    webProcess.stdout.listen((event) => stdout.add(event));

    var process = await Process.start(
      'dart',
      ['compile', argResults!['target'], argResults!['input'], '-o', './build/app'],
    );

    process.stderr.listen((event) => stderr.add(event));
    process.stdout.listen((event) => stdout.add(event));

    var webResult = await webProcess.exitCode;
    var result = await process.exitCode;
    return webResult != 0 ? webResult : result;
  }
}
