import 'dart:async';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:webdev/src/command/build_command.dart' as wd;

import 'base_command.dart';

class BuildCommand extends BaseCommand {
  BuildCommand({super.logger}) {
    argParser.addOption(
      'input',
      abbr: 'i',
      help: 'Specify the input file for the web app',
      defaultsTo: 'lib/main.dart',
    );
    argParser.addFlag(
      'ssr',
      defaultsTo: true,
      help: 'Optionally disables server-side rendering and runs as a pure client-side app.',
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
    await super.run();

    var useSSR = argResults!['ssr'] as bool;

    if (useSSR) {
      var dir = Directory('build');
      if (!await dir.exists()) {
        await dir.create();
      }
    }

    wd.BuildCommand();

    var webProcess = await runWebdev([
      'build',
      '--output=web:build${useSSR ? '/web' : ''}',
      '--',
      '--delete-conflicting-outputs',
      '--define=build_web_compilers:entrypoint=dart2js_args=["-Djaspr.flags.release=true"]'
    ]);

    var webResult = watchProcess(webProcess);
    if (useSSR) {
      unawaited(webResult);
    } else {
      await webResult;
      return ExitCode.success.code;
    }

    String? entryPoint = await getEntryPoint(argResults!['input']);

    if (entryPoint == null) {
      logger.warn("Cannot find entry point. Create a main.dart in lib/ or web/, or specify a file using --input.");
      await shutdown(1);
    }

    var process = await Process.start(
      'dart',
      ['compile', argResults!['target'], entryPoint, '-o', './build/app', '-Djaspr.flags.release=true'],
    );

    unawaited(watchProcess(process));

    await waitActiveProcesses();

    return ExitCode.success.code;
  }
}
