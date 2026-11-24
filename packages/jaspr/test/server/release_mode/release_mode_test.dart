@TestOn('vm')
library;

import 'dart:io';

import 'package:test/test.dart';

/// Runs the probe with [defines] and returns the `kReleaseMode` it prints.
Future<String> releaseModeWith(List<String> defines) async {
  final result = await Process.run(Platform.resolvedExecutable, [
    ...defines,
    'run',
    'test/server/release_mode/print_release_mode.dart',
  ]);
  expect(result.exitCode, equals(0), reason: '${result.stderr}');
  return (result.stdout as String).trim();
}

void main() {
  group('kReleaseMode', () {
    test('is false without defines.', () async {
      expect(await releaseModeWith([]), equals('false'));
    });

    test('is true with jaspr.flags.release.', () async {
      expect(await releaseModeWith(['-Djaspr.flags.release=true']), equals('true'));
    });

    // Set by product builds of the Dart VM, such as `dart compile exe`.
    test('is true with dart.vm.product.', () async {
      expect(await releaseModeWith(['-Ddart.vm.product=true']), equals('true'));
    });
  });
}
