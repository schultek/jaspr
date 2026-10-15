import 'dart:io';

import 'package:build_daemon/constants.dart';
import 'package:jaspr_cli/src/dev/util.dart';
import 'package:test/test.dart';

void main() {
  group('Daemon process helpers', () {
    test('findPidsForPort finds process listening on port', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      try {
        final pids = await findPidsForPort(port);
        expect(pids, contains(pid));
      } finally {
        await server.close(force: true);
      }

      final pidsAfter = await findPidsForPort(port);
      expect(pidsAfter, isNot(contains(pid)));
    });

    test('getDaemonPort and getAssetServerPort parse port files correctly', () {
      final tempDir = Directory.systemTemp.createTempSync('daemon_test_');
      try {
        final ws = Directory(daemonWorkspace(tempDir.path))..createSync(recursive: true);
        File(portFilePath(tempDir.path)).writeAsStringSync('54321\nsome_token\n');
        File(assetServerPortFilePath(tempDir.path)).writeAsStringSync('54322\n');

        expect(getDaemonPort(tempDir.path), equals(54321));
        expect(getAssetServerPort(tempDir.path), equals(54322));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('stopDaemon cleans up daemon files', () async {
      final tempDir = Directory.systemTemp.createTempSync('daemon_clean_test_');
      try {
        final ws = Directory(daemonWorkspace(tempDir.path))..createSync(recursive: true);
        final portFile = File(portFilePath(tempDir.path))..writeAsStringSync('59999\ntoken');
        final assetFile = File(assetServerPortFilePath(tempDir.path))..writeAsStringSync('59998');
        final lockFile = File(lockFilePath(tempDir.path))..writeAsStringSync('');
        final versionFile = File(versionFilePath(tempDir.path))..writeAsStringSync('9');
        final optionsFile = File(optionsFilePath(tempDir.path))..writeAsStringSync('');

        expect(portFile.existsSync(), isTrue);
        expect(assetFile.existsSync(), isTrue);
        expect(lockFile.existsSync(), isTrue);

        await stopDaemon(tempDir.path);

        expect(portFile.existsSync(), isFalse);
        expect(assetFile.existsSync(), isFalse);
        expect(lockFile.existsSync(), isFalse);
        expect(versionFile.existsSync(), isFalse);
        expect(optionsFile.existsSync(), isFalse);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
