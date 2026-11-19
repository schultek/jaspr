@TestOn('vm')
library;

import 'package:jaspr/server.dart';
import 'package:test/test.dart';

void main() {
  group('ServerApp.reassemble', () {
    test('notifies onReassemble listeners.', () async {
      final event = ServerApp.onReassemble.first;

      ServerApp.reassemble();

      await expectLater(event, completes);
    });
  });
}
