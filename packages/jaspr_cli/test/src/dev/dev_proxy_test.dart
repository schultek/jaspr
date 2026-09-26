import 'dart:async';

import 'package:dwds/data/build_result.dart';
import 'package:jaspr_cli/src/dev/dev_proxy.dart';
import 'package:test/test.dart';

void main() {
  group('gateBuildResults', () {
    test('holds back a succeeded result until the callbacks are done', () async {
      final generated = Completer<void>();
      final results = StreamController<BuildResult>();
      final received = <BuildStatus>[];

      gateBuildResults(results.stream, [(result) => generated.future]).listen((result) {
        received.add(result.status);
      });

      results.add(BuildResult(status: BuildStatus.succeeded));
      await pumpEventQueue();

      expect(received, isEmpty, reason: 'the client was told to reload before the files were written');

      generated.complete();
      await pumpEventQueue();

      expect(received, [BuildStatus.succeeded]);
    });

    test('runs the callbacks one after the other', () async {
      final calls = <String>[];
      final first = Completer<void>();
      final results = StreamController<BuildResult>();

      gateBuildResults(results.stream, [
        (result) {
          calls.add('first started');
          return first.future;
        },
        (result) async {
          calls.add('second started');
        },
      ]).listen((result) {
        calls.add('forwarded');
      });

      results.add(BuildResult(status: BuildStatus.succeeded));
      await pumpEventQueue();

      expect(calls, ['first started'], reason: 'the second callback started before the first was done');

      first.complete();
      await pumpEventQueue();

      expect(calls, ['first started', 'second started', 'forwarded']);
    });

    test('passes on a build that did not succeed without waiting', () async {
      final results = StreamController<BuildResult>();
      final received = <BuildStatus>[];

      gateBuildResults(results.stream, [(result) => Completer<void>().future]).listen((result) {
        received.add(result.status);
      });

      results.add(BuildResult(status: BuildStatus.started));
      results.add(BuildResult(status: BuildStatus.failed));
      await pumpEventQueue();

      expect(received, [BuildStatus.started, BuildStatus.failed]);
    });
  });
}
