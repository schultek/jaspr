import 'dart:async';
import 'dart:io';

import 'command.dart';

class BuildCommand extends BaseCommand {
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
  Future<void> run() async {
    await super.run();

    var dir = Directory('build');
    if (!await dir.exists()) {
      await dir.create();
    }

    var webProcess = await runWebdev(['build', '--output=web:build/web']);
    unawaited(watchProcess(webProcess));

    String? entryPoint = await getEntryPoint(argResults!['input']);

    if (entryPoint == null) {
      print("Cannot find entry point. Create a main.dart in lib/ or web/, or specify a file using --input.");
      shutdown(1);
    }

    var process = await Process.start(
      'dart',
      ['compile', argResults!['target'], entryPoint, '-o', './build/app'],
    );

    unawaited(watchProcess(process));

    await waitActiveProcesses();
  }
}
