@TestOn('browser')
library;

import 'package:jaspr/client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart';

import '../../utils/test_component.dart';

void main() {
  group('fragments browser test', () {
    testClient('should attach fragment children to parent', (tester) async {
      final component = FakeComponent(
        child: div([
          Component.fragment([
            h1([Component.text('Hello World')]),
            b([Component.text('Bold Text')]),
            Component.text('Some text'),
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
          Component.fragment([
            h1([Component.text('Hello World')]),
            Component.text('Some text'),
            p([Component.text('Paragraph')]),
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
          Component.text('Start'),
          Component.fragment([
            h1([Component.text('Hello World')]),
            b([Component.text('Bold Text')]),
            Component.text('Some text'),
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
          Component.text('Start'),
          Component.fragment([
            Component.fragment([]),
            h1([Component.text('Hello World')]),
            Component.fragment([
              b([Component.text('Bold Text')]),
              Component.fragment([]),
              Component.fragment([
                Component.fragment([
                  Component.fragment([Component.fragment([])]),
                  p([Component.text('Paragraph')]),
                ]),
              ]),
            ]),
            Component.text('Some text'),
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
          Component.text('Start'),
          Component.fragment(key: ValueKey('f1'), [
            h1([Component.text('Hello World')]),
          ]),
          Component.fragment(key: ValueKey('f2'), [
            b([Component.text('Bold Text')]),
            Component.text('Some text'),
          ]),
          Component.text('End'),
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

      print('MOVE');
      component.updateChild(
        div([
          Component.text('Start'),
          Component.fragment(key: ValueKey('f2'), [
            b([Component.text('Bold Text')]),
            Component.text('Some text'),
          ]),
          Component.fragment(key: ValueKey('f1'), [
            h1([Component.text('Hello World')]),
          ]),
          Component.text('End'),
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
