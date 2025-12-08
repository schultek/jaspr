@TestOn('vm')
library;

import 'dart:async';

import 'package:jaspr_test/jaspr_test.dart';

import 'async_app.dart';

void main() {
  group('async component test', () {
    testComponents('should render future with data', (tester) async {
      final completer = Completer<String>();

      tester.pumpComponent(FutureTester(completer.future));

      expect(find.text('LOADING'), findsOneComponent);

      completer.complete('Completed');
      await tester.pump();

      expect(find.text('DATA: Completed'), findsOneComponent);
    });

    testComponents('should render future with error', (tester) async {
      final completer = Completer<String>();

      tester.pumpComponent(FutureTester(completer.future));

      expect(find.text('LOADING'), findsOneComponent);

      completer.completeError('Failed');
      await tester.pump();

      expect(find.text('ERROR: Failed'), findsOneComponent);
    });

    testComponents('should render stream', (tester) async {
      final controller = StreamController<String>();

      tester.pumpComponent(StreamTester(controller.stream));

      expect(find.text('LOADING'), findsOneComponent);

      controller.add('Hello');
      await tester.pump();

      expect(find.text('DATA: Hello'), findsOneComponent);

      controller.add('World');
      await tester.pump();

      expect(find.text('DATA: World'), findsOneComponent);

      controller.addError('Failed');
      await tester.pump();

      expect(find.text('ERROR: Failed'), findsOneComponent);

      controller.add('Fixed');
      await tester.pump();

      expect(find.text('DATA: Fixed'), findsOneComponent);

      controller.close();
      await tester.pump();

      expect(find.text('DONE'), findsOneComponent);
    });
  });
}
