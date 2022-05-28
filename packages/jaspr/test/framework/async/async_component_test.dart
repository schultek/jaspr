import 'dart:async';

import 'package:jaspr_test/jaspr_test.dart';

import 'async_app.dart';

void main() {
  group('async component test', () {
    late ComponentTester tester;

    setUpAll(() {
      tester = ComponentTester.setUp();
    });

    test('should render future with data', () async {
      var completer = Completer<String>();

      await tester.pumpComponent(FutureTester(completer.future));

      expect(find.text('LOADING'), findsOneComponent);

      completer.complete('Completed');
      await tester.pump();

      expect(find.text('DATA: Completed'), findsOneComponent);
    });

    test('should render future with error', () async {
      var completer = Completer<String>();

      await tester.pumpComponent(FutureTester(completer.future));

      expect(find.text('LOADING'), findsOneComponent);

      completer.completeError('Failed');
      await tester.pump();

      expect(find.text('ERROR: Failed'), findsOneComponent);
    });

    test('should render stream', () async {
      var controller = StreamController<String>();

      await tester.pumpComponent(StreamTester(controller.stream));

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
