@TestOn('browser')
library;

import 'dart:js_interop';

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

    testClient('should maintain correct order after fragment child removal and insertion', (tester) async {
      final component = FakeComponent(
        child: div([
          Component.text('Start'),
          Component.fragment(key: ValueKey('f'), [
            b([Component.text('Emphasized text')]),
          ]),
          p([Component.text('End')]),
        ]),
      );
      tester.pumpComponent(component);

      final divElement = window.document.querySelector('body div')!;
      final bElement = window.document.querySelector('body b')!;
      final pElement = window.document.querySelector('body p')!;

      expect(divElement.childNodes.length, equals(3));
      expect(divElement.childNodes.item(0)?.textContent, equals('Start'));
      expect(divElement.childNodes.item(1), equals(bElement));
      expect(divElement.childNodes.item(2), equals(pElement));

      // Remove the fragment's child (leaving it empty) and insert a new element after it.
      // This exercises getRealNodeOf walking the sibling chain past the now-empty fragment.
      component.updateChild(
        div([
          Component.text('Start'),
          Component.fragment(key: ValueKey('f'), []),
          h1([Component.text('New heading')]),
          p([Component.text('End')]),
        ]),
      );
      await pumpEventQueue();

      final h1Element = window.document.querySelector('body h1')!;

      expect(divElement.childNodes.length, equals(3));
      expect(divElement.childNodes.item(0)?.textContent, equals('Start'));
      expect(divElement.childNodes.item(1), equals(h1Element));
      expect(divElement.childNodes.item(2), equals(pElement));

      expect(bElement.parentNode, isNull);
    });

    group('with an empty fragment as first or last child', () {
      final fragments = <String, Component Function()>{
        'empty first': () => Component.fragment([
          const Component.empty(),
          h1([Component.text('A')]),
        ]),
        'empty last': () => Component.fragment([
          h1([Component.text('A')]),
          const Component.empty(),
        ]),
        'empty first and last': () => Component.fragment([
          const Component.empty(),
          h1([Component.text('A')]),
          b([Component.text('B')]),
          const Component.empty(),
        ]),
        'nested empty first and last': () => Component.fragment([
          Component.fragment([
            Component.fragment([const Component.empty()]),
          ]),
          h1([Component.text('A')]),
          Component.fragment([
            const Component.empty(),
            Component.fragment([]),
          ]),
        ]),
        'nested fragment with empty edges': () => Component.fragment([
          Component.fragment([
            const Component.empty(),
            h1([Component.text('A')]),
            const Component.empty(),
          ]),
        ]),
      };

      for (final MapEntry(key: name, value: fragment) in fragments.entries) {
        testClient('should remove fragment children when replaced ($name)', (tester) async {
          final component = FakeComponent(child: div([fragment()]));
          tester.pumpComponent(component);

          final divElement = window.document.querySelector('body div')!;
          final h1Element = window.document.querySelector('body h1')!;
          expect(h1Element.parentNode, equals(divElement));

          component.updateChild(
            div([
              p([Component.text('Replacement')]),
            ]),
          );
          await pumpEventQueue();

          expect(divElement.innerHTML.toString(), equals('<p>Replacement</p>'));
          expect(divElement.contains(h1Element), isFalse);
        });

        testClient('should insert sibling after fragment ($name)', (tester) async {
          final component = FakeComponent(
            child: div([
              Component.text('Start'),
              Component.fragment(key: ValueKey('f'), [fragment()]),
            ]),
          );
          tester.pumpComponent(component);

          final divElement = window.document.querySelector('body div')!;
          final before = divElement.innerHTML.toString();

          component.updateChild(
            div([
              Component.text('Start'),
              Component.fragment(key: ValueKey('f'), [fragment()]),
              p([Component.text('End')]),
            ]),
          );
          await pumpEventQueue();

          expect(divElement.innerHTML.toString(), equals('$before<p>End</p>'));
        });

        testClient('should move fragment children when fragment moves ($name)', (tester) async {
          final component = FakeComponent(
            child: div([
              Component.fragment(key: ValueKey('f1'), [fragment()]),
              Component.fragment(key: ValueKey('f2'), [
                p([Component.text('P')]),
              ]),
            ]),
          );
          tester.pumpComponent(component);

          final divElement = window.document.querySelector('body div')!;
          final fragmentHtml = divElement.innerHTML.toString().replaceAll('<p>P</p>', '');

          component.updateChild(
            div([
              Component.fragment(key: ValueKey('f2'), [
                p([Component.text('P')]),
              ]),
              Component.fragment(key: ValueKey('f1'), [fragment()]),
            ]),
          );
          await pumpEventQueue();

          expect(divElement.innerHTML.toString(), equals('<p>P</p>$fragmentHtml'));
        });
      }

      final updates = <String, (List<Component>, List<Component>)>{
        'added first': (
          [
            h1([Component.text('A')]),
          ],
          [
            const Component.empty(),
            h1([Component.text('A')]),
          ],
        ),
        'added last': (
          [
            h1([Component.text('A')]),
          ],
          [
            h1([Component.text('A')]),
            const Component.empty(),
          ],
        ),
        'moved first': (
          [
            h1(key: ValueKey('h'), [Component.text('A')]),
            Component.fragment(key: ValueKey('e'), []),
          ],
          [
            Component.fragment(key: ValueKey('e'), []),
            h1(key: ValueKey('h'), [Component.text('A')]),
          ],
        ),
        'moved last': (
          [
            Component.fragment(key: ValueKey('e'), []),
            h1(key: ValueKey('h'), [Component.text('A')]),
          ],
          [
            h1(key: ValueKey('h'), [Component.text('A')]),
            Component.fragment(key: ValueKey('e'), []),
          ],
        ),
      };

      for (final MapEntry(key: name, value: (before, after)) in updates.entries) {
        testClient('should place and remove fragment children after the empty fragment was $name', (tester) async {
          final component = FakeComponent(child: div([Component.fragment(before)]));
          tester.pumpComponent(component);

          final divElement = window.document.querySelector('body div')!;

          component.updateChild(div([Component.fragment(after)]));
          await pumpEventQueue();

          expect(divElement.innerHTML.toString(), equals('<h1>A</h1>'));

          component.updateChild(
            div([
              Component.fragment(after),
              p([Component.text('End')]),
            ]),
          );
          await pumpEventQueue();

          expect(divElement.innerHTML.toString(), equals('<h1>A</h1><p>End</p>'));

          component.updateChild(
            div([
              p([Component.text('Replacement')]),
            ]),
          );
          await pumpEventQueue();

          expect(divElement.innerHTML.toString(), equals('<p>Replacement</p>'));
        });
      }

      testClient('should remove hydrated fragment children when replaced', (tester) async {
        window.document.body!.innerHTML = '<div><h1>A</h1><p>B</p></div>'.toJS;

        final component = FakeComponent(
          child: div([
            Component.fragment([
              const Component.empty(),
              h1([Component.text('A')]),
              p([Component.text('B')]),
              const Component.empty(),
            ]),
          ]),
        );
        tester.pumpComponent(component);

        final divElement = window.document.querySelector('body div')!;
        expect(divElement.innerHTML.toString(), equals('<h1>A</h1><p>B</p>'));

        component.updateChild(
          div([
            b([Component.text('Replacement')]),
          ]),
        );
        await pumpEventQueue();

        expect(divElement.innerHTML.toString(), equals('<b>Replacement</b>'));
      });

      testClient('should move fragment children with a global key to a new parent', (tester) async {
        final key = GlobalKey();
        Component fragment() => Component.fragment(key: key, [
          const Component.empty(),
          h1([Component.text('A')]),
          const Component.empty(),
        ]);

        final component = FakeComponent(
          child: div([
            section([fragment()]),
            article([]),
          ]),
        );
        tester.pumpComponent(component);

        final divElement = window.document.querySelector('body div')!;

        component.updateChild(
          div([
            section([]),
            article([Component.text('Start'), fragment()]),
          ]),
        );
        await pumpEventQueue();

        expect(divElement.innerHTML.toString(), equals('<section></section><article>Start<h1>A</h1></article>'));

        component.updateChild(
          div([
            section([]),
            article([Component.text('Start')]),
          ]),
        );
        await pumpEventQueue();

        expect(divElement.innerHTML.toString(), equals('<section></section><article>Start</article>'));
      });
    });

    testClient('should place a moved child after empty fragments that keep their slot', (tester) async {
      Component empty(int key) => Component.fragment(key: ValueKey(key), []);

      final component = FakeComponent(
        child: div([
          b(key: ValueKey('start'), [Component.text('S')]),
          span(key: ValueKey('moved'), [Component.text('X')]),
          empty(1),
          empty(2),
          empty(3),
          b(key: ValueKey('end'), [Component.text('E')]),
        ]),
      );
      tester.pumpComponent(component);

      final divElement = document.querySelector('body div')!;
      expect(divElement.innerHTML.toString(), equals('<b>S</b><span>X</span><b>E</b>'));

      // The fragment with key 2 keeps its slot (same index, same previous sibling),
      // so it is not attached again while the span moves behind it.
      component.updateChild(
        div([
          b(key: ValueKey('start'), [Component.text('S')]),
          empty(3),
          empty(1),
          empty(2),
          span(key: ValueKey('moved'), [Component.text('X')]),
          b(key: ValueKey('end'), [Component.text('E')]),
        ]),
      );
      await pumpEventQueue();

      expect(divElement.innerHTML.toString(), equals('<b>S</b><span>X</span><b>E</b>'));

      component.updateChild(
        div([
          p([Component.text('Replacement')]),
        ]),
      );
      await pumpEventQueue();

      expect(divElement.innerHTML.toString(), equals('<p>Replacement</p>'));
    });
  });
}
