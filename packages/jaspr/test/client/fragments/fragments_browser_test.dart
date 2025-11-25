@TestOn('browser')
library;

import 'package:jaspr/client.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart';

import '../../utils/test_component.dart';

void main() {
  group('fragments browser test', () {
    testClient('should attach fragment children to parent', (tester) async {
      final component = FakeComponent(
        child: div([
          fragment([
            h1([text('Hello World')]),
            b([text('Bold Text')]),
            text('Some text'),
          ]),
        ]),
      );
      tester.pumpComponent(component);

      final divElement = window.document.querySelector('body div')!;
      final h1Element = window.document.querySelector('body h1')!;
      final bElement = window.document.querySelector('body b')!;

      expect(divElement.childNodes.length, equals(3));
      expect(divElement.childNodes.item(0), equals(h1Element));
      expect(divElement.childNodes.item(1), equals(bElement));
      expect(divElement.childNodes.item(2)?.textContent, equals('Some text'));

      component.updateChild(
        div([
          fragment([
            h1([text('Hello World')]),
            text('Some text'),
            p([text('Paragraph')]),
          ]),
        ]),
      );
      await pumpEventQueue();

      final pElement = window.document.querySelector('body p')!;

      expect(divElement.childNodes.length, equals(3));
      expect(divElement.childNodes.item(0), equals(h1Element));
      expect(divElement.childNodes.item(1)?.textContent, equals('Some text'));
      expect(divElement.childNodes.item(2), equals(pElement));

      expect(bElement.parentNode, isNull);
    });

    testClient('should attach fragment children to parent after start node', (tester) async {
      tester.pumpComponent(
        div([
          text('Start'),
          fragment([
            h1([text('Hello World')]),
            b([text('Bold Text')]),
            text('Some text'),
          ]),
        ]),
      );

      final divElement = window.document.querySelector('body div')!;
      final h1Element = window.document.querySelector('body h1')!;
      final bElement = window.document.querySelector('body b')!;

      expect(divElement.childNodes.length, equals(4));
      expect(divElement.childNodes.item(0)?.textContent, equals('Start'));
      expect(divElement.childNodes.item(1), equals(h1Element));
      expect(divElement.childNodes.item(2), equals(bElement));
      expect(divElement.childNodes.item(3)?.textContent, equals('Some text'));
    });

    testClient('should attach children in correct order with empty fragments', (tester) async {
      tester.pumpComponent(
        div([
          text('Start'),
          fragment([
            fragment([]),
            h1([text('Hello World')]),
            fragment([
              b([text('Bold Text')]),
              fragment([]),
              fragment([
                fragment([
                  fragment([fragment([])]),
                  p([text('Paragraph')]),
                ]),
              ]),
            ]),
            text('Some text'),
          ]),
        ]),
      );

      final divElement = window.document.querySelector('body div')!;
      final h1Element = window.document.querySelector('body h1')!;
      final bElement = window.document.querySelector('body b')!;
      final pElement = window.document.querySelector('body p')!;

      expect(divElement.childNodes.length, equals(5));
      expect(divElement.childNodes.item(0)?.textContent, equals('Start'));
      expect(divElement.childNodes.item(1), equals(h1Element));
      expect(divElement.childNodes.item(2), equals(bElement));
      expect(divElement.childNodes.item(3), equals(pElement));
      expect(divElement.childNodes.item(4)?.textContent, equals('Some text'));
    });

    testClient('should move fragment children when fragment moves', (tester) async {
      final component = FakeComponent(
        child: div([
          text('Start'),
          fragment(key: ValueKey('f1'), [
            h1([text('Hello World')]),
          ]),
          fragment(key: ValueKey('f2'), [
            b([text('Bold Text')]),
            text('Some text'),
          ]),
          text('End'),
        ]),
      );
      tester.pumpComponent(component);

      final divElement = window.document.querySelector('body div')!;
      final h1Element = window.document.querySelector('body h1')!;
      final bElement = window.document.querySelector('body b')!;

      expect(divElement.childNodes.length, equals(5));
      expect(divElement.childNodes.item(0)?.textContent, equals('Start'));
      expect(divElement.childNodes.item(1), equals(h1Element));
      expect(divElement.childNodes.item(2), equals(bElement));
      expect(divElement.childNodes.item(3)?.textContent, equals('Some text'));
      expect(divElement.childNodes.item(4)?.textContent, equals('End'));

      print("MOVE");
      component.updateChild(
        div([
          text('Start'),
          fragment(key: ValueKey('f2'), [
            b([text('Bold Text')]),
            text('Some text'),
          ]),
          fragment(key: ValueKey('f1'), [
            h1([text('Hello World')]),
          ]),
          text('End'),
        ]),
      );
      await pumpEventQueue();

      expect(divElement.childNodes.length, equals(5));
      expect(divElement.childNodes.item(0)?.textContent, equals('Start'));
      expect(divElement.childNodes.item(1), equals(bElement));
      expect(divElement.childNodes.item(2)?.textContent, equals('Some text'));
      expect(divElement.childNodes.item(3), equals(h1Element));
      expect(divElement.childNodes.item(4)?.textContent, equals('End'));
    });
  });
}
