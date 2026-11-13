import 'dart:convert';
import 'dart:io';

import 'package:build_daemon/constants.dart';
import 'package:jaspr_cli/src/dev/client_runner.dart';
import 'package:jaspr_cli/src/dev/util.dart';
import 'package:jaspr_cli/src/logging.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ClientRunner', () {
    // Regression test for https://github.com/schultek/jaspr/issues/997.
    //
    // Uses real processes on purpose: the fakes connect through
    // `connectUnchecked`, so `startBuildDaemon` never returns `null` there.
    test('build does not stop a build daemon that another process started', () async {
      final tempDir = Directory.systemTemp.createTempSync('client_runner_test_');

      // Stands in for the build daemon of a running `jaspr serve`: a separate
      // process listening on the port from the daemon's port file.
      final script = File(p.join(tempDir.path, 'other_daemon.dart'))
        ..writeAsStringSync('''
import 'dart:io';

void main() async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  print(server.port);
}
''');
      final otherDaemon = await Process.start(Platform.resolvedExecutable, [script.path]);
      addTearDown(() async {
        otherDaemon.kill();
        await otherDaemon.exitCode;
        tempDir.deleteSync(recursive: true);
      });
      final port = int.parse(
        await otherDaemon.stdout.transform(utf8.decoder).transform(const LineSplitter()).first,
      );

      Directory(daemonWorkspace(tempDir.path)).createSync(recursive: true);
      File(portFilePath(tempDir.path)).writeAsStringSync('$port\ntoken');
      expect(await isDaemonRunning(tempDir.path), isTrue);

      // Connecting fails in the empty directory, which takes the same
      // `client == null` path as an options skew with the other daemon.
      final exitCode = await IOOverrides.runZoned(
        () => ClientRunner.build(buildOptions: [], outputDir: 'build', logger: Logger(false)),
        getCurrentDirectory: () => tempDir,
      );

      expect(exitCode, equals(1));
      expect(await isDaemonRunning(tempDir.path), isTrue, reason: 'the other daemon must keep running');
      expect(File(portFilePath(tempDir.path)).existsSync(), isTrue, reason: 'its port file must be kept');
    });
  });
}
