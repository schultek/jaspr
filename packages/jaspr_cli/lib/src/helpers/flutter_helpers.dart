import 'dart:async';
import 'dart:io';

import '../commands/base_command.dart';
import '../logging.dart';
import 'copy_helper.dart';

mixin FlutterHelper on BaseCommand {
  late final usesFlutter = () {
    return config.usesFlutter;
  }();

  Future<Process> serveFlutter() async {
    await _ensureTarget();

    var flutterProcess = await Process.start(
      'flutter',
      ['run', '--device-id=web-server', '-t', '.dart_tool/jaspr/flutter_target.dart', '--web-port=5678'],
    );

    if (verbose) {
      unawaited(watchProcess(flutterProcess, tag: Tag.flutter, onFail: () {
        if (!verbose) {}
      }));
    } else {
      flutterProcess.exitCode.then((code) {
        if (code != 0) {
          logger.write('flutter exited unexpectedly. Run again with -v to see verbose output',
              level: Level.critical, progress: ProgressState.completed);
          shutdown(code);
        }
      });
    }

    guardResource(() async => flutterProcess.kill());

    return flutterProcess;
  }

  Future<void> buildFlutter(bool useSSR) async {
    await _ensureTarget();

    var flutterProcess = await Process.start(
      'flutter',
      ['build', 'web', '-t', '.dart_tool/jaspr/flutter_target.dart', '--output=build/flutter'],
    );

    var target = useSSR ? 'build/jaspr/web' : 'build/jaspr';

    var moveTargets = [
      'version.json',
      'flutter_service_worker.js',
      'assets/',
      'canvaskit/',
    ];

    await watchProcess(flutterProcess, tag: Tag.flutter);

    await copyFiles('./build/flutter', target, moveTargets);
  }

  Future<void> _ensureTarget() async {
    var flutterTarget = File('.dart_tool/jaspr/flutter_target.dart');
    if (!await flutterTarget.exists()) {
      await flutterTarget.create(recursive: true);
    }
    await flutterTarget.writeAsString('void main() {}');
  }
}
