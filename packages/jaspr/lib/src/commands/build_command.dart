import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'command.dart';

class BuildCommand extends BaseCommand {
  BuildCommand() {
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
    argParser.addOption('flutter',
        help: 'Build an embedded flutter app from the specified entrypoint.');
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

    var useSSR = argResults!['ssr'] as bool;
    var flutter = argResults!['flutter'] as String?;

    if (useSSR) {
      var webDir = Directory('build/web');
      if (!await webDir.exists()) {
        await webDir.create();
      }
    }

    var webTargetPath = 'build${useSSR ? '/web' : ''}';

    var indexHtml = File('web/index.html');
    var targetIndexHtml = File('build/web/index.html');

    var dummyIndex = false;
    if (flutter != null && !await indexHtml.exists()) {
      dummyIndex = true;
      await indexHtml.create();
    }

    var webProcess = await runWebdev([
      'build',
      '--output=web:$webTargetPath',
      '--',
      '--delete-conflicting-outputs',
      '--define=build_web_compilers:entrypoint=dart2js_args=["-Djaspr.flags.release=true"]'
    ]);

    var webResult = watchProcess(webProcess);
    var flutterResult = Future<void>.value();

    if (flutter != null) {
      var flutterProcess = await Process.start(
        'flutter',
        ['build', 'web', '-t', flutter, '--output=build/flutter'],
      );

      var moveTargets = [
        'version.json',
        'main.dart.js',
        'flutter_service_worker.js',
        'flutter.js',
        'canvaskit/',
      ];

      flutterResult = Future(() async {
        await watchProcess(flutterProcess);

        var moves = <Future>[];
        while (moveTargets.isNotEmpty) {
          var moveTarget = moveTargets.removeAt(0);
          if (moveTarget.endsWith('/')) {
            await Directory('build/web/$moveTarget').create(recursive: true);

            var files = Directory('build/flutter/$moveTarget').list(recursive: true);
            await for (var file in files) {
              final path = p.relative(file.path, from: 'build/flutter');
              if (file is Directory) {
                moveTargets.add(path);
              } else {
                moveTargets.add(path);
              }
            }
          } else {
            moves.add(File('./build/flutter/$moveTarget').copy('./build/web/$moveTarget'));
          }
        }

        await Future.wait(moves);
      });
    }

    if (!useSSR) {
      await Future.wait([
        webResult,
        flutterResult,
      ]);

      if (dummyIndex) {
        await indexHtml.delete();
        if (await targetIndexHtml.exists()) {
          await targetIndexHtml.delete();
        }
      }

      return;
    }

    String? entryPoint = await getEntryPoint(argResults!['input']);

    if (entryPoint == null) {
      print(
          "Cannot find entry point. Create a main.dart in lib/ or web/, or specify a file using --input.");
      shutdown(1);
    }

    var process = await Process.start(
      'dart',
      [
        'compile',
        argResults!['target'],
        entryPoint,
        '-o',
        './build/app',
        '-Djaspr.flags.release=true'
      ],
    );

    await Future.wait([
      webResult,
      flutterResult,
      watchProcess(process),
    ]);

    if (dummyIndex) {
      await indexHtml.delete();
      if (await targetIndexHtml.exists()) {
        await targetIndexHtml.delete();
      }
    }
  }
}
