import 'dart:async';

import 'package:jaspr_cli/src/dev/client_call_guard.dart';
import 'package:test/test.dart';

void main() {
  group('ClientCallGuard', () {
    const timeout = Duration(milliseconds: 50);

    test('returns the result of a call that completes in time', () async {
      final guard = ClientCallGuard(timeout: timeout);

      expect(await guard.run(() async => 'ok'), equals('ok'));
      expect(guard.isUnresponsive, isFalse);
    });

    test('forwards errors of a call that fails in time', () async {
      final guard = ClientCallGuard(timeout: timeout);

      await expectLater(guard.run<void>(() async => throw StateError('failed')), throwsStateError);
      expect(guard.isUnresponsive, isFalse);
    });

    test('returns null and marks the client unresponsive when a call times out', () async {
      var unresponsiveCalls = 0;
      final guard = ClientCallGuard(timeout: timeout, onUnresponsive: () => unresponsiveCalls++);

      expect(await guard.run(() => Completer<String>().future), isNull);
      expect(guard.isUnresponsive, isTrue);
      expect(unresponsiveCalls, equals(1));
    });

    test('skips further calls while the client is unresponsive', () async {
      final guard = ClientCallGuard(timeout: timeout);
      await guard.run(() => Completer<String>().future);

      var called = false;
      final stopwatch = Stopwatch()..start();
      final result = await guard.run(() async {
        called = true;
        return 'ok';
      });

      expect(result, isNull);
      expect(called, isFalse);
      expect(stopwatch.elapsed, lessThan(timeout));
    });

    test('is responsive again once the timed out call completes', () async {
      var responsiveCalls = 0;
      final guard = ClientCallGuard(timeout: timeout, onResponsive: () => responsiveCalls++);
      final pending = Completer<String>();
      await guard.run(() => pending.future);

      pending.complete('late');
      await pumpEventQueue();

      expect(guard.isUnresponsive, isFalse);
      expect(responsiveCalls, equals(1));
      expect(await guard.run(() async => 'ok'), equals('ok'));
    });

    test('is responsive again once the timed out call fails', () async {
      final guard = ClientCallGuard(timeout: timeout);
      final pending = Completer<String>();
      await guard.run(() => pending.future);

      pending.completeError(StateError('connection closed'));
      await pumpEventQueue();

      expect(guard.isUnresponsive, isFalse);
    });
  });
}
