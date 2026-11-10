import 'dart:io';

import 'package:jaspr_cli/src/project.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('findSnapFlutterSdkPath', () {
    late Directory tempDir;
    late Directory snapBin;
    late Directory snapSdk;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('jaspr_snap_sdk_test_');
      snapBin = Directory(path.join(tempDir.path, 'snap', 'bin'))..createSync(recursive: true);
      snapSdk = Directory(
        path.join(
          tempDir.path,
          'snap',
          'flutter',
          'current',
          'flutter',
          'bin',
          'cache',
          'dart-sdk',
        ),
      )..createSync(recursive: true);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    void createSdkMarkers({bool valid = true}) {
      File(path.join(snapSdk.path, 'bin', 'dart')).createSync(recursive: true);
      if (valid) {
        File(path.join(snapSdk.path, 'lib', 'libraries.json')).createSync(recursive: true);
      }
    }

    test('finds the bundled Dart SDK of a Snap installation of Flutter', () {
      createSdkMarkers();

      expect(
        findSnapFlutterSdkPath(pathEnv: snapBin.path),
        equals(snapSdk.path),
      );
    });

    test('finds the Snap SDK when the snap bin directory is one of several PATH entries', () {
      createSdkMarkers();
      final pathEnv = [
        '/usr/bin',
        snapBin.path,
        '/bin',
      ].join(Platform.isWindows ? ';' : ':');

      expect(findSnapFlutterSdkPath(pathEnv: pathEnv), equals(snapSdk.path));
    });

    test('returns null when the Snap SDK does not have a valid SDK layout', () {
      createSdkMarkers(valid: false);

      expect(findSnapFlutterSdkPath(pathEnv: snapBin.path), isNull);
    });

    test('returns null when Flutter is not installed as a Snap package', () {
      expect(findSnapFlutterSdkPath(pathEnv: snapBin.path), isNull);
    });

    test('returns null for PATH entries that are not a snap bin directory', () {
      createSdkMarkers();
      final otherBin = Directory(path.join(tempDir.path, 'other', 'bin'))..createSync(recursive: true);

      expect(findSnapFlutterSdkPath(pathEnv: otherBin.path), isNull);
    });
  });
}
